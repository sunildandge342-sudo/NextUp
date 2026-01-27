import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:http/http.dart' as http;

class ScanQRScreen extends StatefulWidget {
  final int userId;

  const ScanQRScreen({super.key, required this.userId});

  @override
  State<ScanQRScreen> createState() => _ScanQRScreenState();
}

class _ScanQRScreenState extends State<ScanQRScreen> {
  bool _isProcessing = false;
  final MobileScannerController _controller = MobileScannerController();

  Future<void> _joinQueue(String queueCode) async {
    if (_isProcessing) return;

    setState(() => _isProcessing = true);
    _controller.stop();

    try {
      final response = await http.post(
        Uri.parse("http://10.28.43.24:8080/api/token/join"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "userId": widget.userId,
          "queueCode": queueCode,
        }),
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Joined queue successfully")),
        );
        Navigator.pop(context);
      } else {
        throw Exception();
      }
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to join queue")),
      );
      _controller.start();
      setState(() => _isProcessing = false);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Scan QR Code"),
        actions: [
          IconButton(
            icon: const Icon(Icons.keyboard),
            tooltip: "Enter code manually",
            onPressed: () {
              _controller.stop();
              Navigator.pop(context); // or open EnterCodeScreen
            },
          ),
        ],
      ),

      body: MobileScanner(
        controller: _controller,
        onDetect: (capture) {
          if (_isProcessing) return;
          final code = capture.barcodes.first.rawValue;
          if (code != null && code.isNotEmpty) {
            _joinQueue(code);
          }
        },
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.indigo,
        child: const Icon(Icons.close),
        onPressed: () {
          _controller.stop();
          Navigator.pop(context);
        },
      ),
    );
  }
}
