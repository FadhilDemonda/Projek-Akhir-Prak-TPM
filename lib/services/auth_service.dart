import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';

class AuthService {
  static const String _userKey = 'user_data';
  static const String _isLoggedInKey = 'is_logged_in';

  // 🔄 Update user locally using SharedPreferences
  Future<void> updateUser(UserModel user) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('username', user.username);
  await prefs.setString('instansi', user.instansi);
  await prefs.setString('id', user.id);
  if (user.profileImageUrl != null) {
    await prefs.setString('profileImageUrl', user.profileImageUrl!);
  }
}

  // Login user (buat user baru tanpa id)
  Future<bool> login(String username, String instansi) async {
    try {
      // Create a user model without id (pakai constructor create)
      final user = UserModel.create(
        username: username,
        instansi: instansi,
      );

      // Store in shared preferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_userKey, jsonEncode(user.toMap()));
      await prefs.setBool(_isLoggedInKey, true);

      return true;
    } catch (e) {
      print('Login error: $e');
      return false;
    }
  }

  // Check if user is logged in
  Future<bool> isLoggedIn() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_isLoggedInKey) ?? false;
    } catch (e) {
      return false;
    }
  }

  // Get current user (pakai factory fromMap, id akan terbaca)
  Future<UserModel?> getCurrentUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userData = prefs.getString(_userKey);

      if (userData != null) {
        final userMap = jsonDecode(userData) as Map<String, dynamic>;
        return UserModel.fromMap(userMap);
      }
      return null;
    } catch (e) {
      print('Get user error: $e');
      return null;
    }
  }

  

  // Logout user
  Future<bool> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_isLoggedInKey, false);
      return true;
    } catch (e) {
      print('Logout error: $e');
      return false;
    }
  }
}
