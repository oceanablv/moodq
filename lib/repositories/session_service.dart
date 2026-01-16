import 'package:shared_preferences/shared_preferences.dart';

class SessionService {
  Future<void> saveUser(Map<String, dynamic> user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('id', user['id'].toString());
    await prefs.setString('name', user['name'].toString());
    await prefs.setString('email', user['email'].toString());
  }

  Future<void> saveFromResponse(Map<String, dynamic> data) async {
    if (data.containsKey('user')) {
      final user = Map<String, dynamic>.from(data['user']);
      await saveUser(user);
    }
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey('id');
  }

  Future<Map<String, String>?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('id')) return null;
    return {
      'id': prefs.getString('id') ?? '',
      'name': prefs.getString('name') ?? '',
      'email': prefs.getString('email') ?? '',
    };
  }
}
