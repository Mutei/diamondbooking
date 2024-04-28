import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class AuthMethods {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  DatabaseReference ref = FirebaseDatabase.instance.ref("App").child("User");
  static String verifyId = '';
  static Future sentOtp({
    required Function errorStep,
    required Function nextStep,
    required String phoneNo,
  }) async {
    await _auth
        .verifyPhoneNumber(
      phoneNumber: '+966$phoneNo',
      timeout: Duration(
        seconds: 30,
      ),
      verificationCompleted: (phoneAuthCredential) async {
        return;
      },
      verificationFailed: (error) async {
        return;
      },
      codeSent: (verificationId, forceResendingToken) async {
        verifyId = verificationId;
        nextStep();
      },
      codeAutoRetrievalTimeout: (verificationId) async {
        return;
      },
    )
        .onError(
      (error, stackTrace) {
        errorStep();
      },
    );
  }
}
