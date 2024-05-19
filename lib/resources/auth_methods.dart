// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_database/firebase_database.dart';
// import '../models/user.dart' as model;
// import 'package:flutter/material.dart';
//
// import '../screen/main_screen.dart';
// import '../screen/personal_info_screen.dart';
// import '../screen/verification_screen.dart';
//
// class AuthMethods {
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   DatabaseReference ref = FirebaseDatabase.instance.ref("App").child("User");
//
//   Future<String> signUpUser({
//     required String userName,
//     required String email,
//     required String phoneNumber,
//     required String password,
//     required String countryCode,
//     required String countryValue,
//     required String stateValue,
//     required String cityValue,
//     required String bod,
//     required String typeAccount,
//     required String typeUser,
//   }) async {
//     String res = "An error occurred";
//     try {
//       if (email.isNotEmpty ||
//           userName.isNotEmpty ||
//           phoneNumber.isNotEmpty ||
//           password.isNotEmpty) {
//         // Register user
//         UserCredential credential = await _auth.createUserWithEmailAndPassword(
//             email: email, password: password);
//
//         // Add user to realtime database
//         model.User user = model.User(
//           userName: userName,
//           email: email,
//           phoneNumber: countryCode + phoneNumber,
//           password: password,
//           uid: credential.user!.uid,
//           birthOfDate: bod,
//           countryValue: countryValue,
//           cityValue: cityValue,
//           stateValue: stateValue,
//           typeAccount: typeAccount,
//           typeUser: typeUser,
//         );
//         await ref.child(credential.user!.uid).set(
//               user.toJson(),
//             );
//         res = "User registered successfully";
//       }
//     } on FirebaseAuthException catch (e) {
//       if (e.code == 'invalid-email') {
//         res = 'Email is badly formated';
//       } else if (e.code == 'weak-password') {
//         res = 'Password should be at least 6 characters';
//       }
//     } catch (e) {
//       res = e.toString();
//     }
//     return res;
//   }
// }

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

import '../screen/main_screen.dart';
import '../screen/personal_info_screen.dart';
import '../screen/verification_screen.dart';

class AuthMethods {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _ref =
      FirebaseDatabase.instance.ref("App").child("User");

  Future<void> registerWithEmailAndPassword(
    BuildContext context,
    String email,
    String password,
    String phoneNumber,
    String? typeUser,
    String? typeAccount,
  ) async {
    try {
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (userCredential.user != null) {
        print("Type user : $typeUser");
        print("Type Account: $typeAccount");
        sendOtp(context, phoneNumber, email, password, typeUser!, typeAccount!);
      }
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content:
                Text(e.message ?? "Something went wrong while registering"),
          ),
        );
    }
  }

  Future<void> sendOtp(BuildContext context, String phoneNumber, String email,
      String password, String typeUser, String typeAccount) async {
    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential phoneAuthCredential) async {
          await _auth.currentUser?.linkWithCredential(phoneAuthCredential);
          if (!context.mounted) return;
          print("Type user again is $typeUser");
          print("Type account again is $typeAccount");
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (context) => PersonalInfoScreen(
                email: email,
                phoneNumber: phoneNumber,
                password: password,
                typeUser: typeUser,
                typeAccount: typeAccount,
              ),
            ),
            (Route<dynamic> route) => false,
          );
        },
        verificationFailed: (FirebaseAuthException error) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Text(error.message ??
                    "Something went wrong while verifying phone number"),
              ),
            );
        },
        codeSent: (String verificationId, int? forceResendingToken) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => VerifyOtp(
                phoneNumber: phoneNumber,
                verificationId: verificationId,
                email: email,
                password: password,
                typeUser: typeUser,
                typeAccount: typeAccount,
              ),
            ),
          );
        },
        codeAutoRetrievalTimeout: (String verificationId) {},
      );
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(e.message ??
                "Something went wrong while verifying phone number"),
          ),
        );
    } catch (e) {
      print(e);
    }
  }

  Future<void> verifyOtp(
      BuildContext context,
      String verificationId,
      String smsCode,
      String email,
      String phoneNumber,
      String password,
      String typeUser,
      String typeAccount) async {
    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );
      await _auth.currentUser?.linkWithCredential(credential);
      if (!context.mounted) return;

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (context) => PersonalInfoScreen(
            email: email,
            phoneNumber: phoneNumber,
            password: password,
            typeUser: typeUser,
            typeAccount: typeAccount,
          ),
        ),
        (Route<dynamic> route) => false,
      );
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(e.message ??
                "Something went wrong while verifying phone number"),
          ),
        );
    } catch (e) {
      print(e);
    }
  }

  Future<String> loginUser({
    required String email,
    required String password,
    required BuildContext context,
  }) async {
    String res = 'Some error occurred!';
    try {
      if (email.isNotEmpty || password.isNotEmpty) {
        await _auth.signInWithEmailAndPassword(
            email: email, password: password);
        res = 'success';
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => MainScreen()),
          (Route<dynamic> route) => false,
        );
      } else {
        res = 'Please enter all the fields';
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'wrong-password') {
        res = 'You entered a wrong password';
      } else if (e.code == 'user-not-found') {
        res = 'User is not found';
      } else {
        res = 'Log-in Successful';
      }
    } catch (e) {
      res = e.toString();
    }
    return res;
  }

  Future<void> sendOtpForLogin(BuildContext context, String phoneNumber) async {
    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential phoneAuthCredential) async {
          await _auth.signInWithCredential(phoneAuthCredential);
          if (!context.mounted) return;
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => MainScreen()),
            (Route<dynamic> route) => false,
          );
        },
        verificationFailed: (FirebaseAuthException error) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Text(error.message ??
                    "Something went wrong while verifying phone number"),
              ),
            );
        },
        codeSent: (String verificationId, int? forceResendingToken) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => VerifyOtp(
                phoneNumber: phoneNumber,
                verificationId: verificationId,
                email: '', // Add the email parameter if needed
                password: '', // Add the password parameter if needed
                typeUser: '', // Add typeUser if needed
                typeAccount: '', // Add typeAccount if needed
              ),
            ),
          );
        },
        codeAutoRetrievalTimeout: (String verificationId) {},
      );
    } catch (e) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text("Failed to send OTP: ${e.toString()}"),
          ),
        );
    }
  }
}

