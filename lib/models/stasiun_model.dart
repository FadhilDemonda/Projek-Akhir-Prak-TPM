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

  factory Stasiun.fromJson(Map<String, dynamic> json) {
    return Stasiun(
      id: json['id'],
      nama: json['nama'],
      deskripsi: json['deskripsi'],
      kota: json['kota'],
      latitude: json['latitude'].toDouble(),
      longitude: json['longitude'].toDouble(),
      imageURL: json['imageURL'],
    );
  }

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
}
