import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/stasiun_model.dart';
import '../../services/favorite_service.dart';
import '../../services/auth_service.dart';

class StasiunDetailPage extends StatefulWidget {
  final Stasiun stasiun;

  const StasiunDetailPage({Key? key, required this.stasiun}) : super(key: key);

  @override
  State<StasiunDetailPage> createState() => _StasiunDetailPageState();
}

class _StasiunDetailPageState extends State<StasiunDetailPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final MapController _mapController = MapController();

  // Service instances
  final FavoriteService _favoriteService = FavoriteService();
  final AuthService _authService = AuthService();

  // State variables untuk favorite
  bool _isFavorite = false;
  bool _isLoadingFavorite = false;
  String? _currentUserId;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _initializeFavoriteStatus(); // Inisialisasi status favorite
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Fungsi untuk menginisialisasi status favorite stasiun
  Future<void> _initializeFavoriteStatus() async {
    try {
      // Ambil data user yang sedang login
      final currentUser = await _authService.getCurrentUser();
      if (currentUser != null) {
        _currentUserId = currentUser.id;

        // Cek apakah stasiun ini sudah difavoritkan
        bool isFav = await _favoriteService.isFavorite(
          widget.stasiun.id,
          _currentUserId!,
        );

        setState(() {
          _isFavorite = isFav;
        });
      }
    } catch (e) {
      print('Error initializing favorite status: $e');
    }
  }

  // Fungsi untuk toggle status favorite
  Future<void> _toggleFavorite() async {
    if (_currentUserId == null) {
      // Tampilkan pesan jika user belum login
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Silakan login terlebih dahulu untuk menambah favorit'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isLoadingFavorite = true; // Tampilkan loading
    });

    try {
      bool success;

      if (_isFavorite) {
        // Hapus dari favorit
        success = await _favoriteService.removeFromFavorites(
          widget.stasiun.id,
          _currentUserId!,
        );

        if (success) {
          setState(() {
            _isFavorite = false;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${widget.stasiun.nama} dihapus dari favorit'),
              backgroundColor: Colors.red[600],
              action: SnackBarAction(
                label: 'UNDO',
                textColor: Colors.white,
                onPressed:
                    () =>
                        _addToFavorite(), // Tambah kembali jika user menekan UNDO
              ),
            ),
          );
        }
      } else {
        // Tambah ke favorit
        success = await _addToFavorite();
      }
    } catch (e) {
      print('Error toggling favorite: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Terjadi kesalahan, silakan coba lagi'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoadingFavorite = false; // Sembunyikan loading
      });
    }
  }

  // Fungsi helper untuk menambah ke favorit
  Future<bool> _addToFavorite() async {
    bool success = await _favoriteService.addToFavorites(
      widget.stasiun,
      _currentUserId!,
    );

    if (success) {
      setState(() {
        _isFavorite = true;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${widget.stasiun.nama} ditambahkan ke favorit'),
          backgroundColor: Colors.green[600],
          action: SnackBarAction(
            label: 'LIHAT',
            textColor: Colors.white,
            onPressed: () {
              // Navigasi ke halaman favorit (implementasi sesuai routing app)
              // Navigator.pushNamed(context, '/favorites');
            },
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Stasiun sudah ada di favorit'),
          backgroundColor: Colors.orange,
        ),
      );
    }

    return success;
  }

  Future<void> _openInMaps() async {
    final url =
        'https://www.openstreetmap.org/?mlat=${widget.stasiun.latitude}&mlon=${widget.stasiun.longitude}&zoom=15&layers=M';
    if (await canLaunch(url)) {
      await launch(url);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App Bar with Image
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            backgroundColor: Colors.blue[700],
            leading: Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            actions: [
              // Tombol Favorite (menggantikan share)
              Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.3),
                  shape: BoxShape.circle,
                ),
                child:
                    _isLoadingFavorite
                        ? Container(
                          padding: const EdgeInsets.all(12),
                          child: const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          ),
                        )
                        : IconButton(
                          icon: Icon(
                            _isFavorite
                                ? Icons.favorite
                                : Icons.favorite_border,
                            color: _isFavorite ? Colors.red[400] : Colors.white,
                          ),
                          onPressed: _toggleFavorite,
                          tooltip:
                              _isFavorite
                                  ? 'Hapus dari favorit'
                                  : 'Tambah ke favorit',
                        ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    widget.stasiun.imageURL,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey[300],
                        child: const Icon(
                          Icons.train,
                          size: 100,
                          color: Colors.grey,
                        ),
                      );
                    },
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.7),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 20,
                    left: 20,
                    right: 20,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                widget.stasiun.nama,
                                style: const TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            // Indikator favorite di header
                            if (_isFavorite)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.red[400],
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.favorite,
                                      color: Colors.white,
                                      size: 14,
                                    ),
                                    SizedBox(width: 4),
                                    Text(
                                      'Favorit',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(
                              Icons.location_city,
                              color: Colors.white70,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              widget.stasiun.kota,
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.white70,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Content
          SliverToBoxAdapter(
            child: Column(
              children: [
                // Tab Bar
                Container(
                  color: Colors.white,
                  child: TabBar(
                    controller: _tabController,
                    labelColor: Colors.blue[700],
                    unselectedLabelColor: Colors.grey,
                    indicatorColor: Colors.blue[700],
                    indicatorWeight: 3,
                    tabs: const [
                      Tab(icon: Icon(Icons.info_outline), text: 'Informasi'),
                      Tab(icon: Icon(Icons.map_outlined), text: 'Lokasi'),
                    ],
                  ),
                ),
                // Tab Content
                SizedBox(
                  height: 600,
                  child: TabBarView(
                    controller: _tabController,
                    children: [_buildInfoTab(), _buildMapTab()],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Favorite Status Card (tambahan)
          if (_currentUserId != null)
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              color: _isFavorite ? Colors.red[50] : Colors.grey[50],
              child: InkWell(
                onTap: _toggleFavorite,
                borderRadius: BorderRadius.circular(16),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(
                        _isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: _isFavorite ? Colors.red[600] : Colors.grey[600],
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _isFavorite
                              ? 'Hapus dari stasiun favorit'
                              : 'Tambahkan ke stasiun favorit',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color:
                                _isFavorite
                                    ? Colors.red[700]
                                    : Colors.grey[700],
                          ),
                        ),
                      ),
                      if (_isLoadingFavorite)
                        const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      else
                        Icon(
                          Icons.arrow_forward_ios,
                          color: Colors.grey[400],
                          size: 16,
                        ),
                    ],
                  ),
                ),
              ),
            ),
          if (_currentUserId != null) const SizedBox(height: 20),

          // Description Card
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.description,
                        color: Colors.blue[700],
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Deskripsi',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    widget.stasiun.deskripsi,
                    style: const TextStyle(
                      fontSize: 16,
                      height: 1.5,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          // Location Info Card
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        color: Colors.blue[700],
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Informasi Lokasi',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _buildInfoRow(
                    icon: Icons.location_city,
                    label: 'Kota',
                    value: widget.stasiun.kota,
                  ),
                  const SizedBox(height: 16),
                  _buildInfoRow(
                    icon: Icons.my_location,
                    label: 'Latitude',
                    value: widget.stasiun.latitude.toStringAsFixed(6),
                  ),
                  const SizedBox(height: 16),
                  _buildInfoRow(
                    icon: Icons.my_location,
                    label: 'Longitude',
                    value: widget.stasiun.longitude.toStringAsFixed(6),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          // Action Buttons
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _openInMaps,
                  icon: const Icon(Icons.map),
                  label: const Text('Buka di Maps'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[700],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMapTab() {
    return Column(
      children: [
        // Map Controls
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.grey[50],
          child: Row(
            children: [
              Icon(Icons.info_outline, color: Colors.blue[700], size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Lokasi ${widget.stasiun.nama}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              TextButton.icon(
                onPressed: _openInMaps,
                icon: const Icon(Icons.open_in_new, size: 16),
                label: const Text('Buka'),
                style: TextButton.styleFrom(foregroundColor: Colors.blue[700]),
              ),
            ],
          ),
        ),
        // Map
        Expanded(
          child: FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: LatLng(
                widget.stasiun.latitude,
                widget.stasiun.longitude,
              ),
              initialZoom: 15.0,
              maxZoom: 18.0,
              minZoom: 5.0,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.stasiun_app',
              ),
              MarkerLayer(
                markers: [
                  Marker(
                    point: LatLng(
                      widget.stasiun.latitude,
                      widget.stasiun.longitude,
                    ),
                    width: 80,
                    height: 80,
                    child: Container(
                      decoration: BoxDecoration(
                        color: _isFavorite ? Colors.red[600] : Colors.blue[700],
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Icon(
                        _isFavorite ? Icons.favorite : Icons.train,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        // Map Info Footer
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.white,
          child: Row(
            children: [
              Icon(
                _isFavorite ? Icons.favorite : Icons.train,
                color: _isFavorite ? Colors.red[600] : Colors.blue[700],
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            widget.stasiun.nama,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        if (_isFavorite)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.red[100],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'Favorit',
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.red[700],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                      ],
                    ),
                    Text(
                      '${widget.stasiun.latitude.toStringAsFixed(4)}, ${widget.stasiun.longitude.toStringAsFixed(4)}',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: Colors.grey[600], size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
