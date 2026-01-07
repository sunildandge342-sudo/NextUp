import 'package:flutter/material.dart';
import 'package:nextup/screens/dashboard/dashboard_screen.dart';
import 'package:nextup/services/api_services.dart';
import 'package:shared_preferences/shared_preferences.dart'; // ✅ ADDED
import 'admin_dashboard.dart';
import 'signup_screen.dart';

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

    // ✅ Validation check (UNCHANGED)
    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter both email and password')),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      final data = await ApiService.login(email, password);

      setState(() => isLoading = false);

      if (data != null && data['role'] != null) {
        // =================== 🔐 ADDED PART ===================
        // Save JWT token (REQUIRED for account page)
        if (data['token'] != null) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('token', data['token']);
        }
        // =====================================================

        final String role = data['role'].toString().toUpperCase();
        final int userId = data['userId'] is int
            ? data['userId']
            : int.tryParse(data['userId'].toString()) ?? 0;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Welcome, $role!')),
        );

        if (role == 'ADMIN') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const AdminDashboard()),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => UserDashboard(userId: userId),
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid Email or Password')),
        );
      }
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xFFF2F5FF),
      body: SingleChildScrollView(
        child: SizedBox(
          height: height,
          width: width,
          child: Stack(
            children: [
              Positioned(
                top: -50,
                left: -50,
                child: Container(
                  height: 200,
                  width: 200,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [Color(0xFF4A6CF7), Color(0xFF6A9CFF)],
                    ),
                  ),
                ),
              ),
              Align(
                alignment: Alignment.center,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Container(
                    padding: const EdgeInsets.all(28),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          "Welcome back",
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2C3E50),
                          ),
                        ),
                        const SizedBox(height: 30),

                        // Email field
                        TextField(
                          controller: emailController,
                          decoration: InputDecoration(
                            labelText: "Email",
                            prefixIcon: const Icon(Icons.email_outlined),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            filled: true,
                            fillColor: const Color(0xFFF8F9FB),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Password field
                        TextField(
                          controller: passwordController,
                          obscureText: true,
                          decoration: InputDecoration(
                            labelText: "Password",
                            prefixIcon: const Icon(Icons.lock_outline),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            filled: true,
                            fillColor: const Color(0xFFF8F9FB),
                          ),
                        ),
                        const SizedBox(height: 10),

                        // Remember me & Forgot password (UNCHANGED)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Checkbox(
                                  value: rememberMe,
                                  onChanged: (value) {
                                    setState(() => rememberMe = value ?? false);
                                  },
                                ),
                                const Text("Remember me"),
                              ],
                            ),
                            TextButton(
                              onPressed: () {},
                              child: const Text(
                                "Forgot password?",
                                style: TextStyle(color: Color(0xFF4A6CF7)),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Sign in button
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: isLoading ? null : handleLogin,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF4A6CF7),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: isLoading
                                ? const CircularProgressIndicator(
                              color: Colors.white,
                            )
                                : const Text(
                              "Sign in",
                              style: TextStyle(
                                  fontSize: 18, color: Colors.white),
                            ),
                          ),
                        ),
                        const SizedBox(height: 25),

                        // Social sign-in (UNCHANGED)
                        const Text("Sign in with"),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildSocialImage(
                                'assets/icons/facebook.png', Colors.white),
                            const SizedBox(width: 15),
                            _buildSocialImage(
                                'assets/icons/google.png', Colors.white),
                            const SizedBox(width: 15),
                            _buildSocialImage(
                                'assets/icons/apple.png', Colors.white),
                            const SizedBox(width: 15),
                            _buildSocialImage(
                                'assets/icons/x.png', Colors.white),
                          ],
                        ),
                        const SizedBox(height: 30),

                        // Sign up text (UNCHANGED)
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                  const SignUpScreen()),
                            );
                          },
                          child: RichText(
                            text: const TextSpan(
                              text: "Don’t have an account? ",
                              style: TextStyle(
                                color: Colors.black87,
                                fontSize: 18,
                              ),
                              children: [
                                TextSpan(
                                  text: "Sign up",
                                  style: TextStyle(
                                    color: Color(0xFF4A6CF7),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
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
        ),
      ),
    );
  }

  /// Helper for social icons
  Widget _buildSocialImage(String assetPath, Color bgColor) {
    return Container(
      height: 50,
      width: 50,
      decoration: BoxDecoration(
        color: bgColor,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 6,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Image.asset(assetPath, fit: BoxFit.contain),
      ),
    );
  }
}

