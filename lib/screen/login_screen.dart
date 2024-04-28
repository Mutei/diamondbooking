// ignore_for_file: non_constant_identifier_names, prefer_const_constructors, unnecessary_new

import 'dart:io';

import 'package:diamond_booking/constants/colors.dart';
import 'package:diamond_booking/screen/type_account_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';
import '../general_provider.dart';
import '../localization/language_constants.dart';
import '../textFormField/text_form_style.dart';
import 'main_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, required String title});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  bool validateEmail = true;
  bool validatePassword = true;
  bool check = false;
  void initState() {
    getDataFromFirebase();
    super.initState();
  }

  Map<dynamic, dynamic> dataList = new Map<dynamic, dynamic>();
  getDataFromFirebase() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    String? id = FirebaseAuth.instance.currentUser?.uid;
    try {
      DatabaseReference starCountRef =
          FirebaseDatabase.instance.ref("App").child("User");
      starCountRef.onValue.listen((event) {
        DataSnapshot snapshot = event.snapshot;
        if (snapshot.value != null) {
          dataList = snapshot.value as Map;
          print('This is the datalist: $dataList');
        }
      });
    } catch (e) {}
  }

  Widget btnLoginx = Text("Login");
  @override
  Widget build(BuildContext context) {
    final objProvider = Provider.of<GeneralProvider>(context, listen: true);
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/images/logo.png',
                  width: 150,
                ),
                TextFormFieldStyle(
                  context: context,
                  hint: "Email or Phone Ex:+974...",
                  icon: Icon(
                    Icons.person,
                    color: kPrimaryColor,
                  ),
                  control: usernameController,
                  isObsecured: false,
                  validate: validateEmail,
                  textInputType: TextInputType.emailAddress,
                  showVisibilityToggle: false,
                ),
                TextFormFieldStyle(
                  context: context,
                  hint: "Password",
                  icon: Icon(
                    Icons.lock,
                    color: kPrimaryColor,
                  ),
                  control: passwordController,
                  isObsecured: true,
                  validate: validatePassword,
                  textInputType: TextInputType.text,
                  showVisibilityToggle: true,
                ),
                const SizedBox(
                  height: 10,
                ),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  child: ElevatedButton(
                    onPressed: () async {
                      if (usernameController.text.isEmpty) {
                        objProvider.FunSnackBarPage(
                            'Email Can\'t Be Empty', context);
                      } else if (passwordController.text.isEmpty) {
                        objProvider.FunSnackBarPage(
                            'Password Can\'t Be Empty', context);
                      } else {
                        setState(() {
                          btnLoginx = Center(
                            child: SizedBox(
                              child: CircularProgressIndicator(
                                color: Colors.white,
                              ),
                            ),
                          );
                        });
                        SharedPreferences sharedPreferences =
                            await SharedPreferences.getInstance();

                        if (!usernameController.text.contains("@")) {
                          int x = 0;
                          dataList.forEach((key, value) {
                            x++;
                            if (value['Phone'] == usernameController.text &&
                                value['Password'] == passwordController.text) {
                              sharedPreferences.setString("ID", value['ID']);
                              if (check) {
                                sharedPreferences.setString("auto", "1");
                              }
                              Navigator.of(context).pushAndRemoveUntil(
                                MaterialPageRoute(
                                    builder: (context) => MainScreen()),
                                (Route<dynamic> route) => false,
                              );
                            } else {
                              setState(() {
                                btnLoginx = Text("Login");
                                if (dataList.length <= x) {
                                  objProvider.FunSnackBarPage(
                                      "user-not-found", context);
                                }
                              });
                            }
                          });
                        } else {
                          try {
                            final credential = await FirebaseAuth.instance
                                .signInWithEmailAndPassword(
                                    email: usernameController.text,
                                    password: passwordController.text);
                            String? id = FirebaseAuth.instance.currentUser?.uid;
                            sharedPreferences.setString("ID", id!);
                            if (check) {
                              sharedPreferences.setString("auto", "1");
                            }
                            Navigator.of(context).pushAndRemoveUntil(
                              MaterialPageRoute(
                                  builder: (context) => MainScreen()),
                              (Route<dynamic> route) => false,
                            );
                          } on FirebaseAuthException catch (e) {
                            if (e.code == 'user-not-found') {
                              btnLoginx = Text("Login");
                              setState(() {
                                objProvider.FunSnackBarPage(
                                    "user-not-found", context);
                              });
                            } else if (e.code == 'wrong-password') {
                              setState(() {
                                btnLoginx = Text("Login");
                              });
                              // ignore: use_build_context_synchronously
                              objProvider.FunSnackBarPage(
                                  "wrong-password", context);
                            }
                          }
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 36),
                      backgroundColor: kPrimaryColor,
                      // Ensuring the button is full-width and height matches the design
                    ),
                    child: Text(
                      getTranslated(context, 'Login'),
                      style: TextStyle(
                        color: kTypeUserTextColor,
                      ),
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      getTranslated(context, 'Remember me'),
                    ),
                    Checkbox(
                      checkColor: Colors.white, // color of the tick
                      fillColor: MaterialStateProperty.resolveWith<Color>(
                          (Set<MaterialState> states) {
                        if (states.contains(MaterialState.selected)) {
                          return kPrimaryColor; // background color when checked
                        }
                        return Colors.white; // background color when unchecked
                      }),
                      value: check,
                      onChanged: (bool? value) {
                        setState(() {
                          check = value!;
                        });
                      },
                    ),
                  ],
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    SizedBox(
                        height:
                            10), // Add some space before the first button if necessary
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => TypeAccount()));
                      },
                      child: Text(
                        getTranslated(context, 'Sign In'),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: kSecondaryColor,
                        ),
                      ),
                    ),
                    // Spacing between buttons
                    TextButton(
                      onPressed: () {},
                      child: Text(
                        getTranslated(context, 'Login as Guest'),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: kSecondaryColor,
                        ),
                      ),
                    ),
                    // Spacing between buttons
                    TextButton(
                      onPressed: () {},
                      child: Text(
                        getTranslated(context, 'Forgot password'),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: kSecondaryColor,
                        ),
                      ),
                    ),
                    // Add some space after the last button if necessary
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
