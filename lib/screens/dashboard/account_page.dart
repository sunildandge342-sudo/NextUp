import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:nextup/screens/login_screen.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AccountPage extends StatefulWidget {
  final String firstName;
  final String email;
  final String mobile;

  const AccountPage({
    super.key,
    required this.firstName,
    required this.email,
    required this.mobile,
  });

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  late TextEditingController nameController;
  late TextEditingController emailController;
  late TextEditingController mobileController;

  bool editName = false;
  bool editEmail = false;
  bool editMobile = false;

  bool _isSaving = false;

  late String originalName;
  late String originalEmail;
  late String originalMobile;

  @override
  void initState() {
    super.initState();

    // Initial values (fallback / instant UI)
    nameController = TextEditingController(text: widget.firstName);
    emailController = TextEditingController(text: widget.email);
    mobileController = TextEditingController(text: widget.mobile);


    originalName = widget.firstName;
    originalEmail = widget.email;
    originalMobile = widget.mobile;

    // ✅ FETCH REAL DATA FROM BACKEND
    _loadUserProfile();
  }

  bool get _hasChanges {
    return nameController.text.trim() != originalName ||
        emailController.text.trim() != originalEmail ||
        mobileController.text.trim() != originalMobile;
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


  @override
  Widget build(BuildContext context) {
    final firstLetter =
    nameController.text.isNotEmpty ? nameController.text[0].toUpperCase() : "?";

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 10),
            const Text(
              "My Account",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w600,
                color: Colors.indigo,
              ),
            ),
            const SizedBox(height: 24),

            /// PROFILE CARD
            Container(
              padding: const EdgeInsets.symmetric(vertical: 24),
              decoration: _cardDecoration(),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.indigo.withOpacity(0.15),
                    child: Text(
                      firstLetter,
                      style: const TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: Colors.indigo,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 180,
                        child: TextField(
                          controller: nameController,
                          readOnly: !editName,
                          textAlign: TextAlign.center,
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                          ),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87, // ✅ ONLY CHANGE
                          ),
                          onChanged: (_) => setState(() {}),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit, size: 16),
                        color: Colors.indigo,
                        onPressed: () => setState(() => editName = true),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    "USER",
                    style: TextStyle(
                      color: Colors.grey,
                      letterSpacing: 1.5,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            _editableTile(
              title: "Email",
              icon: Icons.email_outlined,
              controller: emailController,
              enabled: editEmail,
              onEdit: () => setState(() => editEmail = true),
            ),

            _editableTile(
              title: "Mobile",
              icon: Icons.phone_outlined,
              controller: mobileController,
              enabled: editMobile,
              keyboardType: TextInputType.phone,
              onEdit: () => setState(() => editMobile = true),
            ),

            const SizedBox(height: 30),

            /// SAVE BUTTON
            if (_hasChanges)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _saveChanges,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE8EDFF),
                    foregroundColor: Colors.indigo,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: _isSaving
                      ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                      : const Text(
                    "Save changes",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

            const SizedBox(height: 16),

            /// SEND FEEDBACK
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.feedback_outlined, size: 18),
                label: const Text(
                  "Send Feedback",
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF1F3F9),
                  foregroundColor: Colors.indigo,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: _sendFeedback,
              ),
            ),

            const SizedBox(height: 12),

            /// LOGOUT
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.logout, size: 18),
                label: const Text(
                  "Logout",
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFDECEA),
                  foregroundColor: const Color(0xFFD32F2F),
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: _showLogoutConfirmation,
              ),
            ),
          ],
        ),
      ),
    );

  }
  // ================= LOAD USER PROFILE =================
  Future<void> _loadUserProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    print("🔑 TOKEN FROM STORAGE: $token");

    if (token == null) {
      print("❌ TOKEN IS NULL");
      return;
    }

    try {
      final response = await http.get(
        Uri.parse("http://192.168.1.40:8080/api/user/profile"),
        headers: {
          "Authorization": "Bearer $token",
        },
      );

      print("📡 STATUS CODE: ${response.statusCode}");
      print("📦 RESPONSE BODY: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        setState(() {
          nameController.text = data['name'] ?? nameController.text;
          emailController.text = data['email'] ?? emailController.text;
          mobileController.text = data['mobile'] ?? mobileController.text;

          originalName = nameController.text;
          originalEmail = emailController.text;
          originalMobile = mobileController.text;
        });
      }
    } catch (e) {
      print("🔥 ERROR: $e");
    }
  }


  // ================= SAVE CHANGES =================
  Future<void> _saveChanges() async {
    setState(() => _isSaving = true);



    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) {
      _showError("Session expired. Please login again.");
      setState(() => _isSaving = false);
      return;
    }
    final Map<String, dynamic> body = {};
    if (editName) body['name'] = nameController.text.trim();
    if (editEmail) body['email'] = emailController.text.trim();
    if (editMobile) body['mobile'] = mobileController.text.trim();
    // ❌ password removed from profile update

    try {
      final response = await http.put(
        Uri.parse("http://http://192.168.1.40:8080/api/user/profile"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        setState(() {
          originalName = nameController.text.trim();
          originalEmail = emailController.text.trim();
          originalMobile = mobileController.text.trim();
          editName = editEmail = editMobile = false;
        });
        _showSuccess("Profile updated successfully");
      } else {
        _showError("Update failed (${response.statusCode})");
      }
    } catch (_) {
      _showError("Server not reachable");
    } finally {
      setState(() => _isSaving = false);
    }
  }

  Future<bool> _changePasswordApi(String oldPassword, String newPassword) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) {
      _showError("Session expired. Please login again.");
      return false;
    }

    try {
      final response = await http.put(
        Uri.parse("http://192.168.1.40:8080/api/user/reset-password"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({
          "oldPassword": oldPassword,
          "newPassword": newPassword,
        }),
      );

      print("🔐 STATUS: ${response.statusCode}");
      print("🔐 BODY: ${response.body}");

      return response.statusCode == 200;
    } catch (e) {
      _showError("Server not reachable");
      return false;
    }
  }
  // ================= LOGOUT CONFIRMATION =================
  void _showLogoutConfirmation() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(22),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: Colors.red.withOpacity(0.12),
                  child: const Icon(
                    Icons.logout,
                    color: Colors.red,
                    size: 28,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  "Log out?",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Are you sure you want to log out?",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 22),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        onPressed: () => Navigator.pop(context),
                        child: const Text("Cancel"),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                          _logout(context);
                        },
                        child: const Text(
                          "Logout",
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }


  // ================= LOGOUT =================
  void _logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
    );
  }
  // ================= SEND FEEDBACK =================

  Future<void> _sendFeedback() async {
    final String email = "sunil.cs24024@mmcc.edu.in";
    final String subject = "NextUp App Feedback";
    final String body =
        "Hello Team,%0D%0A%0D%0A"
        "I would like to share the following feedback:%0D%0A%0D%0A"
        "-------------------------%0D%0A"
        "Name: ${nameController.text}%0D%0A"
        "Email: ${emailController.text}%0D%0A"

        "-------------------------%0D%0A%0D%0A";

    // 1️⃣ Try default mail app
    final Uri mailUri = Uri.parse(
      "mailto:$email?subject=$subject&body=$body",
    );

    try {
      if (await launchUrl(
        mailUri,
        mode: LaunchMode.externalApplication,
      )) {
        return;
      }
    } catch (_) {}

    // 2️⃣ Try Gmail app directly (Android)
    final Uri gmailUri = Uri.parse(
      "googlegmail://co?to=$email&subject=$subject&body=$body",
    );

    try {
      if (await launchUrl(
        gmailUri,
        mode: LaunchMode.externalApplication,
      )) {
        return;
      }
    } catch (_) {}

    // 3️⃣ Fallback → Gmail Web
    final Uri gmailWebUri = Uri.parse(
      "https://mail.google.com/mail/?view=cm&to=$email&su=$subject&body=$body",
    );

    if (await launchUrl(
      gmailWebUri,
      mode: LaunchMode.externalApplication,
    )) {
      return;
    }

    _showError("Unable to open email. Please try again later.");
  }

  // ================= COMMON UI =================
  Widget _editableTile({
    required String title,
    required IconData icon,
    required TextEditingController controller,
    required bool enabled,
    required VoidCallback onEdit,
    TextInputType keyboardType = TextInputType.text,
    bool obscure = false,
    String? placeholder,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: Colors.indigo.withOpacity(0.12),
            child: Icon(icon, color: Colors.indigo, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: TextField(
              controller: controller,
              enabled: enabled,
              obscureText: obscure,
              keyboardType: keyboardType,
              decoration: InputDecoration(
                labelText: title,
                hintText: placeholder,
                border: InputBorder.none,
              ),
              onChanged: (_) => setState(() {}),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.edit, size: 16, color: Colors.indigo),
            onPressed: onEdit,
          ),
        ],
      ),
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      boxShadow: const [
        BoxShadow(
          color: Colors.black12,
          blurRadius: 8,
          offset: Offset(0, 4),
        ),
      ],
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.redAccent),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }
}
