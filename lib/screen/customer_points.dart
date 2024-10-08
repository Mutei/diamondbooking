import 'package:diamond_booking/constants/colors.dart';
import 'package:diamond_booking/constants/styles.dart';
import 'package:diamond_booking/extension/sized_box_extension.dart';
import 'package:diamond_booking/localization/language_constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class CustomerPoints extends StatefulWidget {
  const CustomerPoints({super.key});

  @override
  State<CustomerPoints> createState() => _CustomerPointsState();

  static Future<void> addPointsForRating() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userId = user.uid;
      final databaseReference = FirebaseDatabase.instance
          .ref()
          .child('App/CustomerPoints')
          .child(userId);

      final pointsSnapshot = await databaseReference.child('points').get();
      double currentPoints = 0;
      if (pointsSnapshot.exists) {
        currentPoints = (pointsSnapshot.value as num).toDouble();
      }

      await databaseReference.child('points').set(currentPoints + 10);
    }
  }
}

class _CustomerPointsState extends State<CustomerPoints> {
  final DatabaseReference _databaseReference =
      FirebaseDatabase.instance.ref().child('App/CustomerPoints');
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
      final pointsRef = _databaseReference.child(userId).child('points');

      // Listen for changes in the points
      pointsRef.onValue.listen((event) {
        if (event.snapshot.exists) {
          setState(() {
            _totalPoints = (event.snapshot.value as num).toDouble();
          });
        } else {
          setState(() {
            _totalPoints = 0.0;
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final progressToNextReward = _totalPoints / 1500;
    final nextRewardPoints = _totalPoints >= 1500 ? 3000 : 1500;

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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Column(
                children: [
                  Text(
                    '${getTranslated(context, "Total Points")}: $_totalPoints',
                    style: const TextStyle(fontSize: 24),
                  ),
                  16.kH,
                  LinearProgressIndicator(
                    value: progressToNextReward > 1
                        ? (progressToNextReward - 1)
                        : progressToNextReward,
                    backgroundColor: Colors.grey[300],
                    color: kPrimaryColor,
                    minHeight: 10,
                  ),
                  8.kH,
                  Text(
                    _totalPoints >= 1500
                        ? getTranslated(context, '10 SR off with 3000 points')
                        : getTranslated(context, '5 SR off with 1500 points'),
                    style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                  ),
                ],
              ),
            ),
            32.kH,
            Text(
              getTranslated(context, "How it works?"),
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            8.kH,
            Text(
              getTranslated(context,
                  'Earn points by rating and giving feedback to providers. Reach 1500 points to get 5 SR off, and 3000 points to get 10 SR off.'),
              style: TextStyle(fontSize: 16),
            ),
            // Add more sections as needed
          ],
        ),
      ),
    );
  }
}
