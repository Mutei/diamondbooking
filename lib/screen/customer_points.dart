import 'package:diamond_booking/constants/colors.dart';
import 'package:diamond_booking/constants/styles.dart';
import 'package:diamond_booking/localization/language_constants.dart';
import 'package:flutter/material.dart';

class CustomerPoints extends StatefulWidget {
  const CustomerPoints({super.key});

  @override
  State<CustomerPoints> createState() => _CustomerPointsState();
}

class _CustomerPointsState extends State<CustomerPoints> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        iconTheme: kIconTheme,
        title: Text(
          getTranslated(
            context,
            "My Points",
          ),
          style: const TextStyle(color: kPrimaryColor),
        ),
      ),
    );
  }
}
