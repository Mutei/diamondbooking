import 'package:flutter/material.dart';

class TextHeader extends StatelessWidget {
  final String text;
  final BuildContext context;

  const TextHeader(this.text, this.context, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 30, right: 30, bottom: 10, top: 10),
      child: Text(
        getTranslated(this.context, text),
        style: const TextStyle(
            fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black),
      ),
    );
  }

  String getTranslated(BuildContext context, String key) {
    // Add your translation logic here
    return key;
  }
}
