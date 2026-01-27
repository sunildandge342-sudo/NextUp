import 'package:flutter/material.dart';
import 'package:nextup/services/api_services.dart';
import 'otp_varification.dart';

class ResetPasswordScreen extends StatefulWidget {
  final String resetToken;

  const ResetPasswordScreen({
    super.key,
    required this.resetToken,
  });

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}


class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final passController = TextEditingController();
  final confirmController = TextEditingController();

  bool showPassword = false;
  bool showConfirmPassword = false;
  bool isLoading = false;

  bool showConstraints = false;
  bool isPasswordValid = false;
  bool isConfirmValid = false;

  /// 🔐 Password validation
  bool validatePassword(String password) {
    final regex = RegExp(
      r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&#]).{8,}$',
    );
    return regex.hasMatch(password);
  }

  void onPasswordChanged(String value) {
    setState(() {
      isPasswordValid = validatePassword(value);
      showConstraints = value.isNotEmpty && !isPasswordValid;
      isConfirmValid = value == confirmController.text.trim();
    });
  }

  void onConfirmChanged(String value) {
    setState(() {
      isConfirmValid = value == passController.text.trim();
    });
  }

  Future<void> resetPassword() async {
    if (!isPasswordValid || !isConfirmValid || isLoading) return;

    setState(() => isLoading = true);

    final res = await ApiService.resetPassword(
      widget.resetToken, // ✅ correct
      passController.text.trim(),
    );

    setState(() => isLoading = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(res["message"] ?? "Something went wrong")),
    );

    if (res["message"] != null &&
        res["message"].toString().contains("successful")) {
      Navigator.popUntil(context, (route) => route.isFirst);
    }
  }


  @override
  Widget build(BuildContext context) {
    final bool canSubmit = isPasswordValid && isConfirmValid;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        title: const Text("Reset Password"),
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
                )
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Icon(Icons.lock_reset,
                    size: 48, color: Colors.deepPurple),
                const SizedBox(height: 14),

                const Text(
                  "Create New Password",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 24),

                /// New Password
                TextField(
                  controller: passController,
                  obscureText: !showPassword,
                  onChanged: onPasswordChanged,
                  decoration: InputDecoration(
                    labelText: "New Password",
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(showPassword
                          ? Icons.visibility
                          : Icons.visibility_off),
                      onPressed: () =>
                          setState(() => showPassword = !showPassword),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),

                /// 🔐 Constraints (ONLY WHEN INVALID)
                if (showConstraints) ...[
                  const SizedBox(height: 10),
                  const Text(
                    "Password must contain:",
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    "• Minimum 8 characters\n"
                        "• 1 uppercase letter\n"
                        "• 1 lowercase letter\n"
                        "• 1 number\n"
                        "• 1 special character",
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                      height: 1.4,
                    ),
                  ),
                ],

                const SizedBox(height: 18),

                /// Confirm Password
                TextField(
                  controller: confirmController,
                  obscureText: !showConfirmPassword,
                  onChanged: onConfirmChanged,
                  decoration: InputDecoration(
                    labelText: "Confirm Password",
                    prefixIcon: const Icon(Icons.lock),
                    suffixIcon: IconButton(
                      icon: Icon(showConfirmPassword
                          ? Icons.visibility
                          : Icons.visibility_off),
                      onPressed: () => setState(
                              () => showConfirmPassword = !showConfirmPassword),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                /// 🔘 BUTTON (ALWAYS VISIBLE)
                SizedBox(
                  height: 48,
                  child: GestureDetector(
                    onTap: canSubmit ? resetPassword : null,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeInOut,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        gradient: canSubmit
                            ? const LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
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
                        boxShadow: canSubmit
                            ? [
                          BoxShadow(
                            color: const Color(0xFF9C6BFF).withOpacity(0.25),
                            blurRadius: 12,
                            offset: const Offset(0, 6),
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
                          "Reset Password",
                          style: TextStyle(
                            color: canSubmit
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


