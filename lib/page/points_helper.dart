import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class PointsHelper {
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
