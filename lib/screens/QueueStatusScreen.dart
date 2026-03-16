import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'package:nextup/services/notification_service.dart';
import 'package:nextup/services/notifications_store.dart';
class QueueStatusScreen extends StatefulWidget {
  final String serviceName;
  final int tokenNumber;
  final int position;
  final int estimatedTime;
  final dynamic status;

  final int queueEntryId;
  final int userId;

  const QueueStatusScreen({
    super.key,
    required this.serviceName,
    required this.tokenNumber,
    required this.position,
    required this.estimatedTime,
    required this.status,
    required this.queueEntryId,
    required this.userId,


  });

  @override
  State<QueueStatusScreen> createState() => _QueueStatusScreenState();
}

class _QueueStatusScreenState extends State<QueueStatusScreen>
    with SingleTickerProviderStateMixin {

  late AnimationController _blinkController;
  late Animation<double> _blinkAnimation;
  Timer? _pollingTimer;
  bool get isNext => _position == 1 && _status == "WAITING";
  bool get isProcessing => _status == "SERVING";
  int _position = 0;
  int _estimatedTime = 0;
  String _status = "";
  bool notificationSent = false;
  int? _lastPosition;
  bool notifiedFor3 = false;
  bool notifiedFor1 = false;
  int? _previousPosition;

  Future<void> cancelToken() async {
    print("QUEUE ENTRY ID: ${widget.queueEntryId}");
    print("USER ID: ${widget.userId}");

    final url = Uri.parse(
        "http://192.168.1.41:8080/api/queue/cancel/${widget.queueEntryId}?userId=${widget.userId}");

    final response = await http.delete(url);

    print("STATUS: ${response.statusCode}");
    print("BODY: ${response.body}");

    if (!mounted) return;

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Token cancelled")),
      );

      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed (${response.statusCode})")),
      );
    }
  }

  Future<void> _loadQueueStatus() async {
    try {
      print("FETCH USER QUEUE STATUS: ${widget.userId}");

      final url = Uri.parse(
        "http://192.168.1.41:8080/api/queue/user/${widget.userId}",
      );

      final response = await http.get(url);

      print("STATUS: ${response.statusCode}");
      print("BODY: ${response.body}");

      if (!mounted) return;

      if (response.statusCode == 200) {

        final List data = jsonDecode(response.body);

        if (data.isEmpty) return;

        final queue = data.first;

        int position = queue["position"] ?? _position;
        String serviceName = queue["serviceName"] ?? "Service";

        print("CURRENT POSITION: $position");

        // 🔔 Trigger notification only when position changes
        if (_previousPosition != position) {

          if (position == 3) {
            print("CALLING NOTIFICATION SERVICE FOR POSITION 3");

            await NotificationService.showNotification(
              "Almost Your Turn",
              "$serviceName - Only 2 people ahead",
            );

            NotificationStore.addNotification(
              serviceName,
              "Almost Your Turn",
              "Only 2 people ahead of you. Get ready!",
            );
          }

          if (position == 1) {
            print("CALLING NOTIFICATION SERVICE FOR POSITION 1");

            await NotificationService.showNotification(
              "Your Are Next..!",
              "$serviceName - Be ready to proceed to the service counter",
            );

            NotificationStore.addNotification(
              serviceName,
              "You Are NEXT",
              "Be ready to proceed to the service counter",
            );
          }

          // Update previous position
          _previousPosition = position;
        }

        setState(() {
          _position = position;
          _estimatedTime =
              queue["averageWaitingTimeMinutes"] ?? _estimatedTime;
          _status = queue["status"] ?? _status;
        });
      }
    } catch (e) {
      debugPrint("Queue status error: $e");
    }
  }

  @override
  void initState() {
    super.initState();

    // copy initial values from MyTokensPage
    _position = widget.position;
    _estimatedTime = widget.estimatedTime;
    _status = widget.status;
    notifiedFor3 = false;
    notifiedFor1 = false;
    // blinking animation
    _blinkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);

    _blinkAnimation =
        Tween<double>(begin: 0.4, end: 1.0).animate(_blinkController);

    // load latest queue status immediately
    _loadQueueStatus();

    // polling every 5 seconds
    _pollingTimer = Timer.periodic(
      const Duration(seconds: 5),
          (timer) {
        if (mounted) {

          _loadQueueStatus();
        }
      },
    );
  }

  @override
  void dispose() {
    _blinkController.dispose(); // stop animation
    _pollingTimer?.cancel();    // stop polling
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F5FA),
      body: SafeArea(
        child: Column(
          children: [

            /// ===== PREMIUM HEADER =====
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(24, 18, 24, 22),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFF4F46E5),
                    Color(0xFF7C3AED),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(28),
                ),
              ),
              child: SizedBox(
                height: 80,
                child: Stack(
                  children: [

                    /// TOP LEFT LABEL
                    const Align(
                      alignment: Alignment.topLeft,
                      child: Text(
                        "Live Queue Status",
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),

                    /// CENTERED SERVICE NAME
                    Align(
                      alignment: Alignment.center,
                      child: Text(
                        widget.serviceName,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.6,
                        ),
                      ),
                    ),

                    /// STATUS BAR (BOTTOM LEFT)
                    Align(
                      alignment: Alignment.bottomLeft,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.2),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [

                            /// STATUS DOT
                            FadeTransition(
                              opacity: (isProcessing || widget.status == "WAITING")
                                  ? _blinkAnimation
                                  : const AlwaysStoppedAnimation(1),
                              child: Container(
                                width: 9,
                                height: 9,
                                decoration: BoxDecoration(
                                  color: isProcessing
                                      ? Colors.green
                                      : isNext
                                      ? Colors.white
                                      : Colors.white70,
                                  shape: BoxShape.circle,
                                  boxShadow: isProcessing
                                      ? [
                                    BoxShadow(
                                      color: Colors.green.withOpacity(0.6),
                                      blurRadius: 8,
                                      spreadRadius: 1.5,
                                    )
                                  ]
                                      : [],
                                ),
                              ),
                            ),

                            const SizedBox(width: 8),

                            /// STATUS TEXT
                            Text(
                              isProcessing
                                  ? "Serving"
                                  : isNext
                                  ? "Up Next"
                                  : "Waiting",
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: Colors.white,
                                letterSpacing: 0.2,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 32),

            /// ===== TOKEN HERO CARD =====
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              padding: const EdgeInsets.symmetric(vertical: 36),
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: isProcessing
                    ? const LinearGradient(
                  colors: [
                    Color(0xFFE8FFF7),
                    Color(0xFFDDF6FF),
                    Color(0xFFEDE8FF),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
                    : const LinearGradient(
                  colors: [
                    Colors.white,
                    Colors.white,
                  ],
                ),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(
                  color: isProcessing
                      ? const Color(0xFFD7F5EA)
                      : const Color(0xFFE8EBF3),
                  width: 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 30,
                    offset: const Offset(0, 14),
                  ),
                ],
              ),
              child: Column(
                children: [

                  const Text(
                    "Your Token",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                      color: Colors.grey,
                    ),
                  ),

                  const SizedBox(height: 20),

                  ShaderMask(
                    shaderCallback: (bounds) => const LinearGradient(
                      colors: [
                        Color(0xFF12C48B),
                        Color(0xFF7B61FF),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ).createShader(bounds),
                    child: Text(
                      widget.tokenNumber.toString(),
                      style: const TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 6,
                        fontFamily: "monospace",
                        color: Colors.white,
                      ),
                    ),
                  ),

                  const SizedBox(height: 18),

                  Text(
                    isProcessing
                        ? "Your service is being processed."
                        : isNext
                        ? "You're next! Please be ready."
                        : "Please wait for your turn.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: isProcessing
                          ? Colors.green
                          : isNext
                          ? const Color(0xFF5B6CFF)
                          : Colors.grey,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 22),

                  if (isProcessing)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _typingDot(delay: 0),
                        const SizedBox(width: 6),
                        _typingDot(delay: 200),
                        const SizedBox(width: 6),
                        _typingDot(delay: 400),
                      ],
                    ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  Expanded(
                    child: _PremiumInfoCard(
                      icon: Icons.format_list_numbered,
                      title: "Your Position In Queue",
                      value: isProcessing
                          ? "Serving"
                          : _position.toString(),   // ✅ FIXED
                    ),
                  ),
                  const SizedBox(width: 18),
                  Expanded(
                    child: _PremiumInfoCard(
                      icon: Icons.schedule_rounded,
                      title: "Estimated Waiting Time",
                      value: isProcessing
                          ? "--"
                          : "$_estimatedTime min",  // ✅ FIXED
                    ),
                  ),
                ],
              ),
            ),

            const Spacer(),

            Padding(
              padding: const EdgeInsets.only(bottom: 28),
              child: Text(
                isProcessing
                    ? "Please proceed to the service counter."
                    : "You will receive a notification when it's your turn.",
                style: TextStyle(
                  color: Colors.grey.shade500,
                  fontSize: 13,
                ),
              ),
            ),


            if (widget.status == "WAITING") ...[
              const SizedBox(height: 1), // smaller space above → pulls button upward

              Padding(
                padding: const EdgeInsets.only(bottom: 15), // adjust this to fine-tune position
                child: Center(
                  child: SizedBox(
                    width: 180,
                    height: 40,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.cancel_outlined, size: 18),
                      label: const Text(
                        "Cancel Token",
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.3,
                        ),
                      ),

                      onPressed: () async {
                        final confirm = await showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text("Cancel Token"),
                            content: const Text(
                              "Are you sure you want to cancel this token?",
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: const Text("No"),
                              ),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFE53935),
                                  foregroundColor: Colors.white,
                                ),
                                onPressed: () => Navigator.pop(context, true),
                                child: const Text("Yes"),
                              ),
                            ],
                          ),
                        );

                        if (confirm == true) {
                          cancelToken();
                        }
                      },

                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE53935),
                        foregroundColor: Colors.white,
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }

  Widget _typingDot({required int delay}) {
    return TweenAnimationBuilder(
      tween: Tween(begin: 0.3, end: 1.0),
      duration: Duration(milliseconds: 600 + delay),
      curve: Curves.easeInOut,
      builder: (context, value, child) {
        return Opacity(
          opacity: value as double,
          child: Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: Color(0xFF0FAF87),
              shape: BoxShape.circle,
            ),
          ),
        );
      },
    );
  }
}

/// ===== PREMIUM INFO CARD =====

class _PremiumInfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _PremiumInfoCard({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 25,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: const Color(0xFF5B6CFF), size: 26),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}



