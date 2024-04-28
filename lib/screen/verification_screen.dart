// ignore_for_file: non_constant_identifier_names

import 'package:diamond_booking/constants/colors.dart';
import 'package:diamond_booking/constants/styles.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';
import '../general_provider.dart';
import '../localization/language_constants.dart';

import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';

import '../resources/auth_methods.dart';
import 'main_screen.dart';

class VerificationPhone extends StatefulWidget {
  String verificationId;
  String phone;
  String CountryCodePhone;
  VerificationPhone({
    super.key,
    required this.verificationId,
    required this.phone,
    required this.CountryCodePhone,
  });
  @override
  _State createState() => new _State(verificationId, phone, CountryCodePhone);
}

DatabaseReference ref = FirebaseDatabase.instance.ref("App").child("User");

class _State extends State<VerificationPhone> {
  String verificationId;
  String phone;
  String CountryCodePhone;

  _State(this.verificationId, this.phone, this.CountryCodePhone);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance
        .addPostFrameCallback((_) => afterLayoutWidgetBuild());
  }

  void afterLayoutWidgetBuild() async {
    await _verifyPhoneNumber(CountryCodePhone + phone);
  }

  // Future<void> _verifyPhoneNumber(String phoneNumber,
  //     {bool resend = false}) async {
  //   FirebaseAuth.instance.verifyPhoneNumber(
  //     phoneNumber: phoneNumber,
  //     verificationCompleted: (PhoneAuthCredential credential) async {
  //       // Optionally, handle auto-sign-in or link the credentials
  //     },
  //     verificationFailed: (FirebaseAuthException e) {
  //       if (e.code == 'invalid-phone-number') {
  //         print('The provided phone number is not valid.');
  //       }
  //     },
  //     codeSent: (String newVerificationId, int? resendToken) {
  //       // Update the state with the new verification ID if needed
  //       setState(() {
  //         verificationId = newVerificationId;
  //       });
  //     },
  //     codeAutoRetrievalTimeout: (String newVerificationId) {
  //       // Update the state with the new verification ID if needed
  //       verificationId = newVerificationId;
  //     },
  //     forceResendingToken: resend
  //         ? resendToken
  //         : null, // Use the resend token if this is a resend
  //   );
  // }

  Future<void> _verifyPhoneNumber(String phoneNumber) async {
    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: (PhoneAuthCredential credential) async {
        // Auto-retrieval of the verification code.
        //    await FirebaseAuth.instance.signInWithCredential(credential);
      },
      verificationFailed: (FirebaseAuthException e) {
        if (e.code == 'invalid-phone-number') {
          print('The provided phone number is not valid.');
        }
      },
      codeSent: (String verificationId, int? resendToken) {
        // Save the verification ID so that we can use it later.
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        // Auto-retrieval timed out, handle the error...
        //this.verificationId = verificationId;
        verificationId = verificationId;
      },
    );
  }

  Widget build(BuildContext context) {
    final objProvider = Provider.of<GeneralProvider>(context, listen: false);
    objProvider.CheckLang();
    return SafeArea(
      child: Scaffold(
          resizeToAvoidBottomInset: true,
          body: Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            child: SingleChildScrollView(
                child: Column(
              children: [
                Container(
                  width: MediaQuery.of(context).size.width,
                  margin: const EdgeInsets.only(
                      top: 150, bottom: 20, left: 50, right: 55),
                  padding: const EdgeInsets.only(left: 45),
                  child: RichText(
                    // ignore: prefer_const_constructors
                    text: TextSpan(
                      text: getTranslated(context, 'Please Enter the '),
                      style: kGoogleFontsStyle,
                      // ignore: prefer_const_literals_to_create_immutables
                      children: <TextSpan>[
                        TextSpan(
                          text: getTranslated(context, 'Verification '),
                          style: kPrimaryTypeStyle,
                        ),
                        TextSpan(
                          text:
                              "${getTranslated(context, 'Code ')}\n$CountryCodePhone$phone",
                          // ignore: unnecessary_const
                          style: kGoogleFontsStyle,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: Container(
                        child: OtpTextField(
                          numberOfFields: 6,
                          borderColor: kPrimaryColor,
                          autoFocus: true,
                          //set to true to show as box or false to show as dash
                          showFieldAsBox: true,

                          //runs when a code is typed in
                          onCodeChanged: (String code) {
                            //handle validation or checks here
                          },

                          //runs when every textfield is filled
// In VerificationPhone, update the onSubmit method in OtpTextField:

                          // onSubmit: (String verificationCode) async {
                          //   SharedPreferences sharedPreferences =
                          //       await SharedPreferences.getInstance();
                          //   _showMyDialog(); // Show progress dialog
                          //   PhoneAuthCredential credential =
                          //       PhoneAuthProvider.credential(
                          //           verificationId: verificationId,
                          //           smsCode: verificationCode);
                          //
                          //   try {
                          //     AuthMethods authMethods = AuthMethods();
                          //
                          //     await FirebaseAuth.instance
                          //         .signInWithCredential(credential)
                          //         .whenComplete(() async {
                          //       String email =
                          //           sharedPreferences.getString("Email") ??
                          //               ""; // Ensure these are set beforehand
                          //       String password =
                          //           sharedPreferences.getString("Pass") ?? "";
                          //
                          //       authMethods.createUserWithEmailAndPassword(
                          //           email: email,
                          //           password: password,
                          //           context: context,
                          //           onSuccess: () async {
                          //             String? id =
                          //                 sharedPreferences.getString("ID");
                          //             String? token = await FirebaseMessaging
                          //                 .instance
                          //                 .getToken();
                          //             sharedPreferences.setString(
                          //                 "Token", token!);
                          //
                          //             String fullPhoneNumber =
                          //                 CountryCodePhone + phone;
                          //             await ref.child(id!).set({
                          //               "City": sharedPreferences
                          //                   .getString("cityValue"),
                          //               "Country": sharedPreferences
                          //                   .getString("countryValue"),
                          //               "State": sharedPreferences
                          //                   .getString("stateValue"),
                          //               "Date":
                          //                   sharedPreferences.getString("Date"),
                          //               "Email": email,
                          //               "Name":
                          //                   sharedPreferences.getString("Name"),
                          //               "Phone": fullPhoneNumber,
                          //               "TypeUser": sharedPreferences
                          //                   .getString("TypeUser"),
                          //               "TypeAccount": sharedPreferences
                          //                   .getString("TypeAccount"),
                          //               "Password": password,
                          //               "Token": token,
                          //               "ID": id
                          //             });
                          //             Navigator.of(context)
                          //                 .pop(); // Close progress dialog
                          //             Navigator.of(context).pushAndRemoveUntil(
                          //               MaterialPageRoute(
                          //                   builder: (context) => MainScreen()),
                          //               (Route<dynamic> route) => false,
                          //             );
                          //           },
                          //           onError: (String errorMessage) {
                          //             Navigator.of(context)
                          //                 .pop(); // Close progress dialog
                          //             ScaffoldMessenger.of(context)
                          //                 .showSnackBar(SnackBar(
                          //                     content: Text(errorMessage)));
                          //           });
                          //     });
                          //   } catch (e) {
                          //     Navigator.of(context)
                          //         .pop(); // Ensure dialog is closed on error
                          //     print(e);
                          //   }
                          // },

                          onSubmit: (String verificationCode) async {
                            SharedPreferences sharedPreferences =
                                await SharedPreferences.getInstance();

                            _showMyDialog();
                            PhoneAuthCredential credential =
                                PhoneAuthProvider.credential(
                                    verificationId: verificationId,
                                    smsCode: verificationCode);

                            try {
                              await FirebaseAuth.instance
                                  .signInWithCredential(credential)
                                  .whenComplete(() async {
                                String? id = sharedPreferences.getString("ID");
                                String? token =
                                    await FirebaseMessaging.instance.getToken();
                                sharedPreferences.setString("Token", token!);

                                // Concatenate country code with phone number before saving
                                String fullPhoneNumber =
                                    CountryCodePhone + phone;

                                await ref.child(id!).set({
                                  "City":
                                      sharedPreferences.getString("cityValue"),
                                  "Country": sharedPreferences
                                      .getString("countryValue"),
                                  "State":
                                      sharedPreferences.getString("stateValue"),
                                  "Date": sharedPreferences.getString("Date"),
                                  "Email": sharedPreferences.getString("Email"),
                                  "Name": sharedPreferences.getString("Name"),
                                  "Phone":
                                      fullPhoneNumber, // Save full phone number with country code
                                  "TypeUser":
                                      sharedPreferences.getString("TypeUser"),
                                  "TypeAccount": sharedPreferences
                                      .getString("TypeAccount"),
                                  "Password":
                                      sharedPreferences.getString("Pass"),
                                  "Token": token,
                                  "ID": id
                                });
                                Navigator.of(context).pop();
                                Navigator.of(context).pushAndRemoveUntil(
                                  MaterialPageRoute(
                                      builder: (context) => MainScreen()),
                                  (Route<dynamic> route) => false,
                                );
                              });
                            } catch (e) {
                              print(e);
                            }
                          },

                          // onSubmit: (String verificationCode) async {
                          //   SharedPreferences sharedPreferences =
                          //       await SharedPreferences.getInstance();
                          //
                          //   _showMyDialog();
                          //   PhoneAuthCredential credential =
                          //       PhoneAuthProvider.credential(
                          //           verificationId: verificationId,
                          //           smsCode: verificationCode);
                          //
                          //   ///    print('verificationId is $verificationId');
                          //
                          //   try {
                          //     await FirebaseAuth.instance
                          //         .signInWithCredential(credential)
                          //         .whenComplete(() async {
                          //       String? id = sharedPreferences.getString("ID");
                          //       String? Token =
                          //           await FirebaseMessaging.instance.getToken();
                          //       sharedPreferences.setString("Token", Token!);
                          //
                          //       await ref.child(id!).set({
                          //         "City":
                          //             sharedPreferences.getString("cityValue"),
                          //         "Country":
                          //             sharedPreferences.getString("countryValue"),
                          //         "State":
                          //             sharedPreferences.getString("stateValue"),
                          //         "Date": sharedPreferences.getString("Date"),
                          //         "Email": sharedPreferences.getString("Email"),
                          //         "Name": sharedPreferences.getString("Name"),
                          //         "Phone": phone,
                          //         "TypeUser":
                          //             sharedPreferences.getString("TypeUser"),
                          //         "TypeAccount":
                          //             sharedPreferences.getString("TypeAccount"),
                          //         "Password": sharedPreferences.getString("Pass"),
                          //         "Token": Token,
                          //         "ID": id
                          //       });
                          //       Navigator.of(context).pop();
                          //       Navigator.of(context).pushAndRemoveUntil(
                          //         MaterialPageRoute(
                          //             builder: (context) => MainScreen()),
                          //         (Route<dynamic> route) => false,
                          //       );
                          //     });
                          //   } catch (e) {
                          //     print(e);
                          //   }
                          // }, // end onSubmit
                        ),
                      ),
                    )
                  ],
                ),
                const SizedBox(
                  height: 20,
                ),
                TextButton(
                  onPressed: () {},
                  child: Container(
                    margin: const EdgeInsets.only(
                        top: 15, bottom: 20, left: 60, right: 70),
                    // ignore: prefer_const_constructors
                    child: Text(
                      getTranslated(context, 'Resend Verification Code'),
                      // ignore: prefer_const_constructors
                      style: GoogleFonts.laila(
                          fontSize: 15,
                          color: Colors.blue,
                          decoration: TextDecoration.underline,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            )),
          )),
    );
  }

  Future<void> _showMyDialog() async {
    return showDialog<void>(
      context: context,

      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        // ignore: prefer_const_constructors
        return AlertDialog(
            // ignore: prefer_const_constructors
            content: SizedBox(
          // ignore: sort_child_properties_last
          child: const Center(
            child: CircularProgressIndicator(),
          ),
          height: 150,
        ));
      },
    );
  }
}
