import 'package:flutter/material.dart';
import 'package:nextup/screens/dashboard/dashboard_screen.dart';
import 'package:nextup/services/api_services.dart';
import 'package:shared_preferences/shared_preferences.dart'; // ✅ ADDED
import 'admin_dashboard.dart';
import 'package:nextup/screens/dashboard/dashboard_screen.dart';
import 'signup_screen.dart';
import 'forget_password_email.dart';
import 'package:nextup/services/google_auth_service.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';


class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool isLoading = false;
  bool rememberMe = false;

  Future<void> handleLogin() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter both email and password')),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      final res = await ApiService.login(email, password);
      setState(() => isLoading = false);

      // ✅ FIX: check success + use data object
      if (res["success"] == true && res["data"] != null) {
        final data = res["data"];

        if (data["token"] != null) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('token', data["token"]);
        }

        final role = data["role"].toString().toUpperCase();
        final userId = int.tryParse(data["userId"].toString()) ?? 0;

        if (role == 'SERVICE_PROVIDER') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const AdminDashboard()),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => UserDashboard(userId: userId),
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Invalid email or password',
            ),
          ),
        );
      }
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Login failed: $e')),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FF),
      body: Stack(
        children: [
          // 🔵 Decorative Circle (Top Left)
          Positioned(
            top: -80,
            left: -80,
            child: Container(
              height: 220,
              width: 220,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [Color(0xFF6A8CFF), Color(0xFF4A6CF7)],
                ),
              ),
            ),
          ),

          // 🔳 Main Card
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(26),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 24,
                      offset: const Offset(0, 14),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 🔠 Title
                    const Text(
                      "Welcome back",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2C3E50),
                      ),
                    ),
                    const SizedBox(height: 30),

                    // 📧 Email
                    _buildInputField(
                      controller: emailController,
                      label: "Email",
                      icon: Icons.email_outlined,
                    ),
                    const SizedBox(height: 18),

                    // 🔒 Password
                    _buildInputField(
                      controller: passwordController,
                      label: "Password",
                      icon: Icons.lock_outline,
                      obscure: true,
                    ),
                    const SizedBox(height: 14),

                    // 🔁 Remember / Forgot
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Checkbox(
                              value: rememberMe,
                              activeColor: const Color(0xFF4A6CF7),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4),
                              ),
                              onChanged: (v) =>
                                  setState(() => rememberMe = v ?? false),
                            ),
                            const Text("Remember me"),
                          ],
                        ),
                        TextButton(
                          onPressed: () {

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const ForgotPasswordEmailScreen(),
                              ),
                            );
                          },
                          child: const Text(
                            "Forgot password?",
                            style: TextStyle(color: Color(0xFF4A6CF7)),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),

                    // 🔵 Sign In Button
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        onPressed: isLoading ? null : handleLogin,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4A6CF7),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 4,
                        ),
                        child: isLoading
                            ? const CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.5,
                        )
                            : const Text(
                          "Sign in",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.3,
                            color: Colors.white,
                          ),
                        ),

                      ),
                    ),

                    const SizedBox(height: 26),
                    const Text("Sign in with"),
                    const SizedBox(height: 14),

                    // 🌐 Social Icons
                    Row(
                      children: [
                        Expanded(
                          child: _socialButton(
                            asset: 'assets/icons/google.png',
                            label: 'Google',
                            onTap: () async {
                              final token = await GoogleAuthService.signIn();

                              if (token == null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text("Google sign-in failed")),
                                );
                                return;
                              }

                              final data = await ApiService.socialLogin("GOOGLE", token);

                              if (data == null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text("Social login failed")),
                                );
                                return;
                              }

                              // ✅ SAVE JWT
                              final prefs = await SharedPreferences.getInstance();
                              await prefs.setString('token', data['token']);
                              await prefs.setInt('userId', data['userId']);
                              await prefs.setString('role', data['role']);

                              final role = data['role'].toString().toUpperCase();
                              final userId = data['userId'] as int;

                              // ✅ NAVIGATE
                              if (role == 'SERVICE_PROVIDER') {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(builder: (_) => const AdminDashboard()),
                                );
                              } else {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => UserDashboard(userId: userId),
                                  ),
                                );
                              }
                            },


                          ),
                        ),


                      ],
                    ),


                    const SizedBox(height: 28),

                    // 🔗 Sign Up
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const SignUpScreen(),
                          ),
                        );
                      },
                      child: const Text.rich(
                        TextSpan(
                          text: "Don’t have an account? ",
                          style: TextStyle(fontSize: 16),
                          children: [
                            TextSpan(
                              text: "Sign up",
                              style: TextStyle(
                                color: Color(0xFF4A6CF7),
                                fontWeight: FontWeight.bold,
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
          ),
        ],
      ),
    );
  }

  // 🔹 Input field component
  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscure = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        filled: true,
        fillColor: const Color(0xFFF8F9FD),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFE0E6F5)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide:
          const BorderSide(color: Color(0xFF4A6CF7), width: 1.5),
        ),
      ),
    );
  }

  // 🔹 Social icon
  Widget _socialButton({
    required String asset,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: const Color(0xFFE2E6F3),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              asset,
              height: 22,
              width: 22,
            ),
            const SizedBox(width: 10),
            Text(
              label,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: Color(0xFF2C3E50),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


