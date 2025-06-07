class UserModel {
  final String id;
  final String username;
  final String instansi;
  final String password;
  final String? profileImageUrl;

  // Constructor untuk membuat user baru (id otomatis di-generate)
  UserModel.create({
    required this.username,
    required this.instansi,
    required this.password,
    this.profileImageUrl,
  }) : id =
           DateTime.now().millisecondsSinceEpoch
               .toString(); // ID menggunakan timestamp

  // Constructor untuk user yang sudah ada
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
      'password': password,
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
