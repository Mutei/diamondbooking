import 'package:flutter/material.dart';

class CloseButtonWidget extends StatelessWidget {
  final VoidCallback onTap;

  const CloseButtonWidget({Key? key, required this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(blurRadius: 10, color: Colors.grey, spreadRadius: 1)
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
