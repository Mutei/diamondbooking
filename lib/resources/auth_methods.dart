import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthMethods {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> createUserWithEmailAndPassword({
    required String email,
    required String password,
    required BuildContext context,
    required Function onSuccess,
    required Function(String) onError,
  }) async {
    try {
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      // Additional logic after user is created, if necessary
      onSuccess(); // Callback function on successful creation
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        onError('The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        onError('The account already exists for that email.');
      } else {
        onError('Failed to create account: ${e.message}');
      }
    } catch (e) {
      onError('An error occurred: ${e.toString()}');
    }
  }
}
