import 'package:diamond_booking/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
  String? typeAccount;

  @override
  void initState() {
    super.initState();
    fetchActiveCustomers();
    fetchTypeAccount();
    initializeRatedCustomers();
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

  Future<void> fetchTypeAccount() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DatabaseReference userRef =
          databaseReference.child("App/User/${user.uid}/TypeAccount");
      DataSnapshot snapshot = await userRef.get();
      if (snapshot.exists) {
        setState(() {
          typeAccount = snapshot.value.toString();
        });
        print('TypeAccount: $typeAccount');
      }
    }
  }

  Future<void> initializeRatedCustomers() async {
    // Here you should initialize ratedCustomers based on session information
    // This is a placeholder example
    // Fetch rated customers for this session from Firebase or any other source
    // and populate the ratedCustomers set accordingly
    // Example:
    // ratedCustomers = await fetchRatedCustomersForSession();
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
    await databaseReference
        .child("App/ActiveCustomers/${widget.idEstate}/$userId")
        .remove();
    setState(() {
      activeCustomers.removeWhere((customer) => customer['id'] == userId);
    });

    // Notify chat screen about removal
    DatabaseReference refChat = FirebaseDatabase.instance
        .ref("App")
        .child("Chat")
        .child(widget.idEstate)
        .child(userId);
    await refChat.remove();
  }

  void rateCustomer(String userId, double rating, String comment) async {
    DatabaseReference feedbackRef = databaseReference
        .child("App/ProviderFeedbackToCustomer/$userId/ratings");

    DataSnapshot snapshot = await feedbackRef.get();
    double totalRating = 0;
    int ratingCount = 0;

    if (snapshot.exists) {
      Map<dynamic, dynamic> ratings = snapshot.value as Map<dynamic, dynamic>;
      ratings.forEach((key, value) {
        totalRating += value['rating'];
        ratingCount++;
      });

      totalRating += rating;
      ratingCount++;
    } else {
      totalRating = rating;
      ratingCount = 1;
    }

    double averageRating = totalRating / ratingCount;

    await databaseReference
        .child("App/ProviderFeedbackToCustomer/$userId")
        .update({
      'averageRating': averageRating,
      'ratingCount': ratingCount,
    });

    await feedbackRef.push().set({
      'rating': rating,
      'comment': comment,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });

    setState(() {
      ratedCustomers.add(userId);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text('User rated $rating stars with comment: $comment')),
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
                  iconColor: kPrimaryColor,
                  onSelected: (value) {
                    if (value == 'rate' && !ratedCustomers.contains(userId)) {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text('Rate ${snapshot.data!}'),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              RatingBar.builder(
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
                                  // store rating temporarily
                                  setState(() {
                                    ratedCustomers.add(userId);
                                  });
                                  Navigator.of(context).pop();
                                  // show comment dialog
                                  showDialog(
                                    context: context,
                                    builder: (context) {
                                      TextEditingController commentController =
                                          TextEditingController();
                                      return AlertDialog(
                                        title: Text(
                                            'Add Comment for ${snapshot.data!}'),
                                        content: TextField(
                                          controller: commentController,
                                          decoration: InputDecoration(
                                            hintText: 'Enter comment',
                                          ),
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                              rateCustomer(userId, rating,
                                                  commentController.text);
                                            },
                                            child: Text('Submit'),
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    } else if (value == 'remove') {
                      removeCustomer(userId);
                    }
                  },
                  itemBuilder: (context) => [
                    if (typeAccount == '3' || typeAccount == '4')
                      if (!ratedCustomers.contains(userId))
                        const PopupMenuItem(
                          value: 'rate',
                          child: Text(
                            'Rate & Comment',
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
