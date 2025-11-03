import 'package:flutter/material.dart';
import '../../services/api_services.dart';
import '../../widgets/token_card.dart';

class MyTokensPage extends StatefulWidget {
  final int userId;
  const MyTokensPage({super.key, required this.userId});

  @override
  State<MyTokensPage> createState() => _MyTokensPageState();
}

class _MyTokensPageState extends State<MyTokensPage> {
  List<Map<String, dynamic>> tokens = [];
  bool loading = true;
  String? errorMessage;

  Future<void> _loadTokens() async {
    try {
      final data = await ApiService.getMyTokens(widget.userId);

      setState(() {
        tokens = List<Map<String, dynamic>>.from(data);
        loading = false;
        errorMessage = null;
      });
    } catch (e) {
      setState(() {
        loading = false;
        errorMessage = 'Failed to load tokens. Please try again.';
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _loadTokens();
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(errorMessage!, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _loadTokens,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (tokens.isEmpty) {
      return const Center(
        child: Text(
          'No tokens found.',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadTokens,
      child: ListView.builder(
        padding: const EdgeInsets.all(10),
        itemCount: tokens.length,
        itemBuilder: (context, index) {
          final token = tokens[index];
          return TokenCard(
            tokenNumber: token['tokenNumber'] ?? 0,
            serviceName: token['serviceName'] ?? 'Unknown Service',
            status: token['status'] ?? 'Pending',
            issuedAt: token['createdAt'] ?? '',
            position: token['position'] ?? 0,
            onTap: () {
              // Optional: Navigate to token details or queue status page
            },
          );
        },
      ),
    );
  }
}

