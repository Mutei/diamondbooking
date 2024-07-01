import 'package:diamond_booking/constants/colors.dart';
import 'package:diamond_booking/constants/styles.dart';
import 'package:diamond_booking/localization/language_constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class CustomerPoints extends StatefulWidget {
  const CustomerPoints({super.key});

  @override
  State<CustomerPoints> createState() => _CustomerPointsState();
}

class _CustomerPointsState extends State<CustomerPoints> {
  final DatabaseReference _databaseReference =
      FirebaseDatabase.instance.ref().child('App/ProviderFeedbackToCustomer');
  double _totalPoints = 0.0;

  @override
  void initState() {
    super.initState();
    _fetchCustomerPoints();
  }

  void _fetchCustomerPoints() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userId = user.uid;
      final ratingsRef = _databaseReference.child(userId);

      ratingsRef.onValue.listen((event) {
        double totalPoints = 0.0;
        if (event.snapshot.value != null) {
          final ratingsData =
              Map<String, dynamic>.from(event.snapshot.value as Map);
          ratingsData.forEach((key, value) {
            final rating = (value['rating'] ?? 0).toDouble();
            totalPoints += rating;
          });
        }
        setState(() {
          _totalPoints = totalPoints;
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        iconTheme: kIconTheme,
        title: Text(
          getTranslated(
            context,
            "My Points",
          ),
          style: const TextStyle(color: kPrimaryColor),
        ),
      ),
      body: Center(
        child: Text(
          '${getTranslated(context, "Total Points")}: $_totalPoints',
          style: const TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
