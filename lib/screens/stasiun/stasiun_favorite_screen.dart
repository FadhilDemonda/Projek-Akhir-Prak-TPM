import 'package:flutter/material.dart';
import '../../models/stasiun_model.dart';
import '../../routes.dart';
import '../../services/favorite_service.dart';
import '../../services/auth_service.dart';
import 'stasiun_detail_screen.dart';

class FavoritePage extends StatefulWidget {
  const FavoritePage({Key? key}) : super(key: key);

  @override
  State<FavoritePage> createState() => _FavoritePageState();
}

class _FavoritePageState extends State<FavoritePage> {
  final FavoriteService _favoriteService = FavoriteService();
  final AuthService _authService = AuthService();

  List<Stasiun> _favoriteStations = [];
  bool _isLoading = true;
  String? _currentUserId;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadFavoriteStations();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Memuat daftar stasiun favorit
  Future<void> _loadFavoriteStations() async {
    try {
      setState(() {
        _isLoading = true;
      });

      // Ambil data user yang sedang login
      final currentUser = await _authService.getCurrentUser();
      if (currentUser == null) {
        setState(() {
          _isLoading = false;
        });
        return;
      }

      _currentUserId = currentUser.id;

      // Ambil daftar stasiun favorit
      final favoriteStations = await _favoriteService.getFavoriteStations(
        _currentUserId!,
      );

      setState(() {
        _favoriteStations = favoriteStations;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading favorite stations: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Fungsi untuk menghapus stasiun dari favorit
  Future<void> _removeFromFavorites(Stasiun stasiun, int index) async {
    if (_currentUserId == null) return;

    try {
      bool success = await _favoriteService.removeFromFavorites(
        stasiun.id,
        _currentUserId!,
      );

      if (success) {
        setState(() {
          _favoriteStations.removeAt(index);
        });

        // Tampilkan snackbar dengan opsi undo
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${stasiun.nama} dihapus dari favorit'),
            backgroundColor: Colors.red[600],
            action: SnackBarAction(
              label: 'UNDO',
              textColor: Colors.white,
              onPressed: () async {
                // Tambahkan kembali ke favorit
                bool undoSuccess = await _favoriteService.addToFavorites(
                  stasiun,
                  _currentUserId!,
                );
                if (undoSuccess) {
                  setState(() {
                    _favoriteStations.insert(index, stasiun);
                  });
                }
              },
            ),
          ),
        );
      }
    } catch (e) {
      print('Error removing from favorites: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Terjadi kesalahan saat menghapus favorit'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Fungsi untuk menghapus semua favorit
  Future<void> _clearAllFavorites() async {
    if (_currentUserId == null || _favoriteStations.isEmpty) return;

    // Tampilkan dialog konfirmasi
    bool? confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Hapus Semua Favorit'),
            content: const Text(
              'Apakah Anda yakin ingin menghapus semua stasiun favorit? '
              'Tindakan ini tidak dapat dibatalkan.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Batal'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('Hapus Semua'),
              ),
            ],
          ),
    );

    if (confirmed == true) {
      try {
        bool success = await _favoriteService.clearAllFavorites(
          _currentUserId!,
        );
        if (success) {
          setState(() {
            _favoriteStations.clear();
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Semua stasiun favorit berhasil dihapus'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Terjadi kesalahan saat menghapus favorit'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Filter stasiun berdasarkan pencarian
  List<Stasiun> get _filteredStations {
    if (_searchQuery.isEmpty) {
      return _favoriteStations;
    }

    return _favoriteStations.where((stasiun) {
      return stasiun.nama.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          stasiun.kota.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Stasiun Favorit',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          // Tombol hapus semua favorit
          if (_favoriteStations.isNotEmpty)
            IconButton(
              onPressed: _clearAllFavorites,
              icon: const Icon(Icons.clear_all),
              tooltip: 'Hapus Semua Favorit',
            ),

          // Tombol refresh
          IconButton(
            onPressed: _loadFavoriteStations,
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Column(
        children: [
          // Header dengan statistik
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.blue[700],
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
            ),
            child: Column(
              children: [
                // Statistik favorit
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.favorite, color: Colors.white, size: 24),
                    const SizedBox(width: 8),
                    Text(
                      '${_favoriteStations.length} Stasiun Favorit',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Search bar
                if (_favoriteStations.isNotEmpty)
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _searchController,
                      onChanged: (value) {
                        setState(() {
                          _searchQuery = value;
                        });
                      },
                      decoration: InputDecoration(
                        hintText: 'Cari stasiun favorit...',
                        prefixIcon: const Icon(
                          Icons.search,
                          color: Colors.grey,
                        ),
                        suffixIcon:
                            _searchQuery.isNotEmpty
                                ? IconButton(
                                  onPressed: () {
                                    _searchController.clear();
                                    setState(() {
                                      _searchQuery = '';
                                    });
                                  },
                                  icon: const Icon(
                                    Icons.clear,
                                    color: Colors.grey,
                                  ),
                                )
                                : null,
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.all(16),
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Content area
          Expanded(child: _buildContent()),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      // Loading state
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text(
              'Memuat stasiun favorit...',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    if (_currentUserId == null) {
      // User not logged in
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.account_circle_outlined,
              size: 100,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            const Text(
              'Silakan login terlebih dahulu',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            const Text(
              'Anda perlu login untuk melihat stasiun favorit',
              style: TextStyle(fontSize: 14, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                // Navigasi ke halaman login
                // Navigator.pushNamed(context, '/login');
              },
              icon: const Icon(Icons.login),
              label: const Text('Login'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[700],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      );
    }

    if (_favoriteStations.isEmpty) {
      // Empty state
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.favorite_border, size: 100, color: Colors.grey[400]),
            const SizedBox(height: 16),
            const Text(
              'Belum ada stasiun favorit',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            const Text(
              'Tambahkan stasiun ke favorit untuk melihatnya di sini',
              style: TextStyle(fontSize: 14, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pushNamed(context, Routes.stasiun);
              },
              icon: const Icon(Icons.explore),
              label: const Text('Jelajahi Stasiun'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[700],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      );
    }

    final filteredStations = _filteredStations;

    if (filteredStations.isEmpty && _searchQuery.isNotEmpty) {
      // No search results
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 100, color: Colors.grey[400]),
            const SizedBox(height: 16),
            const Text(
              'Tidak ada hasil pencarian',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            Text(
              'Tidak ditemukan stasiun favorit dengan kata kunci "$_searchQuery"',
              style: const TextStyle(fontSize: 14, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    // List of favorite stations
    return RefreshIndicator(
      onRefresh: _loadFavoriteStations,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: filteredStations.length,
        itemBuilder: (context, index) {
          final stasiun = filteredStations[index];
          return _buildStasiunCard(stasiun, index);
        },
      ),
    );
  }

  Widget _buildStasiunCard(Stasiun stasiun, int index) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () {
          // Navigasi ke detail stasiun
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => StasiunDetailPage(stasiun: stasiun),
            ),
          ).then((_) {
            // Refresh data setelah kembali dari detail page
            _loadFavoriteStations();
          });
        },
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image section
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
              child: Stack(
                children: [
                  Image.network(
                    stasiun.imageURL,
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 200,
                        width: double.infinity,
                        color: Colors.grey[300],
                        child: const Icon(
                          Icons.train,
                          size: 60,
                          color: Colors.grey,
                        ),
                      );
                    },
                  ),
                  // Favorite badge
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.red[600],
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.favorite,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Content section
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title and location
                  Text(
                    stasiun.nama,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.location_city,
                        size: 16,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        stasiun.kota,
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Description preview
                  Text(
                    stasiun.deskripsi.length > 100
                        ? '${stasiun.deskripsi.substring(0, 100)}...'
                        : stasiun.deskripsi,
                    style: const TextStyle(fontSize: 14, height: 1.4),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 16),

                  // Action buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _removeFromFavorites(stasiun, index),
                          icon: const Icon(Icons.favorite_border, size: 18),
                          label: const Text('Hapus'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.red[600],
                            side: BorderSide(color: Colors.red[600]!),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) =>
                                        StasiunDetailPage(stasiun: stasiun),
                              ),
                            ).then((_) {
                              _loadFavoriteStations();
                            });
                          },
                          icon: const Icon(Icons.info_outline, size: 18),
                          label: const Text('Detail'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue[700],
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
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
    );
  }
}
