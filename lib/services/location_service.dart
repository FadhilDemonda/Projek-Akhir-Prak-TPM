
class LocationService {
  // Get location information based on an ID or code
  Future<Map<String, dynamic>?> getLocationInfo(String locationId) async {
    try {
      // In a real app, this would fetch from API or database
      // For demo, we're using mock data
      final mockLocations = await _loadMockLocations();
      return mockLocations.firstWhere(
        (location) => location['id'] == locationId || location['code'] == locationId,
        orElse: () => {
          'id': locationId,
          'name': 'Lokasi Tidak Dikenal',
          'address': 'Alamat tidak tersedia',
          'description': 'Informasi lokasi tidak ditemukan untuk kode $locationId',
          'facilities': ['Tidak ada informasi'],
        },
      );
    } catch (e) {
      print('Get location error: $e');
      return null;
    }
  }
  
  // Get all available locations
  Future<List<Map<String, dynamic>>> getAllLocations() async {
    try {
      return await _loadMockLocations();
    } catch (e) {
      print('Get all locations error: $e');
      return [];
    }
  }
  
  // Load mock location data for demonstration
  Future<List<Map<String, dynamic>>> _loadMockLocations() async {
    return [
      {
        'id': '1',
        'code': 'LOC001',
        'name': 'Gedung A',
        'address': 'Jl. Contoh No. 1',
        'description': 'Gedung utama administrasi',
        'facilities': ['Lift', 'Toilet', 'Kantin', 'Mushola'],
        'latitude': -6.175110,
        'longitude': 106.865036,
      },
      {
        'id': '2',
        'code': 'LOC002',
        'name': 'Gedung B',
        'address': 'Jl. Contoh No. 2',
        'description': 'Gedung perkuliahan',
        'facilities': ['Ruang Kelas', 'Toilet', 'Lab Komputer'],
        'latitude': -6.175230,
        'longitude': 106.865136,
      },
      {
        'id': '3',
        'code': 'LOC003',
        'name': 'Gedung C',
        'address': 'Jl. Contoh No. 3',
        'description': 'Gedung perpustakaan',
        'facilities': ['Ruang Baca', 'Toilet', 'Wifi'],
        'latitude': -6.175350,
        'longitude': 106.865236,
      },
    ];
  }
}