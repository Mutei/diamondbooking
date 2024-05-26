import 'package:diamond_booking/extension/sized_box_extension.dart';
import 'package:diamond_booking/localization/language_constants.dart';
import 'package:diamond_booking/screen/sign_in_screen.dart';
import 'package:flutter/material.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
  bool rememberMe = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    userType = widget.userType ?? '';
    _loadSavedEmail();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadSavedEmail() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _emailController.text = prefs.getString('savedEmail') ?? '';
      rememberMe = _emailController.text.isNotEmpty;
    });
  }

  Future<void> _saveEmail(String email) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('savedEmail', email);
  }

  Future<void> loginWithEmail() async {
    if (_formKey.currentState!.validate()) {
      String userId = await AuthMethods().loginUser(
        email: _emailController.text,
        password: _passwordController.text,
        context: context,
      );
      print("The userid in login is $userId");
      if (rememberMe) {
        await _saveEmail(_emailController.text);
      } else {
        await _saveEmail('');
      }
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
                    16.kH,
                    Row(
                      children: [
                        Checkbox(
                          value: rememberMe,
                          onChanged: (value) {
                            setState(() {
                              rememberMe = value!;
                            });
                          },
                        ),
                        const Text('Remember Me')
                      ],
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
