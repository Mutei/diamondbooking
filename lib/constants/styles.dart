import 'package:flutter/material.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pinput/pinput.dart';
import 'package:sizer/sizer.dart';

import 'colors.dart';

final kPrimaryGoogleFontsStyle = GoogleFonts.laila(
  fontSize: 6.w,
  fontWeight: FontWeight.bold,
  color: Colors.black,
);
final kSecondaryGoogleFontsStyle = GoogleFonts.laila(
  fontWeight: FontWeight.bold,
  color: Colors.black,
);
final kPrimaryTypeStyle = GoogleFonts.laila(
  fontSize: 6.w,
  color: kPrimaryColor,
  fontWeight: FontWeight.bold,
);
ButtonStyle kElevatedButtonStyle = ElevatedButton.styleFrom(
  minimumSize: const Size(double.infinity, 36),
  backgroundColor: kPrimaryColor,
);
final kDefaultPinTheme = PinTheme(
  width: 56,
  height: 56,
  textStyle: const TextStyle(
      fontSize: 20,
      color: Color.fromRGBO(30, 60, 87, 1),
      fontWeight: FontWeight.w600),
  decoration: BoxDecoration(
    border: Border.all(
      color: const Color.fromRGBO(234, 239, 243, 1),
    ),
    borderRadius: BorderRadius.circular(20),
  ),
);
final kFocusedPinTheme = kDefaultPinTheme.copyDecorationWith(
  border: Border.all(
    color: const Color.fromRGBO(114, 178, 238, 1),
  ),
  borderRadius: BorderRadius.circular(8),
);

final kSubmittedPinTheme = kDefaultPinTheme.copyWith(
  decoration: kDefaultPinTheme.decoration?.copyWith(
    color: const Color.fromRGBO(234, 239, 243, 1),
  ),
);
