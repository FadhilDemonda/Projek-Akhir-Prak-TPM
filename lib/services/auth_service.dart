import 'dart:convert';
import 'package:hive/hive.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';

//ayas
//poke
class AuthService {
  static const String _userKey = 'user_data';
  static const String _isLoggedInKey = 'is_logged_in';

  Future<void> updateUser(UserModel user) async {
    try {
      // Menyimpan di SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('username', user.username);
      await prefs.setString('instansi', user.instansi);
      await prefs.setString('id', user.id);
      if (user.profileImageUrl != null) {
        await prefs.setString('profileImageUrl', user.profileImageUrl!);
      }

      // Menyimpan di Hive
      var box = Hive.box<UserModel>('userBox');
      await box.put('user', user);

      print('User data updated in SharedPreferences and Hive');
    } catch (e) {
      print('Error updating user: $e');
    }
  }

  // Login user (buat user baru tanpa id)
  Future<bool> login(String username, String instansi, String password) async {
    try {
      // Create a user model without id (pakai constructor create)
      final user = UserModel.create(
        username: username,
        instansi: instansi,
        password: password, // Menambahkan password
      );

      // Store in shared preferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        _userKey,
        jsonEncode(user.toMap()),
      ); // Menyimpan data user
      await prefs.setBool(_isLoggedInKey, true); // Menyimpan status login

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

  // Fungsi untuk logout
  Future<bool> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(
        _userKey,
      ); // Hapus data pengguna dari SharedPreferences
      await prefs.remove(_isLoggedInKey); // Hapus status login

      // final userBox = await Hive.openBox('userBox');
      // await userBox.clear(); // Hapus semua data pengguna di Hive

      print('User logged out');
      return true; // Kembalikan true jika logout berhasil
    } catch (e) {
      print('Logout error: $e');
      return false; // Kembalikan false jika terjadi error saat logout
    }
  }
}
