import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';

import '../constants/colors.dart';
import '../general_provider.dart';
import '../localization/language_constants.dart';
import 'main_screen.dart';

class VerificationPhone extends StatefulWidget {
  final String verificationId;
  final String phone;
  final String countryCodePhone;

  VerificationPhone({
    required this.verificationId,
    required this.phone,
    required this.countryCodePhone,
  });

  @override
  _VerificationPhoneState createState() => _VerificationPhoneState();
}

class _VerificationPhoneState extends State<VerificationPhone> {
  late String verificationCode;
  DatabaseReference ref = FirebaseDatabase.instance.ref("App").child("User");

  @override
  void initState() {
    super.initState();
    _verifyPhoneNumber(widget.countryCodePhone + widget.phone);
  }

  Future<void> _verifyPhoneNumber(String phoneNumber) async {
    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: (PhoneAuthCredential credential) async {
        await FirebaseAuth.instance.signInWithCredential(credential);
      },
      verificationFailed: (FirebaseAuthException e) {
        print('Failed to verify phone number: ${e.message}');
      },
      codeSent: (String verificationId, int? resendToken) {
        setState(() {
          verificationCode = verificationId;
        });
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        setState(() {
          verificationCode = verificationId;
        });
      },
    );
  }

  @override
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
                    text: TextSpan(
                      text: getTranslated(context, 'Please Enter the '),
                      style: TextStyle(fontSize: 20.sp, color: Colors.black),
                      children: <TextSpan>[
                        TextSpan(
                          text: getTranslated(context, 'Verification '),
                          style: TextStyle(
                              fontSize: 20.sp,
                              color: Colors.black,
                              fontWeight: FontWeight.bold),
                        ),
                        TextSpan(
                          text:
                              "${getTranslated(context, 'Code ')}\n${widget.countryCodePhone}${widget.phone}",
                          style:
                              TextStyle(fontSize: 20.sp, color: Colors.black),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: Container(
                        child: OtpTextField(
                          numberOfFields: 6,
                          borderColor: kPrimaryColor,
                          autoFocus: true,
                          showFieldAsBox: true,
                          onCodeChanged: (String code) {},
                          onSubmit: (String verificationCode) async {
                            SharedPreferences sharedPreferences =
                                await SharedPreferences.getInstance();

                            _showMyDialog();
                            PhoneAuthCredential credential =
                                PhoneAuthProvider.credential(
                                    verificationId: verificationCode,
                                    smsCode: verificationCode);

                            try {
                              await FirebaseAuth.instance
                                  .signInWithCredential(credential)
                                  .whenComplete(() async {
                                String? id = sharedPreferences.getString("ID");
                                String? token =
                                    await FirebaseMessaging.instance.getToken();
                                sharedPreferences.setString("Token", token!);

                                String fullPhoneNumber =
                                    widget.countryCodePhone + widget.phone;

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
                                  "Phone": fullPhoneNumber,
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
                        ),
                      ),
                    )
                  ],
                ),
                const SizedBox(height: 20),
                TextButton(
                  onPressed: () {},
                  child: Container(
                    margin: const EdgeInsets.only(
                        top: 15, bottom: 20, left: 60, right: 70),
                    child: Text(
                      getTranslated(context, 'Resend Verification Code'),
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.blue,
                        decoration: TextDecoration.underline,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
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
