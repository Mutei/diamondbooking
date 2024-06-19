import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class QRImage extends StatelessWidget {
  final String userId;
  final String userName;

  const QRImage({required this.userId, required this.userName, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final qrData = 'MyApp://chat?userId=$userId&userName=$userName';

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF84A5FA),
      ),
      body: Center(
        child: QrImageView(
          data: qrData,
          size: 280,
          embeddedImageStyle: QrEmbeddedImageStyle(
            size: const Size(100, 100),
          ),
        ),
      ),
    );
  }
}
