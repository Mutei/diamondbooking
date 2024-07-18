import 'package:flutter/material.dart';

class PrivateChatScreen extends StatelessWidget {
  final String userId;
  final String fullName;

  PrivateChatScreen({required this.userId, required this.fullName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(fullName),
      ),
      body: Center(
        child: Text('Private chat with $fullName'),
      ),
    );
  }
}
