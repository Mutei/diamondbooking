import 'package:diamond_booking/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Import this for shared preferences

import '../constants/styles.dart';

class ActiveCustomersScreen extends StatefulWidget {
  final String idEstate;

  const ActiveCustomersScreen({super.key, required this.idEstate});

  @override
  ActiveCustomersScreenState createState() => ActiveCustomersScreenState();
}

class ActiveCustomersScreenState extends State<ActiveCustomersScreen> {
  final DatabaseReference databaseReference = FirebaseDatabase.instance.ref();
  List<Map<String, dynamic>> activeCustomers = [];
  Set<String> ratedCustomers = Set<String>();

  @override
  void initState() {
    super.initState();
    fetchActiveCustomers();
  }

  void fetchActiveCustomers() {
    DatabaseReference activeCustomersRef =
        databaseReference.child("App/ActiveCustomers/${widget.idEstate}");
    activeCustomersRef.onValue.listen((event) {
      if (event.snapshot.exists) {
        Map activeUsers = event.snapshot.value as Map;
        setState(() {
          activeCustomers = activeUsers.entries.map((entry) {
            return {"id": entry.key, "timestamp": entry.value['timestamp']};
          }).toList();
        });
      } else {
        setState(() {
          activeCustomers = [];
        });
      }
    });
  }

  Future<String> getUserFullName(String userId) async {
    DatabaseReference userRef =
        FirebaseDatabase.instance.ref("App").child("User").child(userId);
    DataSnapshot snapshot = await userRef.get();
    if (snapshot.exists) {
      String firstName = snapshot.child("FirstName").value?.toString() ?? "";
      String secondName = snapshot.child("SecondName").value?.toString() ?? "";
      String lastName = snapshot.child("LastName").value?.toString() ?? "";
      return "$firstName $secondName $lastName";
    }
    return "";
  }

  Future<void> removeCustomer(String userId) async {
    // Clear shared preferences for the removed customer
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.remove('access_time_${widget.idEstate}_$userId');
    sharedPreferences.remove('last_scan_time_${widget.idEstate}_$userId');

    await databaseReference
        .child("App/ActiveCustomers/${widget.idEstate}/$userId")
        .remove();
    setState(() {
      activeCustomers.removeWhere((customer) => customer['id'] == userId);
    });
  }

  void rateCustomer(String userId, double rating) {
    DatabaseReference feedbackRef =
        databaseReference.child("App/ProviderFeedbackToCustomer/$userId");
    feedbackRef.push().set({
      'rating': rating,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });
    setState(() {
      ratedCustomers.add(userId);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('User rated $rating stars')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Active Customers',
          style: TextStyle(
            color: kPrimaryColor,
          ),
        ),
        centerTitle: true,
        iconTheme: kIconTheme,
      ),
      body: ListView.builder(
        itemCount: activeCustomers.length,
        itemBuilder: (context, index) {
          String userId = activeCustomers[index]['id'];
          return FutureBuilder<String>(
            future: getUserFullName(userId),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const ListTile(
                  title: Text('Loading...'),
                );
              }
              if (snapshot.hasError || !snapshot.hasData) {
                return const ListTile(
                  title: Text('Error loading user'),
                );
              }
              return ListTile(
                title: Text(
                  snapshot.data!,
                  style: const TextStyle(
                    color: kPrimaryColor,
                  ),
                ),
                subtitle: Text(
                  'Active since: ${DateTime.fromMillisecondsSinceEpoch(activeCustomers[index]['timestamp'])}',
                  style: const TextStyle(
                    color: kPrimaryColor,
                  ),
                ),
                trailing: PopupMenuButton<String>(
                  color: kPrimaryColor,
                  onSelected: (value) {
                    if (value == 'rate' && !ratedCustomers.contains(userId)) {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text('Rate ${snapshot.data!}'),
                          content: RatingBar.builder(
                            initialRating: 3,
                            minRating: 1,
                            direction: Axis.horizontal,
                            allowHalfRating: true,
                            itemCount: 5,
                            itemBuilder: (context, _) => const Icon(
                              Icons.star,
                              color: Colors.amber,
                            ),
                            onRatingUpdate: (rating) {
                              Navigator.of(context).pop();
                              rateCustomer(userId, rating);
                            },
                          ),
                        ),
                      );
                    } else if (value == 'remove') {
                      removeCustomer(userId);
                    }
                  },
                  itemBuilder: (context) => [
                    if (!ratedCustomers.contains(userId))
                      const PopupMenuItem(
                        value: 'rate',
                        child: Text(
                          'Rate',
                          style: TextStyle(
                            color: kPrimaryColor,
                          ),
                        ),
                      ),
                    const PopupMenuItem(
                      value: 'remove',
                      child: Text(
                        'Remove',
                        style: TextStyle(
                          color: kPrimaryColor,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
