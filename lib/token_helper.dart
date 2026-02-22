import 'package:shared_preferences/shared_preferences.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

class TokenHelper {
  static Future<String?> getValidToken() async {
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    if (token == null) return null;

    if (JwtDecoder.isExpired(token)) {
      await prefs.remove('token');
      return null;
    }

    return token;
  }
}