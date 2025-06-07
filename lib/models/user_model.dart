import 'package:hive/hive.dart';

part 'user_model.g.dart'; // Membuat file .g.dart secara otomatis setelah build

@HiveType(typeId: 1) // Tentukan typeId yang unik untuk model ini
class UserModel {
  @HiveField(0) // Field pertama untuk id
  final String id;

  @HiveField(1) // Field kedua untuk username
  final String username;

  @HiveField(2) // Field ketiga untuk instansi
  final String instansi;

  @HiveField(3)
  final String password; // Add the password field

  @HiveField(4) // Field keempat untuk profileImageUrl (optional)
  final String? profileImageUrl;

  // Constructor untuk membuat user baru (id belum ada/otomatis di-generate backend)
  UserModel.create({
    required this.username,
    required this.instansi,
    required this.password, // Ensure password is passed
    this.profileImageUrl,
  }) : id = ''; // id kosong dulu, karena belum ada saat pembuatan baru

  // Constructor untuk user yang sudah ada (misal dari database/API), id pasti ada
  UserModel({
    required this.id,
    required this.username,
    required this.instansi,
    required this.password, // Ensure password is included here
    this.profileImageUrl,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'instansi': instansi,
      'profileImageUrl': profileImageUrl,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] ?? '',
      username: map['username'] ?? '',
      instansi: map['instansi'] ?? '',
      password: map['password'] ?? '', // Make sure password is retrieved
      profileImageUrl: map['profileImageUrl'],
    );
  }

  UserModel copyWith({
    String? id,
    String? username,
    String? instansi,
    String? profileImageUrl,
    required String password,
  }) {
    return UserModel(
      id: id ?? this.id,
      username: username ?? this.username,
      instansi: instansi ?? this.instansi,
      password: password ?? this.password,

      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
    );
  }
}
