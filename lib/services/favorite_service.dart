import 'dart:convert';
import 'package:hive/hive.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/stasiun_model.dart';

class FavoriteService {
  static const String _favoriteKey = 'favorite_stations';
  static const String _favoriteBoxName = 'favoriteBox';

  // Menambahkan stasiun ke daftar favorit
  Future<bool> addToFavorites(Stasiun stasiun, String userId) async {
    try {
      var box = await Hive.openBox(_favoriteBoxName);
      final prefs = await SharedPreferences.getInstance();

      // Ambil daftar favorit yang sudah ada
      List<String> existingFavorites = await getFavoriteIds(userId);

      // Cek apakah stasiun sudah ada di favorit
      if (existingFavorites.contains(stasiun.id)) {
        print('⚠️ Stasiun ${stasiun.nama} sudah ada di favorit');
        return false; // Stasiun sudah ada di favorit
      }

      // Tambahkan ID stasiun ke daftar favorit
      existingFavorites.add(stasiun.id);

      // Simpan ke Hive dengan key kombinasi userId dan stasiunId
      String hiveKey = '${userId}_${stasiun.id}';
      await box.put(hiveKey, stasiun.toMap());

      // Simpan daftar ID favorit ke SharedPreferences
      String favoritesKey = '${_favoriteKey}_$userId';
      await prefs.setStringList(favoritesKey, existingFavorites);

      print('✅ Stasiun ${stasiun.nama} berhasil ditambahkan ke favorit');
      return true;
    } catch (e) {
      print('Error adding to favorites: $e');
      return false;
    }
  }

  // Menghapus stasiun dari daftar favorit
  Future<bool> removeFromFavorites(String stasiunId, String userId) async {
    try {
      var box = await Hive.openBox(_favoriteBoxName);
      final prefs = await SharedPreferences.getInstance();

      // Ambil daftar favorit yang sudah ada
      List<String> existingFavorites = await getFavoriteIds(userId);

      // Cek apakah stasiun ada di favorit
      if (!existingFavorites.contains(stasiunId)) {
        print('⚠️ Stasiun tidak ditemukan di favorit');
        return false;
      }

      // Hapus ID stasiun dari daftar favorit
      existingFavorites.remove(stasiunId);

      // Hapus dari Hive
      String hiveKey = '${userId}_$stasiunId';
      await box.delete(hiveKey);

      // Update daftar ID favorit di SharedPreferences
      String favoritesKey = '${_favoriteKey}_$userId';
      await prefs.setStringList(favoritesKey, existingFavorites);

      print('✅ Stasiun berhasil dihapus dari favorit');
      return true;
    } catch (e) {
      print('Error removing from favorites: $e');
      return false;
    }
  }

  // Mengecek apakah stasiun sudah ada di favorit
  Future<bool> isFavorite(String stasiunId, String userId) async {
    try {
      List<String> favoriteIds = await getFavoriteIds(userId);
      return favoriteIds.contains(stasiunId);
    } catch (e) {
      print('Error checking favorite status: $e');
      return false;
    }
  }

  // Mendapatkan semua stasiun favorit milik user
  Future<List<Stasiun>> getFavoriteStations(String userId) async {
    try {
      var box = await Hive.openBox(_favoriteBoxName);
      List<Stasiun> favoriteStations = [];

      // Ambil semua data dari Hive yang key-nya dimulai dengan userId
      final allData = box.toMap();
      for (var entry in allData.entries) {
        String key = entry.key.toString();

        // Cek apakah key dimulai dengan userId
        if (key.startsWith('${userId}_')) {
          try {
            Map<String, dynamic> stasiunMap = Map<String, dynamic>.from(
              entry.value,
            );
            Stasiun stasiun = Stasiun.fromMap(stasiunMap);
            favoriteStations.add(stasiun);
          } catch (e) {
            print('Error parsing stasiun data: $e');
            continue; // Skip jika ada error parsing
          }
        }
      }

      print(
        '📦 Ditemukan ${favoriteStations.length} stasiun favorit untuk user $userId',
      );
      return favoriteStations;
    } catch (e) {
      print('Error getting favorite stations: $e');
      return [];
    }
  }

