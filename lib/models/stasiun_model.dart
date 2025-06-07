class Stasiun {
  final String id;
  final String nama;
  final String deskripsi;
  final String kota;
  final double latitude;
  final double longitude;
  final String imageURL;

  Stasiun({
    required this.id,
    required this.nama,
    required this.deskripsi,
    required this.kota,
    required this.latitude,
    required this.longitude,
    required this.imageURL,
  });

  // Factory constructor dari JSON (untuk API response)
  factory Stasiun.fromJson(Map<String, dynamic> json) {
    return Stasiun(
      id: json['id'] ?? '',
      nama: json['nama'] ?? '',
      deskripsi: json['deskripsi'] ?? '',
      kota: json['kota'] ?? '',
      latitude: (json['latitude'] ?? 0.0).toDouble(),
      longitude: (json['longitude'] ?? 0.0).toDouble(),
      imageURL: json['imageURL'] ?? '',
    );
  }

  // Factory constructor dari Map (untuk local storage)
  factory Stasiun.fromMap(Map<String, dynamic> map) {
    return Stasiun(
      id: map['id'] ?? '',
      nama: map['nama'] ?? '',
      deskripsi: map['deskripsi'] ?? '',
      kota: map['kota'] ?? '',
      latitude: (map['latitude'] ?? 0.0).toDouble(),
      longitude: (map['longitude'] ?? 0.0).toDouble(),
      imageURL: map['imageURL'] ?? '',
    );
  }

  // Convert ke JSON (untuk API request)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nama': nama,
      'deskripsi': deskripsi,
      'kota': kota,
      'latitude': latitude,
      'longitude': longitude,
      'imageURL': imageURL,
    };
  }

  // Convert ke Map (untuk local storage)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nama': nama,
      'deskripsi': deskripsi,
      'kota': kota,
      'latitude': latitude,
      'longitude': longitude,
      'imageURL': imageURL,
    };
  }
}
