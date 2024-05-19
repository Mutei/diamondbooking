import 'package:diamond_booking/extension/sized_box_extension.dart';
import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../constants/styles.dart';

class ReusedElevatedButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final IconData icon;

  const ReusedElevatedButton({
    super.key,
    required this.text,
    required this.onPressed,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: kElevatedButtonStyle,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: kSecondaryColor,
          ),
          10.kW,
          Text(
            text,
            style: const TextStyle(
              color: kSecondaryColor,
            ),
          ),
        ],
      ),
    );
  }
}
