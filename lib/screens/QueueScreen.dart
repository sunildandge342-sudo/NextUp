import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:qr_flutter/qr_flutter.dart';
class QueueScreen extends StatefulWidget {
  final int userId;
  final int serviceId;
  final String serviceName;
  final bool isActive;

  const QueueScreen({
    super.key,
    required this.serviceId,
    required this.serviceName,
    required this.isActive,
    required this.userId,
  });

  @override
  State<QueueScreen> createState() => _QueueScreenState();
}

class _QueueScreenState extends State<QueueScreen>
    with TickerProviderStateMixin {
  Map<String, dynamic>? currentServing;
  List<dynamic> waitingList = [];
  bool _isDisposed = false;
  Timer? _refreshTimer;
  Timer? _pollingTimer;
  Timer? _serveTimer;
  int _pollCounter = 0;
  int _secondsElapsed = 0;
  Timer? _uiTimer;
  bool _isUpdatingStatus = false;
  late AnimationController _blinkController;
  late Animation<double> _blinkAnimation;
  late AnimationController _glowController;
  late Animation<double> _glowAnimation;
  late bool _isActive;
  bool _isCallingNext = false;
  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;

    return "${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}";
  }

  String _getLiveTime() {
    final serving = currentServing;

    if (serving == null || serving["servedAt"] == null) {
      return "00:00";
    }

    final servedAtString = serving["servedAt"] as String?;

    if (servedAtString == null) {
      return "00:00";
    }

    final servedAt = DateTime.parse(servedAtString);
    final difference = DateTime.now().difference(servedAt);

    final minutes = difference.inMinutes;
    final seconds = difference.inSeconds % 60;

    return "${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}";
  }


  final String baseUrl = "http://192.168.1.41:8080/api";

  @override


  // ================= API =================

  Future<void> _loadQueue() async {
    if (_isDisposed) return;

    try {
      final response = await http
          .get(Uri.parse("$baseUrl/queue/${widget.serviceId}"))
          .timeout(const Duration(seconds: 8));

      if (_isDisposed || !mounted) return;

      if (response.statusCode != 200) {
        debugPrint("Queue API failed: ${response.statusCode}");
        return;
      }

      final raw = jsonDecode(response.body);

      final serving = raw["currentlyServing"] as Map<String, dynamic>?;
      final waiting = raw["waitingList"] as List? ?? [];
      final activeStatus = raw["active"] as bool? ?? false;

      if (_isDisposed || !mounted) return;

      setState(() {
        currentServing = serving;
        waitingList = waiting;
        _isActive = activeStatus;
      });

    } catch (e) {
      if (!_isDisposed && mounted) {
        debugPrint("Queue load error: $e");
      }
    }
  }

  Future<void> _toggleStatus(bool value) async {
    try {
      final response = await http.patch(
        Uri.parse("$baseUrl/services/${widget.serviceId}/status"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "isActive": value,
        }),
      );

      print("STATUS CODE: ${response.statusCode}");
      print("BODY: ${response.body}");

      if (response.statusCode == 200) {
        setState(() {
          _isActive = value;
        });
      } else {
        _showError("Failed to update service status.");
      }
    } catch (e) {
      print("ERROR: $e");
      _showError("Network error.");
    }
  }

  Future<void> _callNext() async {
    if (_isCallingNext) return;

    setState(() {
      _isCallingNext = true;
    });

    try {
      final response = await http.post(
        Uri.parse("$baseUrl/queue/${widget.serviceId}/call-next"),
      );

      if (response.statusCode == 200) {
        await _loadQueue();
      } else {
        debugPrint("Call next failed: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("Call next error: $e");
    } finally {
      if (mounted) {
        setState(() {
          _isCallingNext = false;
        });
      }
    }
  }
  Future<void> _serveCurrent() async {
    final serving = currentServing;

    if (serving == null) return;

    try {
      final response = await http.post(
        Uri.parse("$baseUrl/queue/${widget.serviceId}/complete-current"),
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        await _loadQueue(); // reload updated queue state
      } else {
        debugPrint("Complete current failed: ${response.statusCode}");
      }
    } catch (e) {
      if (mounted) {
        debugPrint("Serve error: $e");
      }
    }
  }

  Future<bool?> _showDeactivateDialog() {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.warning_amber_rounded,
                    color: Colors.red,
                    size: 32,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  "Deactivate Service?",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  "Users will not be able to join the queue while the service is inactive.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 28),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () {
                          Navigator.pop(context, false);
                        },
                        child: const Text("Cancel"),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFF6B6B), // light red
                          foregroundColor: Colors.white, // white text
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        onPressed: () {
                          Navigator.pop(context, true);
                        },
                        child: const Text(
                          "Deactivate",
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        );
      },
    );
  }

  // ================= TIMER =================



  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
  @override
  void initState() {
    super.initState();

    _loadQueue();

    _uiTimer = Timer.periodic(
      const Duration(seconds: 1),
          (_) {
        if (mounted) {

          _pollCounter++;

          if (_pollCounter % 5 == 0) {
            _loadQueue(); // refresh queue every 5 seconds
          }

          setState(() {});
        }
      },
    );

    _isActive = widget.isActive;
  }

  @override
  void dispose() {
    _uiTimer?.cancel();
    super.dispose();
  }
  void _showQrDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.serviceName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),

                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      )
                    ],
                  ),
                  child: QrImageView(
                    data: widget.serviceId.toString(),
                    version: QrVersions.auto,
                    size: 220,
                    backgroundColor: Colors.white,
                  ),
                ),

                const SizedBox(height: 20),

                Text(
                  "Scan to join queue",
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                  ),
                ),

                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4A6CF7),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Close"),
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }

  // ================= UI =================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FC),
      body: Column(
        children: [
          Text(
          _getLiveTime(),
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),

          // ===== Header =====
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(
              top: 60,
              bottom: 30,
              left: 20,
              right: 20,
            ),
            decoration: const BoxDecoration(
              color: Color(0xFFEFF2FF),
              borderRadius: BorderRadius.vertical(
                bottom: Radius.circular(28),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [

                // 🔙 Back Button
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(
                    Icons.arrow_back_ios_new,
                    color: Colors.indigo,
                  ),
                ),

                const SizedBox(width: 16),

                // 🏷 Service Name (Flexible)
                Expanded(
                  child: Text(
                    widget.serviceName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: Colors.indigo,
                    ),
                  ),
                ),

                // 🔳 Right Section (QR + Toggle grouped)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [

                    if (_isActive)
                      GestureDetector(
                        onTap: () {
                          _showQrDialog();
                        },
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 45,
                              height: 45,
                              decoration: BoxDecoration(
                                color: Colors.indigo.withOpacity(0.08),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.qr_code_rounded,
                                color: Colors.indigo,
                                size: 22,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "QR Code",
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey.shade500,
                                letterSpacing: 0.2,
                              ),
                            ),
                          ],
                        ),
                      ),


                      const SizedBox(width: 20),

                    // 🔥 ACTIVE TOGGLE
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: _isActive
                                ? Colors.green.withOpacity(0.1)
                                : Colors.red.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: _isActive ? Colors.green : Colors.red,
                            ),
                          ),
                          child: Text(
                            _isActive ? "Active" : "Inactive",
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: _isActive ? Colors.green : Colors.red,
                            ),
                          ),
                        ),

                        const SizedBox(width: 8),

                        Switch(
                          value: _isActive,
                          onChanged: (value) async {
                            if (!value) {
                              final confirm = await _showDeactivateDialog();
                              if (confirm == true) {
                                _toggleStatus(false);
                              }
                            } else {
                              _toggleStatus(true);
                            }
                          },
                          activeColor: Colors.white,
                          activeTrackColor: const Color(0xFF22C55E),
                          inactiveThumbColor: Colors.white,
                          inactiveTrackColor: Colors.grey.shade300,
                          materialTapTargetSize:
                          MaterialTapTargetSize.shrinkWrap,
                        )
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  /// ================= CURRENTLY SERVING =================
                  const Text(
                    "Currently Serving",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),

                  const SizedBox(height: 16),

                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0xFFE8F0FF),
                          Color(0xFFF4EDFF),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.06),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [

                        /// 👤 USER NAME
                        Text(
                          currentServing?["userName"] ??
                              "No customer being served",
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),

                        if (currentServing != null &&
                            currentServing?["status"] == "SERVING") ...[

                          const SizedBox(height: 6),

                          /// 🔢 TOKEN NUMBER
                          Text(
                            "Token #${currentServing?["tokenNumber"] ?? "-"}",
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade700,
                            ),
                          ),

                          const SizedBox(height: 14),

                          /// ⏱ LIVE TIMER (based on servedAt)

                        ],

                        const SizedBox(height: 24),

                        /// ACTION BUTTONS
                        Row(
                          children: [

                            /// MARK SERVED BUTTON
                            Expanded(
                              child: ElevatedButton(
                                onPressed: (currentServing != null &&
                                    currentServing?["status"] == "SERVING")
                                    ? () async {
                                  await _serveCurrent();

                                  if (mounted) {
                                    setState(() {
                                      currentServing = null;
                                    });
                                  }
                                }
                                    : null,
                                style: ElevatedButton.styleFrom(
                                  elevation: 0,
                                  backgroundColor: Colors.indigo,
                                  padding:
                                  const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                                child: const Text(
                                  "Mark Served",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(width: 14),

                            /// CALL NEXT BUTTON
                            Expanded(
                              child: ElevatedButton(
                                onPressed: _isCallingNext
                                    ? null
                                    : _callNext,
                                style: ElevatedButton.styleFrom(
                                  foregroundColor: Colors.white,
                                  backgroundColor: Colors.indigo,
                                  padding:
                                  const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                                child: _isCallingNext
                                    ? const SizedBox(
                                  height: 18,
                                  width: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                                    : const Text(
                                  "Call Next",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 36),

                  /// ================= WAITING LIST =================
                  const Text(
                    "Waiting in Queue",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),

                  const SizedBox(height: 16),

                  Expanded(
                    child: waitingList.isEmpty
                        ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(height: 14),
                          Text(
                            "No customers waiting",
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    )
                        : ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      itemCount: waitingList.length,
                      itemBuilder: (context, index) {
                        final user = waitingList[index];

                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          margin: const EdgeInsets.only(bottom: 16),
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(22),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 18,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [

                              /// 🔢 POSITION
                              Container(
                                width: 46,
                                height: 46,
                                decoration: BoxDecoration(
                                  color:
                                  Colors.indigo.withOpacity(0.08),
                                  shape: BoxShape.circle,
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  "${index + 1}",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.indigo,
                                  ),
                                ),
                              ),

                              const SizedBox(width: 16),

                              /// 👤 USER INFO
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      user["userName"] ?? "User",
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      "Token #${user["tokenNumber"] ?? "-"}",
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              Icon(
                                Icons.chevron_right_rounded,
                                color: Colors.grey.shade400,
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}