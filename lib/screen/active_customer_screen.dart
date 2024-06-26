import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class ActiveCustomersScreen extends StatefulWidget {
  final String idEstate;

  const ActiveCustomersScreen({super.key, required this.idEstate});

  @override
  ActiveCustomersScreenState createState() => ActiveCustomersScreenState();
}

class ActiveCustomersScreenState extends State<ActiveCustomersScreen> {
  final DatabaseReference databaseReference = FirebaseDatabase.instance.ref();
  List<Map<String, dynamic>> activeCustomers = [];

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Active Customers'),
      ),
      body: ListView.builder(
        itemCount: activeCustomers.length,
        itemBuilder: (context, index) {
          return FutureBuilder<String>(
            future: getUserFullName(activeCustomers[index]['id']),
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
                title: Text(snapshot.data!),
                subtitle: Text(
                    'Active since: ${DateTime.fromMillisecondsSinceEpoch(activeCustomers[index]['timestamp'])}'),
              );
            },
          );
        },
      ),
    );
  }
}
