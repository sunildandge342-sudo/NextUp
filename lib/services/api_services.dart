import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // ⚙️ Replace with your backend IP and port
  static const String baseUrl = "http://192.168.1.40:8080";

  /// ✅ Generic POST request for reusability
  static Future<Map<String, dynamic>> postRequest(
      Uri url, Map<String, dynamic> body) async {
    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );

      // Success (200 or 201)
      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      }

      // Other responses (400, 500, etc.)
      return {
        "success": false,
        "message": "Error ${response.statusCode}: ${response.body}"
      };
    } catch (e) {
      return {"success": false, "message": "Network Error: $e"};
    }
  }

  /// 🔐 Login function (used by LoginScreen)
  static Future<Map<String, dynamic>?> login(
      String email, String password) async {
    final url = Uri.parse("$baseUrl/api/auth/login");

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email, "password": password}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data;
      } else {
        print("❌ LOGIN FAILED: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      print("⚠️ LOGIN NETWORK ERROR: $e");
      return null;
    }
  }
  static Future<String> bookToken(int userId, String serviceName) async {
    final response = await http.post(
      Uri.parse("$baseUrl/token/book"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"userId": userId, "serviceName": serviceName}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return "Token #${data['tokenNumber']} booked.\nPosition: ${data['position']}\nEstimated time: ${data['estimatedTime']}";
    } else {
      return "Failed to book token.";
    }
  }

  static Future<List<Map<String, dynamic>>> getMyTokens(int userId) async {
    final response = await http.get(Uri.parse("$baseUrl/token/my-tokens/$userId"));
    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(jsonDecode(response.body));
    }
    return [];
  }
  static Future<Map<String, dynamic>> submitFeedback(Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse("$baseUrl/feedback"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(data),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      return {"message": "Error: ${response.body}"};
    }
  }

}