//
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_database/firebase_database.dart';
// import 'package:flutter/material.dart';
//
// import '../screen/main_screen.dart';
// import '../screen/personal_info_screen.dart';
// import '../screen/verification_screen.dart';
//
// class AuthMethods {
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   final DatabaseReference _ref =
//       FirebaseDatabase.instance.ref("App").child("User");
//
//   Future<String> loginUser({
//     required String email,
//     required String password,
//     required BuildContext context,
//   }) async {
//     String res = 'Some error occurred!';
//     try {
//       if (email.isNotEmpty || password.isNotEmpty) {
//         await _auth.signInWithEmailAndPassword(
//             email: email, password: password);
//         res = 'success';
//         // Navigate directly to the main screen
//         Navigator.of(context).pushAndRemoveUntil(
//           MaterialPageRoute(builder: (context) => MainScreen()),
//           (Route<dynamic> route) => false,
//         );
//       } else {
//         res = 'Please enter all the fields';
//       }
//     } on FirebaseAuthException catch (e) {
//       if (e.code == 'wrong-password') {
//         res = 'You entered a wrong password';
//       } else if (e.code == 'user-not-found') {
//         res = 'User is not found';
//       } else {
//         res = 'Log-in Successful';
//       }
//     } catch (e) {
//       res = e.toString();
//     }
//     return res;
//   }
//
//   Future<void> sendOtp(BuildContext context, String phoneNumber, String email,
//       String password, String typeUser, String typeAccount) async {
//     try {
//       await _auth.verifyPhoneNumber(
//         phoneNumber: phoneNumber,
//         verificationCompleted: (PhoneAuthCredential phoneAuthCredential) async {
//           await _auth.currentUser?.linkWithCredential(phoneAuthCredential);
//           if (!context.mounted) return;
//           print("Type user again is $typeUser");
//           print("Type account again is $typeAccount");
//           Navigator.of(context).pushAndRemoveUntil(
//             MaterialPageRoute(
//               builder: (context) => PersonalInfoScreen(
//                 email: email,
//                 phoneNumber: phoneNumber,
//                 password: password,
//                 typeUser: typeUser,
//                 typeAccount: typeAccount,
//               ),
//             ),
//             (Route<dynamic> route) => false,
//           );
//         },
//         verificationFailed: (FirebaseAuthException error) {
//           ScaffoldMessenger.of(context)
//             ..hideCurrentSnackBar()
//             ..showSnackBar(
//               SnackBar(
//                 content: Text(error.message ??
//                     "Something went wrong while verifying phone number"),
//               ),
//             );
//         },
//         codeSent: (String verificationId, int? forceResendingToken) {
//           Navigator.of(context).push(
//             MaterialPageRoute(
//               builder: (context) => VerifyOtp(
//                 phoneNumber: phoneNumber,
//                 verificationId: verificationId,
//                 email: email,
//                 password: password,
//                 typeUser: typeUser,
//                 typeAccount: typeAccount,
//               ),
//             ),
//           );
//         },
//         codeAutoRetrievalTimeout: (String verificationId) {},
//       );
//     } on FirebaseAuthException catch (e) {
//       ScaffoldMessenger.of(context)
//         ..hideCurrentSnackBar()
//         ..showSnackBar(
//           SnackBar(
//             content: Text(e.message ??
//                 "Something went wrong while verifying phone number"),
//           ),
//         );
//     } catch (e) {
//       print(e);
//     }
//   }
//
//   Future<void> registerWithEmailAndPassword(
//     BuildContext context,
//     String email,
//     String password,
//     String phoneNumber,
//     String? typeUser,
//     String? typeAccount,
//   ) async {
//     try {
//       UserCredential userCredential =
//           await _auth.createUserWithEmailAndPassword(
//         email: email,
//         password: password,
//       );
//       if (userCredential.user != null) {
//         print("Type user : $typeUser");
//         print("Type Account: $typeAccount");
//         sendOtp(context, phoneNumber, email, password, typeUser!, typeAccount!);
//       }
//     } on FirebaseAuthException catch (e) {
//       ScaffoldMessenger.of(context)
//         ..hideCurrentSnackBar()
//         ..showSnackBar(
//           SnackBar(
//             content:
//                 Text(e.message ?? "Something went wrong while registering"),
//           ),
//         );
//     }
//   }
//
//   Future<void> verifyOtp(
//       BuildContext context,
//       String verificationId,
//       String smsCode,
//       String email,
//       String phoneNumber,
//       String password,
//       String typeUser,
//       String typeAccount) async {
//     try {
//       final credential = PhoneAuthProvider.credential(
//         verificationId: verificationId,
//         smsCode: smsCode,
//       );
//       await _auth.currentUser?.linkWithCredential(credential);
//       if (!context.mounted) return;
//
//       Navigator.of(context).pushAndRemoveUntil(
//         MaterialPageRoute(
//           builder: (context) => PersonalInfoScreen(
//             email: email,
//             phoneNumber: phoneNumber,
//             password: password,
//             typeUser: typeUser,
//             typeAccount: typeAccount,
//           ),
//         ),
//         (Route<dynamic> route) => false,
//       );
//     } on FirebaseAuthException catch (e) {
//       ScaffoldMessenger.of(context)
//         ..hideCurrentSnackBar()
//         ..showSnackBar(
//           SnackBar(
//             content: Text(e.message ??
//                 "Something went wrong while verifying phone number"),
//           ),
//         );
//     } catch (e) {
//       print(e);
//     }
//   }
//
//   Future<void> sendOtpForLogin(BuildContext context, String phoneNumber) async {
//     try {
//       await _auth.verifyPhoneNumber(
//         phoneNumber: phoneNumber,
//         verificationCompleted: (PhoneAuthCredential phoneAuthCredential) async {
//           await _auth.signInWithCredential(phoneAuthCredential);
//           if (!context.mounted) return;
//           // Navigate directly to the main screen
//           Navigator.of(context).pushAndRemoveUntil(
//             MaterialPageRoute(builder: (context) => MainScreen()),
//             (Route<dynamic> route) => false,
//           );
//         },
//         verificationFailed: (FirebaseAuthException error) {
//           ScaffoldMessenger.of(context)
//             ..hideCurrentSnackBar()
//             ..showSnackBar(
//               SnackBar(
//                 content: Text(error.message ??
//                     "Something went wrong while verifying phone number"),
//               ),
//             );
//         },
//         codeSent: (String verificationId, int? forceResendingToken) {
//           Navigator.of(context).push(
//             MaterialPageRoute(
//               builder: (context) => VerifyOtp(
//                 phoneNumber: phoneNumber,
//                 verificationId: verificationId,
//                 email: '', // Add the email parameter if needed
//                 password: '', // Add the password parameter if needed
//                 typeUser: '', // Add typeUser if needed
//                 typeAccount: '', // Add typeAccount if needed
//               ),
//             ),
//           );
//         },
//         codeAutoRetrievalTimeout: (String verificationId) {},
//       );
//     } catch (e) {
//       ScaffoldMessenger.of(context)
//         ..hideCurrentSnackBar()
//         ..showSnackBar(
//           SnackBar(
//             content: Text("Failed to send OTP: ${e.toString()}"),
//           ),
//         );
//     }
//   }
// }
