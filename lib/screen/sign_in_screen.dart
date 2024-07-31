import 'package:diamond_booking/extension/sized_box_extension.dart';
import 'package:flutter/material.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/colors.dart';
import '../resources/auth_methods.dart';
import '../widgets/reused_elevated_button.dart';
import '../widgets/sign_in_info_text_form_field.dart';
import 'login_screen.dart';

class SignInScreen extends StatefulWidget {
  String typeAccount;
  SignInScreen({
    super.key,
    required this.typeAccount,
  });

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool enableOtpBtn = false;
  String phoneNumber = '';
  String? get typeAccount => widget.typeAccount;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  getOtp() async {
    if (_formKey.currentState!.validate()) {
      SharedPreferences sharedPreferences =
          await SharedPreferences.getInstance();
      String? typeUser = sharedPreferences.getString('TypeUser');
      print("This is the typeUser $typeUser");
      AuthMethods().registerWithEmailAndPassword(
        context,
        _emailController.text,
        _passwordController.text,
        phoneNumber,
        typeUser, //TypeUser
        typeAccount, //TypeAccount
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Enter your phone number"),
        titleTextStyle: Theme.of(context).textTheme.headlineSmall!.copyWith(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(14.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "This Application requires you to enter your phone number for otp.",
                  ),
                  30.kH,
                  SignInInfoTextFormField(
                    controller: _emailController,
                    labelText: 'Email',
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
                    labelText: 'Password',
                    obscureText: true,
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
                  InternationalPhoneNumberInput(
                    onInputValidated: (value) {
                      setState(() {
                        enableOtpBtn = value;
                      });
                    },
                    onInputChanged: (value) {
                      setState(() {
                        phoneNumber = value.phoneNumber!;
                      });
                    },
                    formatInput: true,
                    autoFocus: true,
                    selectorConfig: const SelectorConfig(
                      useEmoji: false,
                      selectorType: PhoneInputSelectorType.BOTTOM_SHEET,
                    ),
                    initialValue: PhoneNumber(isoCode: 'SA'), // Add this line
                    inputDecoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12),
                    ),
                  ),
                  ReusedElevatedButton(
                    text: "Send OTP",
                    onPressed: enableOtpBtn ? getOtp : null,
                    icon: Icons.phone,
                  ),
                  20.kH,
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Already have an account?"),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const LoginScreen(
                                title: '',
                              ),
                            ),
                          );
                        },
                        child: const Text(
                          "Login",
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
      ),
    );
  }
}

