import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import '../models/user.dart' as model;

class AuthMethods {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  DatabaseReference ref = FirebaseDatabase.instance.ref("App").child("User");
  Future<String> signUpUser({
    required String userName,
    required String email,
    required String phoneNumber,
    required String password,
    required String countryCode,
    required String countryValue,
    required String stateValue,
    required String cityValue,
    required String bod,
    required String typeAccount,
    required String typeUser,
  }) async {
    String res = "An error occurred";
    try {
      if (email.isNotEmpty ||
          userName.isNotEmpty ||
          phoneNumber.isNotEmpty ||
          password.isNotEmpty) {
        // Register user
        UserCredential credential = await _auth.createUserWithEmailAndPassword(
            email: email, password: password);
        // Add user to realtime database
        model.User user = model.User(
          userName: userName,
          email: email,
          phoneNumber: countryCode + phoneNumber,
          password: password,
          uid: credential.user!.uid,
          birthOfDate: bod,
          countryValue: countryValue,
          cityValue: cityValue,
          stateValue: stateValue,
          typeAccount: typeAccount,
          typeUser: typeUser,
        );
        await ref.child(credential.user!.uid).set(
              user.toJson(),
            );
        res = "User registered successfully";
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'invalid-email') {
        res = 'Email is badly formated';
      } else if (e.code == 'weak-password') {
        res = 'Password should be at least 6 characters';
      }
    } catch (e) {
      res = e.toString();
    }
    return res;
  }
}
