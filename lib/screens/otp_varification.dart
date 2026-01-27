import 'package:flutter/material.dart';

import 'reset_password.dart';
import 'package:nextup/services/api_services.dart';

class OtpVerificationScreen extends StatefulWidget {
  final String email;
  const OtpVerificationScreen({super.key, required this.email});

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final TextEditingController otpController = TextEditingController();

  bool isLoading = false;

  Future<void> verifyOtp() async {
    final otp = otpController.text.trim();

    if (otp.isEmpty) {
      _showSnack("Please enter OTP");
      return;
    }

    setState(() => isLoading = true);
    final res = await ApiService.verifyOtp(widget.email, otp);
    setState(() => isLoading = false);

    if (res["message"] != null &&
        res["message"].toString().toLowerCase().contains("verified")) {
      final resetToken = res["resetToken"];

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ResetPasswordScreen(
            resetToken: resetToken,
          ),
        ),
      );
    } else {
      _showSnack(res["message"] ?? "Invalid OTP");
    }
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool canVerify = otpController.text.trim().isNotEmpty && !isLoading;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        title: const Text("Verify OTP"),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 12,
                  offset: Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Icon(
                  Icons.mark_email_read_outlined,
                  size: 48,
                  color: Colors.deepPurple,
                ),
                const SizedBox(height: 14),

                const Text(
                  "OTP Verification",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  "Enter the 6-digit OTP sent to\n${widget.email}",
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 13,
                  ),
                ),

                const SizedBox(height: 24),

                /// OTP FIELD
                TextField(
                  controller: otpController,
                  keyboardType: TextInputType.number,
                  maxLength: 6,
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    labelText: "Enter OTP",
                    prefixIcon: const Icon(Icons.lock_outline),
                    counterText: "",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),

                const SizedBox(height: 28),

                /// VERIFY BUTTON (LIGHT & CLEAN)
                SizedBox(
                  height: 48,
                  child: GestureDetector(
                    onTap: canVerify ? verifyOtp : null,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        gradient: canVerify
                            ? const LinearGradient(
                          colors: [
                            Color(0xFF9C6BFF), // soft purple
                            Color(0xFF6EC6FF), // soft blue
                          ],
                        )
                            : LinearGradient(
                          colors: [
                            Colors.grey.shade200,
                            Colors.grey.shade200,
                          ],
                        ),
                        boxShadow: canVerify
                            ? [
                          BoxShadow(
                            color:
                            const Color(0xFF9C6BFF).withOpacity(0.45),
                            blurRadius: 22,
                            spreadRadius: 1.5,
                            offset: const Offset(0, 6),
                          ),
                          BoxShadow(
                            color:
                            const Color(0xFF6EC6FF).withOpacity(0.35),
                            blurRadius: 30,
                            spreadRadius: 2,
                            offset: const Offset(0, 10),
                          ),
                        ]
                            : [],
                      ),
                      child: Center(
                        child: isLoading
                            ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Colors.white,
                          ),
                        )
                            : Text(
                          "Verify OTP",
                          style: TextStyle(
                            color: canVerify
                                ? Colors.white
                                : Colors.grey.shade500,
                            fontSize: 15.5,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

              ],
            ),
          ),
        ),
      ),
    );
  }
}

