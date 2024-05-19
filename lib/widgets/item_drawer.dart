import 'package:flutter/material.dart';

class DrawerItem extends StatelessWidget {
  final String text;
  final Icon icon;
  final Function() onTap;
  final String hint;

  const DrawerItem({
    required this.text,
    required this.icon,
    required this.onTap,
    required this.hint,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      child: ListTile(
        title: Text(text),
        subtitle: Text(
          hint,
          style: TextStyle(fontSize: 12),
        ),
        leading: icon,
        onTap: onTap,
      ),
    );
  }
}
