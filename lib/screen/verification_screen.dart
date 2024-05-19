import 'package:diamond_booking/extension/sized_box_extension.dart';
import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';
import 'package:sms_autofill/sms_autofill.dart';

import '../constants/styles.dart';
import '../resources/auth_methods.dart';

class VerifyOtp extends StatefulWidget {
  final String phoneNumber;
  final String verificationId;
  final String email;
  final String password;
  final String typeUser;
  final String typeAccount;

  const VerifyOtp({
    super.key,
    required this.phoneNumber,
    required this.verificationId,
    required this.email,
    required this.password,
    required this.typeUser,
    required this.typeAccount,
  });

  @override
  State<VerifyOtp> createState() => _VerifyOtpState();
}

class _VerifyOtpState extends State<VerifyOtp> with CodeAutoFill {
  String otpCode = '';

  @override
  void initState() {
    super.initState();
    listenForCode();
  }

  @override
  void dispose() {
    cancel();
    super.dispose();
  }

  @override
  void codeUpdated() {
    setState(() {
      otpCode = code!;
    });
    AuthMethods().verifyOtp(
      context,
      widget.verificationId,
      otpCode,
      widget.email,
      widget.phoneNumber,
      widget.password,
      widget.typeUser,
      widget.typeAccount,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.phoneNumber),
        titleTextStyle: Theme.of(context).textTheme.headlineSmall!.copyWith(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(14.0),
          child: Column(
            children: [
              const Text(
                "To register, enter the 6 digit codes sent to you on messages!",
              ),
              20.kH,
              Pinput(
                length: 6,
                defaultPinTheme: kDefaultPinTheme,
                focusedPinTheme: kFocusedPinTheme,
                submittedPinTheme: kSubmittedPinTheme,
                controller: TextEditingController(text: otpCode),
                onCompleted: (value) {
                  AuthMethods().verifyOtp(
                    context,
                    widget.verificationId,
                    value,
                    widget.email,
                    widget.phoneNumber,
                    widget.password,
                    widget.typeAccount,
                    widget.typeUser,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_database/firebase_database.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';
// import 'package:provider/provider.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:sizer/sizer.dart';
//
// import '../constants/colors.dart';
// import '../general_provider.dart';
// import '../localization/language_constants.dart';
// import 'main_screen.dart';
//
// class VerificationPhone extends StatefulWidget {
//   final String verificationId;
//   final String phone;
//   final String countryCodePhone;
//
//   VerificationPhone({
//     required this.verificationId,
//     required this.phone,
//     required this.countryCodePhone,
//   });
//
//   @override
//   _VerificationPhoneState createState() => _VerificationPhoneState();
// }
//
// class _VerificationPhoneState extends State<VerificationPhone> {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: SafeArea(
//         child: SingleChildScrollView(
//           child: Column(
//             children: [
//               Text(
//                   "Enter OTP sent to ${widget.countryCodePhone}${widget.phone}"),
//               OtpTextField(
//                 numberOfFields: 6,
//                 borderColor: Theme.of(context).primaryColor,
//                 showFieldAsBox: true,
//                 onCodeChanged: (String code) {},
//                 onSubmit: (String verificationCode) async {
//                   try {
//                     PhoneAuthCredential credential =
//                         PhoneAuthProvider.credential(
//                       verificationId: widget.verificationId,
//                       smsCode: verificationCode,
//                     );
//                     UserCredential userCredential = await FirebaseAuth.instance
//                         .signInWithCredential(credential);
//
//                     // Optional: Store or update additional user info here if needed
//
//                     // Navigate to MainScreen
//                     Navigator.pushReplacement(context,
//                         MaterialPageRoute(builder: (_) => MainScreen()));
//                   } catch (e) {
//                     showDialog(
//                         context: context,
//                         builder: (_) => AlertDialog(
//                               content: Text("Failed to verify OTP: $e"),
//                             ));
//                   }
//                 },
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
