import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static Future<SharedPreferences> _getPrefs() async {
    return await SharedPreferences.getInstance();
  }

  static Future<String> getAuthBearerToken() async {
    final prefs = await _getPrefs();
    return prefs.getString('token') ?? '';
  }

  static Future<bool> setAuthBearerToken(String token) async {
    final prefs = await _getPrefs();
    return prefs.setString('token', token);
  }
}
