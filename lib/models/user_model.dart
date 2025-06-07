import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart'; // Import UUID package

part 'user_model.g.dart'; // Pastikan baris ini ada di atas

@HiveType(typeId: 1) // Tentukan typeId yang unik untuk model ini
class UserModel {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String username;

  @HiveField(2)
  final String instansi;

  @HiveField(3)
  final String password;

  @HiveField(4)
  final String? profileImageUrl;

  // Constructor untuk membuat user baru (id di-generate dengan UUID)
  UserModel.create({
    required this.username,
    required this.instansi,
    required this.password,
    this.profileImageUrl,
  }) : id =
           Uuid()
               .v4(); // ID akan otomatis terisi dengan UUID baru saat pembuatan user

  // Constructor untuk user yang sudah ada (misal dari database/API)
  UserModel({
    required this.id,
    required this.username,
    required this.instansi,
    required this.password,
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
      password: map['password'] ?? '',
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
