import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class GeneralProvider with ChangeNotifier {
  int _requestCount = 0;

  int get requestCount => _requestCount;

  void setRequestCount(int count) {
    _requestCount = count;
    notifyListeners();
  }

  void resetRequestCount() {
    _requestCount = 0;
    notifyListeners();
  }

  Future<void> fetchRequestCount() async {
    String? id = FirebaseAuth.instance.currentUser?.uid;
    if (id != null) {
      DatabaseReference requestRef =
          FirebaseDatabase.instance.ref("App").child("Booking").child("Book");

      requestRef.orderByChild("IDOwner").equalTo(id).onValue.listen((event) {
        int count = 0;
        if (event.snapshot.exists) {
          event.snapshot.children.forEach((child) {
            if (child.child("Status").value == "1") {
              count++;
            }
          });
        }
        setRequestCount(count);
      });
    }
  }
}
