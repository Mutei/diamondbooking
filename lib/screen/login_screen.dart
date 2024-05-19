// import 'dart:io';
//
// import 'package:diamond_booking/constants/colors.dart';
// import 'package:diamond_booking/screen/forgot_password.dart';
// import 'package:diamond_booking/screen/sign_in_screen.dart';
// import 'package:diamond_booking/screen/type_account_screen.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_database/firebase_database.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:sizer/sizer.dart';
// import '../general_provider.dart';
// import '../localization/language_constants.dart';
// import '../main.dart';
// import '../widgets/language_selector.dart';
// import '../widgets/text_form_style.dart';
// import 'main_screen.dart';
//
// class LoginScreen extends StatefulWidget {
//   final String? userType;
//   const LoginScreen({
//     super.key,
//     required String title,
//     this.userType,
//   });
//
//   @override
//   State<LoginScreen> createState() => _LoginScreenState();
// }
//
// class _LoginScreenState extends State<LoginScreen> {
//   TextEditingController usernameController = TextEditingController();
//   TextEditingController passwordController = TextEditingController();
//   bool validateEmail = true;
//   bool validatePassword = true;
//   bool check = false;
//   bool isLoading = false;
//   late String userType = '';
//   String _selectedLanguage = 'en';
//
//   void initState() {
//     getDataFromFirebase();
//     super.initState();
//     userType = widget.userType ?? '';
//   }
//
//   Map<dynamic, dynamic> dataList = new Map<dynamic, dynamic>();
//   getDataFromFirebase() async {
//     SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
//     String? id = FirebaseAuth.instance.currentUser?.uid;
//     try {
//       DatabaseReference starCountRef =
//           FirebaseDatabase.instance.ref("App").child("User");
//       starCountRef.onValue.listen((event) {
//         DataSnapshot snapshot = event.snapshot;
//         if (snapshot.value != null) {
//           dataList = snapshot.value as Map;
//           print('This is the datalist: $dataList');
//         }
//       });
//     } catch (e) {}
//   }
//
//   Widget btnLoginx = Text("Login");
//   @override
//   Widget build(BuildContext context) {
//     final objProvider = Provider.of<GeneralProvider>(context, listen: true);
//     return Scaffold(
//       // appBar: AppBar(
//       //   actions: [
//       //     LanguageSelector(
//       //       selectedLanguage: _selectedLanguage,
//       //       onLanguageChanged: _changeLanguage,
//       //     ),
//       //   ],
//       // ),
//       body: SafeArea(
//         child: Center(
//           child: SingleChildScrollView(
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Image.asset(
//                   'assets/images/logo.png',
//                   width: 150,
//                 ),
//                 TextFormFieldStyle(
//                   context: context,
//                   hint: "Email or Phone Ex:+974...",
//                   icon: Icon(
//                     Icons.person,
//                     color: kPrimaryColor,
//                   ),
//                   control: usernameController,
//                   isObsecured: false,
//                   validate: validateEmail,
//                   textInputType: TextInputType.emailAddress,
//                   showVisibilityToggle: false,
//                 ),
//                 TextFormFieldStyle(
//                   context: context,
//                   hint: "Password",
//                   icon: Icon(
//                     Icons.lock,
//                     color: kPrimaryColor,
//                   ),
//                   control: passwordController,
//                   isObsecured: true,
//                   validate: validatePassword,
//                   textInputType: TextInputType.text,
//                   showVisibilityToggle: true,
//                 ),
//                 const SizedBox(
//                   height: 10,
//                 ),
//                 Container(
//                   margin: const EdgeInsets.symmetric(horizontal: 20),
//                   child: ElevatedButton(
//                     onPressed: () async {
//                       print(userType);
//                       SharedPreferences sharedPreferences =
//                           await SharedPreferences.getInstance();
//                       String? selectedType =
//                           sharedPreferences.getString("TypeUser");
//                       if (selectedType != null && selectedType != userType) {
//                         // Display error message or prevent login
//                         // For example, you can show a Snackbar or AlertDialog indicating the mismatch
//                         objProvider.FunSnackBarPage(
//                             "You can't login with this account type", context);
//                         return; // Exit the login process
//                       }
//                       if (usernameController.text.isEmpty) {
//                         objProvider.FunSnackBarPage(
//                             'Email Can\'t Be Empty', context);
//                       } else if (passwordController.text.isEmpty) {
//                         objProvider.FunSnackBarPage(
//                             'Password Can\'t Be Empty', context);
//                       } else {
//                         setState(() {
//                           btnLoginx = Center(
//                             child: SizedBox(
//                               child: CircularProgressIndicator(
//                                 color: Colors.white,
//                               ),
//                             ),
//                           );
//                         });
//                         SharedPreferences sharedPreferences =
//                             await SharedPreferences.getInstance();
//
//                         if (!usernameController.text.contains("@")) {
//                           int x = 0;
//                           dataList.forEach((key, value) {
//                             x++;
//                             if (value['Phone'] == usernameController.text &&
//                                 value['Password'] == passwordController.text) {
//                               sharedPreferences.setString("ID", value['ID']);
//                               if (check) {
//                                 sharedPreferences.setString("auto", "1");
//                               }
//                               Navigator.of(context).pushAndRemoveUntil(
//                                 MaterialPageRoute(
//                                     builder: (context) => MainScreen()),
//                                 (Route<dynamic> route) => false,
//                               );
//                             } else {
//                               setState(() {
//                                 btnLoginx = Text("Login");
//                                 if (dataList.length <= x) {
//                                   objProvider.FunSnackBarPage(
//                                       "user-not-found", context);
//                                 }
//                               });
//                             }
//                           });
//                         } else {
//                           try {
//                             final credential = await FirebaseAuth.instance
//                                 .signInWithEmailAndPassword(
//                                     email: usernameController.text,
//                                     password: passwordController.text);
//                             String? id = FirebaseAuth.instance.currentUser?.uid;
//                             sharedPreferences.setString("ID", id!);
//                             if (check) {
//                               sharedPreferences.setString("auto", "1");
//                             }
//                             Navigator.of(context).pushAndRemoveUntil(
//                               MaterialPageRoute(
//                                   builder: (context) => MainScreen()),
//                               (Route<dynamic> route) => false,
//                             );
//                           } on FirebaseAuthException catch (e) {
//                             if (e.code == 'user-not-found') {
//                               btnLoginx = Text("Login");
//                               setState(() {
//                                 objProvider.FunSnackBarPage(
//                                     "user-not-found", context);
//                               });
//                             } else if (e.code == 'wrong-password') {
//                               setState(() {
//                                 btnLoginx = Text("Login");
//                               });
//                               // ignore: use_build_context_synchronously
//                               objProvider.FunSnackBarPage(
//                                   "wrong-password", context);
//                             }
//                           }
//                         }
//                       }
//                     },
//                     style: ElevatedButton.styleFrom(
//                       minimumSize: const Size(double.infinity, 36),
//                       backgroundColor: kPrimaryColor,
//                       // Ensuring the button is full-width and height matches the design
//                     ),
//                     child: Text(
//                       getTranslated(context, 'Login'),
//                       style: TextStyle(
//                         color: kTypeUserTextColor,
//                       ),
//                     ),
//                   ),
//                 ),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Text(
//                       getTranslated(context, 'Remember me'),
//                     ),
//                     Checkbox(
//                       checkColor: Colors.white, // color of the tick
//                       fillColor: MaterialStateProperty.resolveWith<Color>(
//                           (Set<MaterialState> states) {
//                         if (states.contains(MaterialState.selected)) {
//                           return kPrimaryColor; // background color when checked
//                         }
//                         return Colors.white; // background color when unchecked
//                       }),
//                       value: check,
//                       onChanged: (bool? value) {
//                         setState(() {
//                           check = value!;
//                         });
//                       },
//                     ),
//                   ],
//                 ),
//                 Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: <Widget>[
//                     SizedBox(
//                         height:
//                             10), // Add some space before the first button if necessary
//                     TextButton(
//                       onPressed: () {
//                         Navigator.of(context).push(
//                           MaterialPageRoute(
//                             builder: (context) =>
//                                 SignInScreen(typeAccount: '1'),
//                           ),
//                         );
//                       },
//                       child: Text(
//                         getTranslated(context, 'Sign In'),
//                         textAlign: TextAlign.center,
//                         style: TextStyle(
//                           color: kSecondaryColor,
//                         ),
//                       ),
//                     ),
//                     // Spacing between buttons
//                     TextButton(
//                       onPressed: () {},
//                       child: Text(
//                         getTranslated(context, 'Login as Guest'),
//                         textAlign: TextAlign.center,
//                         style: TextStyle(
//                           color: kSecondaryColor,
//                         ),
//                       ),
//                     ),
//                     // Spacing between buttons
//                     TextButton(
//                       onPressed: () {
//                         Navigator.of(context).push(
//                           MaterialPageRoute(
//                             builder: (context) => ForgotPasswordScreen(),
//                           ),
//                         );
//                       },
//                       child: Text(
//                         getTranslated(context, 'Forgot password'),
//                         textAlign: TextAlign.center,
//                         style: TextStyle(
//                           color: kSecondaryColor,
//                         ),
//                       ),
//                     ),
//                     // Add some space after the last button if necessary
//                   ],
//                 )
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'package:diamond_booking/extension/sized_box_extension.dart';
import 'package:diamond_booking/localization/language_constants.dart';
import 'package:diamond_booking/screen/sign_in_screen.dart';
import 'package:flutter/material.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import '../constants/colors.dart';
import '../resources/auth_methods.dart';
import '../widgets/reused_elevated_button.dart';
import '../widgets/sign_in_info_text_form_field.dart';

class LoginScreen extends StatefulWidget {
  final String? userType;
  const LoginScreen({super.key, required String title, this.userType});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool enableOtpBtn = false;
  String phoneNumber = '';
  late String userType = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    userType = widget.userType ?? '';
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  void loginWithEmail() {
    if (_formKey.currentState!.validate()) {
      AuthMethods().loginUser(
        email: _emailController.text,
        password: _passwordController.text,
        context: context,
      );
    }
  }

  void getOtp() {
    if (phoneNumber.isNotEmpty) {
      AuthMethods().sendOtpForLogin(context, phoneNumber);
    } else {
      print("Phone Number is empty");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          getTranslated(
            context,
            'Login',
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(
              text: getTranslated(
                context,
                'Email & Password',
              ),
            ),
            Tab(
              text: getTranslated(
                context,
                'Phone Number',
              ),
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Email & Password Tab
          Padding(
            padding: const EdgeInsets.all(14.0),
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    SignInInfoTextFormField(
                      controller: _emailController,
                      labelText: getTranslated(
                        context,
                        "Email",
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your email';
                        } else if (!RegExp(r'^[^@]+@[^@]+\.[^@]+')
                            .hasMatch(value)) {
                          return 'Please enter a valid email address';
                        }
                        return null;
                      },
                    ),
                    20.kH,
                    SignInInfoTextFormField(
                      controller: _passwordController,
                      obscureText: true,
                      labelText: getTranslated(
                        context,
                        "Password",
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your password';
                        } else if (value.length < 6) {
                          return 'Password must be at least 6 characters long';
                        }
                        return null;
                      },
                    ),
                    20.kH,
                    ReusedElevatedButton(
                      text: getTranslated(
                        context,
                        'Login',
                      ),
                      onPressed: loginWithEmail,
                      icon: Icons.email,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          getTranslated(
                            context,
                            "Are you new here?",
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => SignInScreen(
                                  typeAccount: '1',
                                ),
                              ),
                            );
                          },
                          child: Text(
                            getTranslated(
                              context,
                              "Sign Up",
                            ),
                            style: TextStyle(
                              color: kTextButtonColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Phone Number Tab
          Padding(
            padding: const EdgeInsets.all(14.0),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  InternationalPhoneNumberInput(
                    onInputChanged: (PhoneNumber number) {
                      setState(() {
                        phoneNumber = number.phoneNumber!;
                      });
                    },
                    onInputValidated: (bool value) {
                      setState(() {
                        enableOtpBtn = value;
                      });
                    },
                    autoFocus: true,
                    selectorConfig: const SelectorConfig(
                      selectorType: PhoneInputSelectorType.BOTTOM_SHEET,
                    ),
                    inputDecoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: getTranslated(
                        context,
                        'Phone Number',
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12,
                      ),
                    ),
                    formatInput: true,
                    ignoreBlank: false,
                    autoValidateMode: AutovalidateMode.disabled,
                    selectorTextStyle: const TextStyle(color: Colors.black),
                  ),
                  20.kH,
                  ReusedElevatedButton(
                    text: getTranslated(
                      context,
                      'Send Otp',
                    ),
                    onPressed: enableOtpBtn ? getOtp : null,
                    icon: Icons.phone,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
