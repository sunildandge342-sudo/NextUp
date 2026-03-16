import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';

class FacebookAuthService {
  static Future<String?> signIn() async {
    try {
      final result = await FacebookAuth.instance.login(
        permissions: ['email', 'public_profile'],
      );

      if (result.status == LoginStatus.success) {
        return result.accessToken!.token; // 🔑 backend
      }
      return null;
    } catch (e) {
      print("Facebook login error: $e");
      return null;
    }
  }
}
