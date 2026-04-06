import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String _sessionKey = 'isLoggedIn';
  static const String _currentUserKey = 'currentUser';
  static const String _usersListKey = 'users_list';

  Future<bool> register(String email, String password) async {
    final prefs = await SharedPreferences.getInstance();
    
    List<String> users = prefs.getStringList(_usersListKey) ?? [];
    
    if (users.contains(email)) {
      return false; // User already exists
    }
    
    users.add(email);
    await prefs.setStringList(_usersListKey, users);
    
    await prefs.setString('password_$email', password);
    
    return true; 
  }

  Future<bool> login(String email, String password) async {
    final prefs = await SharedPreferences.getInstance();
    
    List<String> users = prefs.getStringList(_usersListKey) ?? [];
    
    if (users.contains(email)) {
      final savedPassword = prefs.getString('password_$email');
      if (savedPassword != null && savedPassword == password) {
        await prefs.setBool(_sessionKey, true);
        await prefs.setString(_currentUserKey, email);
        return true;
      }
    }
    return false;
  }

  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_sessionKey) ?? false;
  }

  Future<String?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_currentUserKey);
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_sessionKey, false);
    await prefs.remove(_currentUserKey);
  }
}