  // Mendapatkan daftar ID stasiun favorit (helper function)
  Future<List<String>> getFavoriteIds(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String favoritesKey = '${_favoriteKey}_$userId';

      // Ambil daftar ID favorit dari SharedPreferences
      List<String>? favoriteIds = prefs.getStringList(favoritesKey);
      return favoriteIds ?? []; // Return list kosong jika null
    } catch (e) {
      print('Error getting favorite IDs: $e');
      return [];
    }
  }

  // Mendapatkan jumlah stasiun favorit
  Future<int> getFavoriteCount(String userId) async {
    try {
      List<String> favoriteIds = await getFavoriteIds(userId);
      return favoriteIds.length;
    } catch (e) {
      print('Error getting favorite count: $e');
      return 0;
    }
  }

  // Menghapus semua stasiun favorit milik user
  Future<bool> clearAllFavorites(String userId) async {
    try {
      var box = await Hive.openBox(_favoriteBoxName);
      final prefs = await SharedPreferences.getInstance();

      // Hapus semua data favorit dari Hive yang key-nya dimulai dengan userId
      final allKeys = box.keys.toList();
      for (var key in allKeys) {
        String keyStr = key.toString();
        if (keyStr.startsWith('${userId}_')) {
          await box.delete(key);
        }
      }

      // Hapus daftar ID favorit dari SharedPreferences
      String favoritesKey = '${_favoriteKey}_$userId';
      await prefs.remove(favoritesKey);

      print('✅ Semua stasiun favorit berhasil dihapus');
      return true;
    } catch (e) {
      print('Error clearing favorites: $e');
      return false;
    }
  }

  // Sinkronisasi data favorit (membersihkan data yang tidak konsisten)
  Future<void> syncFavorites(String userId) async {
    try {
      var box = await Hive.openBox(_favoriteBoxName);
      final prefs = await SharedPreferences.getInstance();

      // Ambil daftar ID dari SharedPreferences
      List<String> favoriteIds = await getFavoriteIds(userId);

      // Ambil semua key dari Hive yang dimulai dengan userId
      final allKeys = box.keys.toList();
      List<String> hiveKeys = [];

      for (var key in allKeys) {
        String keyStr = key.toString();
        if (keyStr.startsWith('${userId}_')) {
          // Ekstrak ID stasiun dari key
          String stasiunId = keyStr.substring('${userId}_'.length);
          hiveKeys.add(stasiunId);
        }
      }

      // Hapus ID yang ada di SharedPreferences tapi tidak ada di Hive
      favoriteIds.removeWhere((id) => !hiveKeys.contains(id));

      // Hapus data di Hive yang tidak ada di SharedPreferences
      for (var key in allKeys) {
        String keyStr = key.toString();
        if (keyStr.startsWith('${userId}_')) {
          String stasiunId = keyStr.substring('${userId}_'.length);
          if (!favoriteIds.contains(stasiunId)) {
            await box.delete(key);
          }
        }
      }

      // Update SharedPreferences dengan data yang sudah bersih
      String favoritesKey = '${_favoriteKey}_$userId';
      await prefs.setStringList(favoritesKey, favoriteIds);

      print('✅ Sinkronisasi data favorit selesai');
    } catch (e) {
      print('Error syncing favorites: $e');
    }
  }

  // Export data favorit ke JSON (untuk backup)
  Future<String?> exportFavorites(String userId) async {
    try {
      List<Stasiun> favoriteStations = await getFavoriteStations(userId);

      Map<String, dynamic> exportData = {
        'userId': userId,
        'exportDate': DateTime.now().toIso8601String(),
        'favoriteStations': favoriteStations.map((s) => s.toMap()).toList(),
      };

      String jsonString = jsonEncode(exportData);
      print('✅ Data favorit berhasil diekspor');
      return jsonString;
    } catch (e) {
      print('Error exporting favorites: $e');
      return null;
    }
  }

  // Import data favorit dari JSON (untuk restore)
  Future<bool> importFavorites(String userId, String jsonString) async {
    try {
      Map<String, dynamic> importData = jsonDecode(jsonString);
      List<dynamic> stationsList = importData['favoriteStations'];

      // Hapus semua favorit yang ada
      await clearAllFavorites(userId);

      // Import stasiun satu per satu
      for (var stationData in stationsList) {
        Map<String, dynamic> stationMap = Map<String, dynamic>.from(
          stationData,
        );
        Stasiun stasiun = Stasiun.fromMap(stationMap);
        await addToFavorites(stasiun, userId);
      }

      print('✅ Data favorit berhasil diimpor');
      return true;
    } catch (e) {
      print('Error importing favorites: $e');
      return false;
    }
  }
}
