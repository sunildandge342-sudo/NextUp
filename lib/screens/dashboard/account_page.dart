import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:nextup/screens/login_screen.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

// ===============================
// FULL UPDATED ACCOUNT PAGE CODE
// Email is VIEW ONLY (No Edit Icon)
// Nothing else changed
// ===============================

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

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
  bool editMobile = false;

  bool _isSaving = false;

  late String originalName;
  late String originalEmail;
  late String originalMobile;

  @override
  void initState() {
    super.initState();

    nameController = TextEditingController(text: widget.firstName);
    emailController = TextEditingController(text: widget.email);
    mobileController = TextEditingController(text: widget.mobile);

    originalName = widget.firstName;
    originalEmail = widget.email;
    originalMobile = widget.mobile;

    _loadUserProfile();
  }

  bool get _hasChanges {
    return nameController.text.trim() != originalName ||
        mobileController.text.trim() != originalMobile;
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    mobileController.dispose();
    super.dispose();
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
            const SizedBox(height: 20),

            const Text(
              "My Account",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w600,
                color: Colors.indigo,
              ),
            ),

            const SizedBox(height: 24),

            // ================= PROFILE CARD =================
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
                        width: 200,
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
                            color: Colors.black87,
                          ),
                          onChanged: (_) => setState(() {}),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit,
                            size: 18, color: Colors.indigo),
                        onPressed: () {
                          setState(() => editName = true);
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ================= EMAIL TILE (NO EDIT ICON) =================
            Container(
              margin: const EdgeInsets.only(bottom: 14),
              padding: const EdgeInsets.all(16),
              decoration: _cardDecoration(),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: Colors.indigo.withOpacity(0.12),
                    child: const Icon(Icons.email_outlined,
                        color: Colors.indigo, size: 20),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: TextField(
                      controller: emailController,
                      enabled: false, // 🔒 permanently disabled
                      decoration: const InputDecoration(
                        labelText: "Email",
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ================= MOBILE TILE =================
            _editableTile(
              title: "Mobile",
              icon: Icons.phone_outlined,
              controller: mobileController,
              enabled: editMobile,
              keyboardType: TextInputType.phone,
              onEdit: () {
                setState(() => editMobile = true);
              },
            ),

            const SizedBox(height: 30),

            // ================= SAVE BUTTON =================
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

            // ================= SEND FEEDBACK =================
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

            // ================= LOGOUT =================
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

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // ================= LOAD PROFILE =================
  Future<void> _loadUserProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) return;

    try {
      final response = await http.get(
        Uri.parse("http://192.168.1.41:8080/api/user/profile"),
        headers: {"Authorization": "Bearer $token"},
      );

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
    } catch (_) {}
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
    if (editMobile) body['mobile'] = mobileController.text.trim();

    try {
      final response = await http.put(
        Uri.parse("http://192.168.1.41:8080/api/user/profile"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        setState(() {
          originalName = nameController.text.trim();
          originalMobile = mobileController.text.trim();
          editName = false;
          editMobile = false;
        });
        _showSuccess("Profile updated successfully");
      } else {
        _showError("Update failed");
      }
    } catch (_) {
      _showError("Server not reachable");
    } finally {
      setState(() => _isSaving = false);
    }
  }

  // ================= EDITABLE TILE =================
  Widget _editableTile({
    required String title,
    required IconData icon,
    required TextEditingController controller,
    required bool enabled,
    required VoidCallback onEdit,
    TextInputType keyboardType = TextInputType.text,
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
              keyboardType: keyboardType,
              decoration: InputDecoration(
                labelText: title,
                border: InputBorder.none,
              ),
              onChanged: (_) => setState(() {}),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.edit,
                size: 16, color: Colors.indigo),
            onPressed: onEdit,
          ),
        ],
      ),
    );
  }

  // ================= UI DECORATION =================
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
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.redAccent,
      ),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showLogoutConfirmation() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Log out?"),
        content: const Text("Are you sure you want to log out?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _logout(context);
            },
            child: const Text("Logout"),
          ),
        ],
      ),
    );
  }

  void _logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
    );
  }

  Future<void> _sendFeedback() async {
    final String email = "sunil.cs24024@mmcc.edu.in";
    final String subject = "NextUp App Feedback";
    final String body =
        "Hello Team,%0D%0A%0D%0AName: ${nameController.text}%0D%0AEmail: ${emailController.text}%0D%0A";

    final Uri mailUri =
    Uri.parse("mailto:$email?subject=$subject&body=$body");

    try {
      await launchUrl(mailUri,
          mode: LaunchMode.externalApplication);
    } catch (_) {
      _showError("Unable to open email.");
    }
  }
}
