import 'package:flutter/material.dart';

class CloseTextFormFieldStyle extends StatelessWidget {
  final Function() onTap;

  const CloseTextFormFieldStyle({
    super.key,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(blurRadius: 10, color: Colors.grey, spreadRadius: 1),
          ],
        ),
        child: const CircleAvatar(
          backgroundColor: Colors.white,
          child: Icon(
            Icons.close,
            color: Colors.red,
          ),
        ),
      ),
    );
  }
}
