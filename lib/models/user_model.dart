class UserModel {
  final String id;
  final String username;
  final String instansi;
  final String? profileImageUrl;

  // Constructor untuk membuat user baru (id belum ada/otomatis di-generate backend)
  UserModel.create({
    required this.username,
    required this.instansi,
    this.profileImageUrl,
  }) : id = '';  // id kosong dulu, karena belum ada saat pembuatan baru

  // Constructor untuk user yang sudah ada (misal dari database/API), id pasti ada
  UserModel({
    required this.id,
    required this.username,
    required this.instansi,
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
      profileImageUrl: map['profileImageUrl'],
    );
  }

  UserModel copyWith({
    String? id,
    String? username,
    String? instansi,
    String? profileImageUrl,
  }) {
    return UserModel(
      id: id ?? this.id,
      username: username ?? this.username,
      instansi: instansi ?? this.instansi,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
    );
  }
}
