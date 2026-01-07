import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class EnterCodeScreen extends StatefulWidget {
  final int userId;
  const EnterCodeScreen({super.key, required this.userId});

  @override
  State<EnterCodeScreen> createState() => _EnterCodeScreenState();
}

class _EnterCodeScreenState extends State<EnterCodeScreen> {
  final TextEditingController _codeController = TextEditingController();
  bool _loading = false;

  Future<void> _joinQueue() async {
    setState(() => _loading = true);
    var response = await http.post(
      Uri.parse("http://<your-ip>:8080/api/tokens/join"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "userId": widget.userId,
        "serviceCode": _codeController.text.trim(),
      }),
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Queue joined successfully!")),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Invalid or expired code")),
      );
    }
    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Enter Queue Code")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _codeController,
              decoration: const InputDecoration(
                labelText: "Enter Queue Code",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _loading ? null : _joinQueue,
              child: _loading
                  ? const CircularProgressIndicator()
                  : const Text("Join Queue"),
            ),
          ],
        ),
      ),
    );
  }
}
