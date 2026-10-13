import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:qr/featuer/result/reselt_scan.dart';

class ScanPage extends StatefulWidget {
  const ScanPage({super.key});

  @override
  State<ScanPage> createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> {
  final MobileScannerController _scannerController = MobileScannerController(
    autoStart: true,
  );
  bool _hasScanned = false;

  @override
  void dispose() {
    _scannerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("ماسح الرمز السريع (QR)"),
        centerTitle: true,
      ),
      body: MobileScanner(controller: _scannerController, onDetect: _onDetect),
    );
  }

  Future<void> _onDetect(BarcodeCapture capture) async {
    if (_hasScanned) return;

    final barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;

    final resultText = barcodes.first.rawValue;
    if (resultText == null || resultText.isEmpty) return;

    _hasScanned = true;

    await _saveResult(resultText);

    await _scannerController.stop();

    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const ResultScanView()),
      );
    }
  }

  Future<void> _saveResult(String resultText) async {
    final user = FirebaseAuth.instance.currentUser;
    final collection = FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .collection('scans');

    await collection.doc().set({"result": resultText, "time": DateTime.now()});
  }
}
