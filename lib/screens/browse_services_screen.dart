import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class BrowseServicesScreen extends StatefulWidget {
  final int userId;
  const BrowseServicesScreen({super.key, required this.userId});

  @override
  State<BrowseServicesScreen> createState() => _BrowseServicesScreenState();
}

class _BrowseServicesScreenState extends State<BrowseServicesScreen> {
  List<dynamic> services = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    fetchServices();
  }

  Future<void> fetchServices() async {
    var response = await http.get(Uri.parse("http://<your-ip>:8080/api/services"));
    if (response.statusCode == 200) {
      setState(() {
        services = jsonDecode(response.body);
        loading = false;
      });
    }
  }

  Future<void> joinQueue(int serviceId) async {
    var response = await http.post(
      Uri.parse("http://<your-ip>:8080/api/tokens/join"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"userId": widget.userId, "serviceId": serviceId}),
    );
    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Joined queue successfully!")),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Browse Services")),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: services.length,
        itemBuilder: (context, index) {
          final s = services[index];
          return Card(
            margin: const EdgeInsets.all(8),
            child: ListTile(
              title: Text(s["name"]),
              subtitle: Text("Location: ${s["location"]}"),
              trailing: ElevatedButton(
                onPressed: () => joinQueue(s["serviceId"]),
                child: const Text("Join"),
              ),
            ),
          );
        },
      ),
    );
  }
}
