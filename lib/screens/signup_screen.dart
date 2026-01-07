import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'login_screen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool _isLoading = false;
  bool _obscure = true;
  bool _validateNow = false;

  final String baseUrl = "http://192.168.1.40:8080/api/auth/signup";

  // ================= VALIDATION HELPERS =================

  bool _isValidEmail(String email) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email);
  }

  bool _isValidPhone(String phone) {
    final phoneRegex = RegExp(r'^[6-9]\d{9}$'); // Indian format
    return phoneRegex.hasMatch(phone);
  }

  bool _isStrongPassword(String password) {
    final hasUpper = RegExp(r'[A-Z]').hasMatch(password);
    final hasLower = RegExp(r'[a-z]').hasMatch(password);
    final hasDigit = RegExp(r'[0-9]').hasMatch(password);
    final hasSpecial = RegExp(r'[!@#\$&*~]').hasMatch(password);

    return password.length >= 8 &&
        hasUpper &&
        hasLower &&
        hasDigit &&
        hasSpecial;
  }

  // ================= REGISTER USER =================

  Future<void> _registerUser() async {
    setState(() => _validateNow = true);
    print("📡 URL: $baseUrl");

    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final url = Uri.parse(baseUrl);
    final headers = {'Content-Type': 'application/json'};
    final Map<String, dynamic> body = {
      "name": nameController.text.trim(),
      "email": emailController.text.trim(),
      "password": passwordController.text.trim(),
      "phone": phoneController.text.trim(),
    };

    try {
      final response =
      await http.post(url, headers: headers, body: jsonEncode(body));

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("✅ Account created successfully")),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
      } else {
        final error = jsonDecode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("❌ ${error['message']}")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("⚠️ Server not reachable")),
      );
    }

    setState(() => _isLoading = false);
  }

  // ================= UI =================

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    return Scaffold(
      backgroundColor: const Color(0xFFF2F5FF),
      body: SafeArea(
        child: Stack(
          children: [
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Opacity(
                opacity: 0.4,
                child: Image.asset(
                  'assets/images/signup.png',
                  fit: BoxFit.cover,
                  height: media.size.height * 0.38,
                ),
              ),
            ),
            SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Column(
                children: [
                  SizedBox(height: media.size.height * 0.16),
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 18,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Text(
                            'Create Account',
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF263238),
                            ),
                          ),
                          const SizedBox(height: 18),
                          Form(
                            key: _formKey,
                            autovalidateMode: _validateNow
                                ? AutovalidateMode.always
                                : AutovalidateMode.disabled,
                            child: Column(
                              children: [
                                _buildField(
                                  controller: nameController,
                                  label: 'Full Name',
                                  icon: Icons.person_outline,
                                  validator: (v) =>
                                  v == null || v.trim().isEmpty
                                      ? 'Full name is required'
                                      : null,
                                ),
                                const SizedBox(height: 12),
                                _buildField(
                                  controller: emailController,
                                  label: 'Email',
                                  icon: Icons.email_outlined,
                                  keyboardType: TextInputType.emailAddress,
                                  validator: (v) {
                                    if (v == null || v.trim().isEmpty) {
                                      return 'Email is required';
                                    }
                                    if (!_isValidEmail(v.trim())) {
                                      return 'Enter a valid email address';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 12),
                                _buildField(
                                  controller: phoneController,
                                  label: 'Phone Number',
                                  icon: Icons.phone_outlined,
                                  keyboardType: TextInputType.phone,
                                  validator: (v) {
                                    if (v == null || v.trim().isEmpty) {
                                      return 'Phone number is required';
                                    }
                                    if (!_isValidPhone(v.trim())) {
                                      return 'Enter valid 10-digit mobile number';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 12),
                                TextFormField(
                                  controller: passwordController,
                                  obscureText: _obscure,
                                  decoration: InputDecoration(
                                    labelText: 'Password',
                                    prefixIcon: const Icon(Icons.lock_outline,
                                        color: Color(0xFF4A6CF7)),
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        _obscure
                                            ? Icons.visibility_off
                                            : Icons.visibility,
                                        color: const Color(0xFF4A6CF7),
                                      ),
                                      onPressed: () => setState(
                                              () => _obscure = !_obscure),
                                    ),
                                    filled: true,
                                    fillColor: const Color(0xFFF8F9FB),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: const BorderSide(
                                          color: Colors.transparent),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: const BorderSide(
                                          color: Color(0xFF4A6CF7),
                                          width: 1.6),
                                    ),
                                  ),
                                  validator: (v) {
                                    if (v == null || v.trim().isEmpty) {
                                      return 'Password is required';
                                    }
                                    if (!_isStrongPassword(v.trim())) {
                                      return 'Password must include:\n'
                                          '• 8+ characters\n'
                                          '• Uppercase & lowercase\n'
                                          '• Number\n'
                                          '• Special character';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 16),
                                SizedBox(
                                  width: double.infinity,
                                  height: 52,
                                  child: ElevatedButton(
                                    onPressed:
                                    _isLoading ? null : _registerUser,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                      const Color(0xFF4A6CF7),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    child: _isLoading
                                        ? const CircularProgressIndicator(
                                        color: Colors.white)
                                        : const Text(
                                      'Sign Up',
                                      style: TextStyle(
                                          fontSize: 17,
                                          fontWeight: FontWeight.w600),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextButton(
                    onPressed: () => Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const LoginScreen()),
                    ),
                    child: const Text.rich(
                      TextSpan(
                        text: 'Already have an account? ',
                        style: TextStyle(color: Colors.black87, fontSize: 16),
                        children: [
                          TextSpan(
                            text: 'Sign in',
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
          ],
        ),
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: const Color(0xFF4A6CF7)),
        filled: true,
        fillColor: const Color(0xFFF8F9FB),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.transparent),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
          const BorderSide(color: Color(0xFF4A6CF7), width: 1.6),
        ),
        contentPadding:
        const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      ),
      validator: validator ??
              (v) => v == null || v.trim().isEmpty ? 'Enter $label' : null,
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}






