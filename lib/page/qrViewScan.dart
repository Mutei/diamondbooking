import 'dart:io';
import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

class QRViewScan extends StatefulWidget {
  final String expectedID;

  QRViewScan({required this.expectedID});

  @override
  QRViewExample createState() => QRViewExample(expectedID);
}

class QRViewExample extends State<QRViewScan> {
  final String expectedID;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  Barcode? result;
  QRViewController? controller;
  bool _isNavigating = false; // Prevents multiple pops

  QRViewExample(this.expectedID);

  @override
  void reassemble() {
    super.reassemble();
    if (controller != null) {
      if (Platform.isAndroid) {
        controller!.pauseCamera();
      } else if (Platform.isIOS) {
        controller!.resumeCamera();
      }
    }
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) {
      if (_isNavigating) return; // Prevent multiple navigations
      setState(() {
        result = scanData;
      });

      if (result != null && result!.code != null) {
        final scannedData = result!.code!;
        print('Scanned Data: $scannedData');

        // Parse the scanned data to extract the estate ID
        String? scannedEstateID;
        try {
          final uri = Uri.parse(scannedData);
          scannedEstateID = uri.queryParameters['estateId'];
        } catch (e) {
          print('Failed to parse URI: $e');
        }

        // Additional parsing logic if the data is not a URL
        if (scannedEstateID == null && scannedData.contains('estateId')) {
          final splitData = scannedData.split('=');
          if (splitData.length > 1) {
            scannedEstateID = splitData[1];
          }
        }

        print('Scanned Estate ID: $scannedEstateID');
        print('Expected Estate ID: $expectedID');

        if (mounted) {
          _isNavigating = true;
          if (scannedEstateID == expectedID) {
            Navigator.pop(context, true);
          } else {
            Navigator.pop(context, false);
          }
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          Expanded(
            flex: 5,
            child: QRView(
              key: qrKey,
              onQRViewCreated: _onQRViewCreated,
            ),
          ),
          Expanded(
            flex: 1,
            child: Center(
              child: (result != null)
                  ? Text(
                  'Barcode Type: ${result!.format}   Data: ${result!.code}')
                  : Text('Scan a code'),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}
