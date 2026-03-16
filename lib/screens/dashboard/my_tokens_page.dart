import 'package:flutter/material.dart';
import 'package:nextup/screens/QueueStatusScreen.dart';
import '../../services/api_services.dart';
import '../../widgets/token_card.dart';

import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:nextup/services/notification_service.dart';
class MyTokensPage extends StatefulWidget {
  final int userId;

  const MyTokensPage({Key? key, required this.userId})
      : super(key: key);

  @override
  State<MyTokensPage> createState() => _MyTokensPageState();
}

class _MyTokensPageState extends State<MyTokensPage> {
  List<dynamic> myQueues = [];
  bool isLoading = true;
  Timer? _timer;

  final String baseUrl = "http://192.168.1.41:8080";

  @override
  void initState() {
    super.initState();
    _fetchTokens();

    _timer = Timer.periodic(
      const Duration(seconds: 10),
          (_) => _fetchTokens(),
    );


  }

  Future<void> _fetchTokens() async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/api/queue/user/${widget.userId}"),
      );

      if (response.statusCode == 200) {
        setState(() {
          myQueues = jsonDecode(response.body);
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
      }
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F5FA),
      body: Column(
        children: [

          /// ===== PREMIUM HEADER =====
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(24, 60, 24, 20),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(
                bottom: Radius.circular(28),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  "My Active Tokens",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.2,
                  ),
                ),
                SizedBox(height: 12),
                Divider(height: 1),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: isLoading
                  ? const Center(
                child: CircularProgressIndicator(),
              )
                  : myQueues.isEmpty
                  ? _buildEmptyState()
                  : RefreshIndicator(
                onRefresh: _fetchTokens,
                child: ListView.builder(
                  itemCount: myQueues.length,
                  itemBuilder: (context, index) {
                    final queue = myQueues[index];

                    return _buildTokenCard(queue);
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// ===== PREMIUM TOKEN CARD =====
  Widget _buildTokenCard(dynamic queue) {
    final bool isNext = queue["position"] == 1;

    return GestureDetector(
      onTap: () {

        print(queue);

        final qId = queue["id"];        // ✅ changed
        final uId = queue["userId"];

        if (qId == null || uId == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Invalid token data")),
          );
          return;
        }

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => QueueStatusScreen(
              serviceName: queue["serviceName"] ?? "Service",
              tokenNumber: queue["tokenNumber"] ?? 0,
              position: queue["position"] ?? 0,
              estimatedTime: queue["averageWaitingTimeMinutes"] ?? 0,
              status: queue["status"] ?? "WAITING",
              queueEntryId: qId,
              userId: uId,
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 18),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFFFFFFF),
              Color(0xFFF8FAFF),
            ],
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: Colors.grey.shade100,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            /// 🔹 Top Row (Service Name + Status)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    queue["serviceName"] ?? "Service",
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.2,
                    ),
                  ),
                ),
                _statusBadge(isNext),
              ],
            ),

            const SizedBox(height: 20),

            /// 🔹 Token Highlight Section
            Container(
              padding: const EdgeInsets.symmetric(
                vertical: 14,
                horizontal: 16,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFFEEF1FF),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Tap to See live Queue updates                   Your Token",
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey,
                    ),
                  ),
                  Text(
                    "#${queue["tokenNumber"]}",
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF4F46E5),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            /// 🔹 Info Row

          ],
        ),
      ),
    );
  }

  Widget _infoItem(
      IconData icon, String title, String value) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            size: 16,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey.shade500,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _statusBadge(bool isNext) {
    return Container(
      padding:
      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isNext
            ? Colors.green.withOpacity(0.15)
            : Colors.indigo.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        isNext ? "Next" : "Active",
        style: TextStyle(
          color: isNext ? Colors.green : Colors.indigo,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }

  /// ===== EMPTY STATE =====
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment:
        MainAxisAlignment.center,
        children: const [
          Icon(Icons.inbox,
              size: 60, color: Colors.grey),
          SizedBox(height: 12),
          Text(
            "You are not in any queue",
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}