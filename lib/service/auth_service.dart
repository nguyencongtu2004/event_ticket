import 'package:event_ticket/enum.dart';
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

  static Future<bool> removeAuthBearerToken() async {
    final prefs = await _getPrefs();
    return prefs.remove('token');
  }

  static Future<bool> setRole(Roles role) async {
    final prefs = await _getPrefs();
    return prefs.setString('role', role.name); // set name of role
  }

  static Future<Roles> getRole() async {
    final prefs = await _getPrefs();
    final role = prefs.getString('role');
    if (role == null) return Roles.ticketBuyer;
    return Roles.values.firstWhere((e) => e.name == role);
  }

  static Future<bool> removeRole() async {
    final prefs = await _getPrefs();
    return prefs.remove('role');
  }
}