// import 'package:country_code_picker/country_code_picker.dart';
// import 'package:csc_picker/csc_picker.dart';
// import 'package:diamond_booking/constants/colors.dart';
// import 'package:diamond_booking/constants/styles.dart';
// import 'package:diamond_booking/extension/sized_box_extension.dart';
// import 'package:diamond_booking/screen/login_screen.dart';
// import 'package:diamond_booking/screen/verification_screen.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_database/firebase_database.dart';
// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:provider/provider.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:sizer/sizer.dart';
// import '../chooseCity.dart';
// import '../general_provider.dart';
// import '../localization/language_constants.dart';
// import '../resources/auth_methods.dart';
// import '../widgets/text_form_style.dart';
// import 'main_screen.dart';
//
// class SignInScreen extends StatefulWidget {
//   String typeAccount;
//
//   SignInScreen({super.key, this.restorationId, required this.typeAccount});
//
//   final String? restorationId;
//
//   @override
//   State<SignInScreen> createState() => _SignInScreenState();
// }
//
// class _SignInScreenState extends State<SignInScreen> with RestorationMixin {
//   String verificationID = "";
//   @override
//   String? get restorationId => widget.restorationId;
//   String? get typeAccount => widget.typeAccount;
//   final TextEditingController _nameController = TextEditingController();
//   final TextEditingController _emailController = TextEditingController();
//   final TextEditingController _passwordController = TextEditingController();
//   final TextEditingController _bodController = TextEditingController();
//   final TextEditingController _specialDateController = TextEditingController();
//   final TextEditingController _phoneController = TextEditingController();
//   final _auth = FirebaseAuth.instance;
//   bool validateEmail = true;
//   bool validatePassword = true;
//   bool validateName = true;
//   bool validateBOD = false;
//   bool validateSpecialDate = false;
//   bool validatePhone = true;
//   bool validateCountry = false;
//   bool validateCity = false;
//   FocusNode focusNode = FocusNode();
//   String countryCodePhone = "";
//   late String countryValue = "";
//   late String? stateValue = "";
//   late String? cityValue = "";
//   bool _isLoading = false;
//   Widget btnLoginx = Text("Sign In");
//   DatabaseReference ref = FirebaseDatabase.instance.ref("App").child("User");
//   @override
//   void dispose() {
//     // TODO: implement dispose
//     _nameController.dispose();
//     _emailController.dispose();
//     _passwordController.dispose();
//     _bodController.dispose();
//     _specialDateController.dispose();
//     _phoneController.dispose();
//     super.dispose();
//   }
//
//   void signUpUser() async {
//     SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
//     String? typeUser = sharedPreferences.getString("TypeUser");
//     String res = await AuthMethods().signUpUser(
//       userName: _nameController.text,
//       email: _emailController.text,
//       phoneNumber: _phoneController.text,
//       password: _passwordController.text,
//       countryCode: countryCodePhone,
//       countryValue: countryValue,
//       stateValue: stateValue!,
//       cityValue: cityValue!,
//       bod: _bodController.text,
//       typeAccount: typeAccount!,
//       typeUser: typeUser!,
//     );
//     if (res == "User registered successfully") {
//       // Navigate to the main screen
//       Navigator.of(context).pushAndRemoveUntil(
//         MaterialPageRoute(builder: (context) => MainScreen()),
//         (Route<dynamic> route) => false,
//       );
//       print(res);
//     } else {
//       print(res); // Handle error cases if necessary
//     }
//   }
//
//   Future<void> _showMyDialog() async {
//     return showDialog<void>(
//       context: context,
//       barrierDismissible: false, // user must tap button!
//       builder: (BuildContext context) {
//         return AlertDialog(
//           // ignore: unnecessary_const
//           title: Text(
//             getTranslated(context, "Notes..."),
//             // ignore: prefer_const_constructors
//             style: TextStyle(
//                 fontWeight: FontWeight.bold, color: Colors.black, fontSize: 30),
//           ),
//           content: RichText(
//             // ignore: prefer_const_constructors
//             text: TextSpan(
//               text: getTranslated(
//                   context, 'We will send a verification code to '),
//               style: GoogleFonts.laila(
//                   fontSize: 6.w,
//                   color: Colors.black,
//                   fontWeight: FontWeight.bold),
//               // ignore: prefer_const_literals_to_create_immutables
//               children: <TextSpan>[
//                 TextSpan(
//                   text: countryCodePhone + _phoneController.text,
//                   // ignore: prefer_const_constructors
//                   style: kPrimaryTypeStyle,
//                 ),
//                 TextSpan(
//                     text: getTranslated(
//                         context, 'Are you sure the number is correct?'),
//                     style: GoogleFonts.laila(
//                         fontSize: 6.w,
//                         color: Colors.black,
//                         fontWeight: FontWeight.bold)),
//               ],
//             ),
//           ),
//           actions: <Widget>[
//             TextButton(
//               child: Text(
//                 getTranslated(context, 'Confirm'),
//                 style: const TextStyle(
//                   color: kConfirmTextColor,
//                 ),
//               ),
//               onPressed: () async {},
//             ),
//             TextButton(
//               child: Text(
//                 getTranslated(context, 'close'),
//                 style: const TextStyle(
//                   color: kCloseTextColor,
//                 ),
//               ),
//               onPressed: () async {
//                 setState(() {
//                   // ignore: prefer_const_constructors
//                   btnLoginx = Center(
//                       // ignore: prefer_const_constructors
//                       child: Text("Sign In"));
//                 });
//                 Navigator.of(context).pop();
//               },
//             ),
//           ],
//         );
//       },
//     );
//   }
//
//   static Route<DateTime> _datePickerRoute(
//     BuildContext context,
//     Object? arguments,
//   ) {
//     return DialogRoute<DateTime>(
//       context: context,
//       builder: (BuildContext context) {
//         return Theme(
//           data: ThemeData(
//             colorScheme: const ColorScheme.light(
//               primary: kPrimaryColor, // color of the header and selected date
//               onPrimary: Colors
//                   .white, // color of the text on the header and selected date
//               surface: Colors.white, // background color of the header
//               onSurface: Colors.black, // text color on the body
//             ),
//             dialogBackgroundColor:
//                 Colors.lightBlue[50], // background color of the dialog
//             buttonTheme: const ButtonThemeData(
//               textTheme: ButtonTextTheme.primary,
//             ),
//           ),
//           child: DatePickerDialog(
//             restorationId: 'date_picker_dialog',
//             initialEntryMode: DatePickerEntryMode.calendarOnly,
//             initialDate: DateTime.fromMillisecondsSinceEpoch(arguments! as int),
//             firstDate: DateTime(1900),
//             lastDate: DateTime(2024),
//           ),
//         );
//       },
//     );
//   }
//
//   final RestorableDateTime _selectedDate =
//       RestorableDateTime(DateTime(2021, 7, 25));
//   late final RestorableRouteFuture<DateTime?>
//       _restorableBODDatePickerRouteFuture = RestorableRouteFuture<DateTime?>(
//     onComplete: _selectBirthOfDate,
//     onPresent: (NavigatorState navigator, Object? arguments) {
//       return navigator.restorablePush(
//         _datePickerRoute,
//         arguments: _selectedDate.value.millisecondsSinceEpoch,
//       );
//     },
//   );
//   void restoreState(RestorationBucket? oldBucket, bool initialRestore) {
//     registerForRestoration(_selectedDate, 'selected_date');
//     registerForRestoration(
//         _restorableBODDatePickerRouteFuture, 'date_picker_route_future');
//   }
//
//   void _selectBirthOfDate(DateTime? newSelectedDate) {
//     if (newSelectedDate != null) {
//       setState(() {
//         _selectedDate.value = newSelectedDate;
//         _bodController.text =
//             '${_selectedDate.value.day}/${_selectedDate.value.month}/${_selectedDate.value.year}';
//       });
//     }
//   }
//
//   void _onCountryChange(CountryCode countryCode) {
//     //TODO : manipulate the selected country code here
//     countryCodePhone = countryCode.toString().trim();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final objProvider = Provider.of<GeneralProvider>(context, listen: true);
//     objProvider.CheckLang();
//     return Scaffold(
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
//                   hint: "UserName",
//                   icon: const Icon(
//                     Icons.person,
//                     color: kPrimaryColor,
//                   ),
//                   control: _nameController,
//                   isObsecured: false,
//                   validate: validateEmail,
//                   textInputType: TextInputType.text,
//                   showVisibilityToggle: false,
//                 ),
//                 TextFormFieldStyle(
//                   context: context,
//                   hint: "Email",
//                   icon: const Icon(
//                     Icons.email,
//                     color: kPrimaryColor,
//                   ),
//                   control: _emailController,
//                   isObsecured: false,
//                   validate: validateEmail,
//                   textInputType: TextInputType.emailAddress,
//                   showVisibilityToggle: false,
//                 ),
//                 TextFormFieldStyle(
//                   context: context,
//                   hint: "Phone Number",
//                   prefixIconWidget: SizedBox(
//                     width:
//                         130, // Adjust the width of the container holding the CountryCodePicker
//                     child: CountryCodePicker(
//                       onChanged: _onCountryChange,
//                       padding: const EdgeInsets.symmetric(
//                           horizontal: 5), // Reduce horizontal padding
//                       initialSelection: 'IT',
//                       favorite: const ['+966', 'SA'],
//                       showCountryOnly: false,
//                       showOnlyCountryWhenClosed: false,
//                       alignLeft: true,
//                     ),
//                   ),
//                   control: _phoneController,
//                   isObsecured: false,
//                   validate: validatePassword,
//                   textInputType: TextInputType.phone,
//                   showVisibilityToggle: false,
//                 ),
//                 InkWell(
//                   child: TextFormFieldStyle(
//                     context: context,
//                     hint: "Birthday",
//                     // ignore: prefer_const_constructors
//                     icon: Icon(
//                       Icons.calendar_month,
//                       color: kPrimaryColor,
//                     ),
//                     control: _bodController,
//                     isObsecured: false,
//                     validate: validateSpecialDate,
//                     textInputType: TextInputType.text,
//                   ),
//                   onTap: () {
//                     _restorableBODDatePickerRouteFuture.present();
//                   },
//                 ),
//                 TextFormFieldStyle(
//                   context: context,
//                   hint: "Password",
//                   icon: const Icon(
//                     Icons.lock,
//                     color: kPrimaryColor,
//                   ),
//                   control: _passwordController,
//                   isObsecured: true,
//                   validate: validatePassword,
//                   textInputType: TextInputType.text,
//                   showVisibilityToggle: true,
//                 ),
//                 CustomCSCPicker(
//                   onCountryChanged: (value) {
//                     setState(() {
//                       countryValue = value;
//                     });
//                   },
//                   onStateChanged: (value) {
//                     setState(() {
//                       stateValue = value;
//                     });
//                   },
//                   onCityChanged: (value) {
//                     setState(() {
//                       cityValue = value;
//                     });
//                   },
//                 ),
//                 10.kH,
//                 Container(
//                   margin: const EdgeInsets.symmetric(horizontal: 20),
//                   child: ElevatedButton(
//                     onPressed: () async {
//                       if (_nameController.text.isEmpty ||
//                           _emailController.text.isEmpty ||
//                           _phoneController.text.isEmpty ||
//                           _bodController.text.isEmpty ||
//                           _passwordController.text.isEmpty ||
//                           countryValue.isEmpty ||
//                           cityValue!.isEmpty ||
//                           stateValue!.isEmpty) {
//                         getTranslated(
//                           context,
//                           objProvider.FunSnackBarPage(
//                             'All Fields must be filled',
//                             context,
//                           ),
//                         );
//                       } else {
//                         setState(() {
//                           _isLoading =
//                               true; // Set isLoading to true to show progress indicator
//                         });
//                         signUpUser(); // Perform sign-up process
//                       }
//                     },
//                     style: ElevatedButton.styleFrom(
//                       minimumSize: const Size(double.infinity, 36),
//                       backgroundColor: kPrimaryColor,
//                     ),
//                     child: _isLoading
//                         ? SizedBox(
//                             width: 20, // Adjust width as needed
//                             height: 20, // Adjust height as needed
//                             child: CircularProgressIndicator(
//                               color: Colors.white,
//                               strokeWidth: 2,
//                             ),
//                           )
//                         : Text(
//                             getTranslated(context, 'Sign Up'),
//                             style: const TextStyle(
//                               color: Colors.white,
//                             ),
//                           ),
//                   ),
//                 ),
//                 Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: <Widget>[
//                     10.kH, // Add some space before the first button if necessary
//                     TextButton(
//                       onPressed: () {
//                         Navigator.of(context).push(
//                           MaterialPageRoute(
//                             builder: (context) => const LoginScreen(
//                               title: '',
//                             ),
//                           ),
//                         );
//                       },
//                       child: Text(
//                         getTranslated(context, 'Login'),
//                         textAlign: TextAlign.center,
//                         style: const TextStyle(
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
//                         style: const TextStyle(
//                           color: kSecondaryColor,
//                         ),
//                       ),
//                     ),
//                     // Spacing between buttons
//                     TextButton(
//                       onPressed: () {},
//                       child: Text(
//                         getTranslated(context, 'Forgot password'),
//                         textAlign: TextAlign.center,
//                         style: const TextStyle(
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
