import 'dart:convert';
import 'package:hive/hive.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';

class AuthService {
  static const String _userKey = 'user_data';
  static const String _isLoggedInKey = 'is_logged_in';

  Future<void> updateUser(UserModel user) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Update SharedPreferences data (by field)
      await prefs.setString('username', user.username);
      await prefs.setString('instansi', user.instansi);
      await prefs.setString('id', user.id);
      if (user.profileImageUrl != null) {
        await prefs.setString('profileImageUrl', user.profileImageUrl!);
      }

      var box = await Hive.openBox('userBox');

      // Cari dan hapus user lama berdasarkan ID
      final existingEntry = box.toMap().entries.firstWhere((entry) {
        final map = entry.value as Map;
        return map['id'] == user.id;
      }, orElse: () => MapEntry(null, null));

      if (existingEntry.key != null) {
        await box.delete(existingEntry.key); // hapus key lama (misalnya x23)
      }

      // Simpan user baru dengan key = username baru
      await box.put(user.username, user.toMap());

      // Simpan ke _userKey juga supaya getCurrentUser ambil yang benar
      await prefs.setString(_userKey, jsonEncode(user.toMap()));
      await prefs.reload(); // optional untuk jaga-jaga

      print('✅ Data user berhasil diperbarui: ${user.username}');
    } catch (e) {
      print('Error updating user: $e');
    }
  }

  // Login user (buat user baru tanpa id)
  Future<bool> login(String username, String instansi, String password) async {
    try {
      var box = await Hive.openBox('userBox');

      final allUsers = box.toMap();

      final matchingEntry = allUsers.entries.firstWhere((entry) {
        final userMap = entry.value as Map;
        return userMap['username'] == username &&
            userMap['password'] == password;
      }, orElse: () => MapEntry(null, null));

      if (matchingEntry.key == null) {
        print('❌ Login gagal: user tidak ditemukan atau password salah');
        return false;
      }

      final user = UserModel.fromMap(
        Map<String, dynamic>.from(matchingEntry.value),
      );

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_userKey, jsonEncode(user.toMap()));
      await prefs.setBool(_isLoggedInKey, true);

      // Update user data di Hive juga
      await box.put('user', user.toMap());

      print('✅ Login berhasil sebagai: ${user.username}');
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
      await prefs.reload(); // Pastikan data fresh

      final userData = prefs.getString(_userKey);
      if (userData == null) {
        print('⚠️ Tidak ada data user di SharedPreferences');
        return null;
      }

      final userMap = jsonDecode(userData) as Map<String, dynamic>;
      final username = userMap['username'];
      if (username == null) {
        print('⚠️ Username tidak ditemukan di data user');
        return null;
      }

      final box = await Hive.openBox('userBox');
      final hiveData = box.get(username);

      if (hiveData != null && hiveData is Map) {
        print('📦 User ditemukan di Hive: $hiveData');
        return UserModel.fromMap(Map<String, dynamic>.from(hiveData));
      } else {
        print('⚠️ User tidak ditemukan di Hive');
        return null;
      }
    } catch (e) {
      print('Error retrieving user data: $e');
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

      // var userBox = await Hive.openBox('userBox');
      // await userBox.clear(); // Hapus semua data pengguna di Hive

      print('User logged out');
      return true; // Kembalikan true jika logout berhasil
    } catch (e) {
      print('Logout error: $e');
      return false; // Kembalikan false jika terjadi error saat logout
    }
  }

  Future<bool> deleteUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_userKey); // Hapus data pengguna di SharedPreferences
      await prefs.remove(_isLoggedInKey); // Hapus status login

      var box = await Hive.openBox('userBox');
      await box.clear(); // Hapus semua data pengguna di Hive

      print('✅ Akun berhasil dihapus');
      return true;
    } catch (e) {
      print('Error deleting user: $e');
      return false;
    }
  }
}
