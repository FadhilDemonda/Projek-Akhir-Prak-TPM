import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:sensors_plus/sensors_plus.dart'; // Package untuk accelerometer
import 'dart:async';
import 'dart:math'; // Untuk perhitungan matematika
import '../constants/colors.dart';
import '../routes.dart';
import '../services/auth_service.dart';
import '../services/favorite_service.dart';
import '../models/user_model.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final AuthService _authService = AuthService();
  final FavoriteService _favoriteService = FavoriteService();
  final PageController _pageController = PageController(viewportFraction: 0.9);

  UserModel? _currentUser;
  Timer? _autoSlideTimer;
  bool _isLoading = true;
  int _favoriteCount = 0; // Counter untuk jumlah favorit

  // Variabel untuk shake detection
  StreamSubscription<AccelerometerEvent>? _accelerometerSubscription;
  double _shakeThreshold =
      35.0; // Ambang batas untuk deteksi guncangan (semakin tinggi semakin sensitif)
  DateTime? _lastShakeTime; // Waktu guncangan terakhir untuk mencegah spam
  int _shakeCooldown = 30000; // Cooldown 2 detik antara guncangan

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _startAutoSlide();
    _initializeShakeDetection(); // Inisialisasi deteksi guncangan
  }

  @override
  void dispose() {
    _autoSlideTimer?.cancel();
    _pageController.dispose();
    _accelerometerSubscription
        ?.cancel(); // Bersihkan subscription accelerometer
    super.dispose();
  }

  // Fungsi untuk menginisialisasi deteksi guncangan
  void _initializeShakeDetection() {
    // Listen ke data accelerometer dari sensor ponsel
    _accelerometerSubscription = accelerometerEvents.listen((
      AccelerometerEvent event,
    ) {
      // Hitung magnitude (kekuatan) dari gerakan pada sumbu X, Y, Z
      double magnitude = sqrt(
        pow(event.x, 2) + pow(event.y, 2) + pow(event.z, 2),
      );

      // Jika magnitude melebihi threshold dan sudah melewati cooldown
      if (magnitude > _shakeThreshold && _canDetectShake()) {
        _onShakeDetected(); // Panggil fungsi ketika guncangan terdeteksi
      }
    });
  }

  // Fungsi untuk mengecek apakah bisa mendeteksi guncangan (cooldown)
  bool _canDetectShake() {
    DateTime now = DateTime.now();
    if (_lastShakeTime == null) {
      return true;
    }

    // Cek apakah sudah melewati cooldown period
    return now.difference(_lastShakeTime!).inMilliseconds > _shakeCooldown;
  }

  // Fungsi yang dipanggil ketika guncangan terdeteksi
  void _onShakeDetected() {
    _lastShakeTime = DateTime.now(); // Update waktu guncangan terakhir

    // Tampilkan dialog konfirmasi untuk membuka panduan
    _showShakeDialog();
  }

  // Dialog yang muncul ketika shake terdeteksi
  void _showShakeDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: Row(
            children: [
              Icon(Icons.vibration, color: AppColors.primary, size: 28),
              SizedBox(width: 8),
              Text(
                'Guncangan Terdeteksi!',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.menu_book, size: 60, color: AppColors.primary),
              SizedBox(height: 16),
              Text(
                'Apakah Anda ingin membuka Panduan Aplikasi?',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 8),
              Text(
                'Guncang ponsel untuk akses cepat ke panduan!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Tutup dialog
              },
              child: Text('Tidak', style: TextStyle(color: Colors.grey[600])),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(); // Tutup dialog
                Navigator.pushNamed(
                  context,
                  Routes.panduan,
                ); // Buka halaman panduan
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Ya, Buka Panduan',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _loadUserData() async {
    try {
      final user = await _authService.getCurrentUser();
      print('Loaded user: ${user?.username}'); // Debugging

      setState(() {
        _currentUser = user;
        _isLoading = false;
      });

      // Load favorite count jika user sudah login
      if (user != null) {
        _loadFavoriteCount(user.id);
      }
    } catch (e) {
      print('Error loading user: $e'); // Handle error if data not loaded
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadFavoriteCount(String userId) async {
    try {
      final count = await _favoriteService.getFavoriteCount(userId);
      setState(() {
        _favoriteCount = count;
      });
    } catch (e) {
      print('Error loading favorite count: $e');
    }
  }

  void _startAutoSlide() {
    _autoSlideTimer = Timer.periodic(Duration(seconds: 4), (_) {
      if (_pageController.hasClients) {
        int nextPage = _pageController.page!.round() + 1;
        if (nextPage >= 4) nextPage = 0;
        _pageController.animateToPage(
          nextPage,
          duration: Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  Widget buildMenuButton(String label, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: AppColors.primary,
            child: Icon(icon, color: Colors.white),
          ),
          SizedBox(height: 6),
          Text(label, style: TextStyle(fontSize: 14)),
        ],
      ),
    );
  }

  Widget buildSliderImage(String assetPath) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.asset(
          assetPath,
          fit: BoxFit.cover,
          width: double.infinity,
        ),
      ),
    );
  }

  Widget _buildDepoCard(String title, String imagePath, String argument) {
    return GestureDetector(
      onTap:
          () => Navigator.pushNamed(
            context,
            Routes.saranaPrasarana,
            arguments: argument,
          ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          image: DecorationImage(
            image: AssetImage(imagePath),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              Colors.black.withOpacity(0.3),
              BlendMode.darken,
            ),
          ),
        ),
        alignment: Alignment.bottomLeft,
        padding: EdgeInsets.all(12),
        child: Text(
          title,
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            shadows: [Shadow(color: Colors.black54, blurRadius: 4)],
          ),
        ),
      ),
    );
  }

  // Widget untuk tombol favorit dengan badge counter
  Widget _buildFavoriteButton() {
    return Stack(
      children: [
        IconButton(
          icon: Icon(Icons.favorite, color: Colors.white),
          onPressed: () async {
            if (_currentUser != null) {
              // Navigasi ke halaman favorit
              final result = await Navigator.pushNamed(
                context,
                Routes.favorite,
              );

              // Refresh favorite count setelah kembali
              if (result == 'updated' || result == null) {
                _loadFavoriteCount(_currentUser!.id);
              }
            } else {
              // Tampilkan snackbar jika belum login
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Silakan login terlebih dahulu'),
                  backgroundColor: Colors.orange,
                  action: SnackBarAction(
                    label: 'LOGIN',
                    textColor: Colors.white,
                    onPressed: () {
                      Navigator.pushNamed(context, Routes.login);
                    },
                  ),
                ),
              );
            }
          },
          tooltip: 'Stasiun Favorit',
        ),
        // Badge counter untuk jumlah favorit
        if (_favoriteCount > 0)
          Positioned(
            right: 8,
            top: 8,
            child: Container(
              padding: EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 2,
                    offset: Offset(0, 1),
                  ),
                ],
              ),
              constraints: BoxConstraints(minWidth: 18, minHeight: 18),
              child: Text(
                _favoriteCount > 99 ? '99+' : _favoriteCount.toString(),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header dengan info shake
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF8A2387), Color(0xFFE94057)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap: () async {
                            final result = await Navigator.pushNamed(
                              context,
                              Routes.profile,
                            );
                            print('Returning from profile screen');
                            if (result == 'updated') {
                              print('Refreshing user data after update');
                              _loadUserData(); // Memastikan kita memuat ulang data user setelah kembali
                            }
                          },
                          child: Row(
                            children: [
                              // Profile Image URL handling here
                              CircleAvatar(
                                radius: 24,
                                backgroundImage:
                                    _currentUser?.profileImageUrl != null &&
                                            _currentUser!
                                                .profileImageUrl!
                                                .isNotEmpty
                                        ? NetworkImage(
                                          _currentUser!.profileImageUrl!,
                                        )
                                        : AssetImage('assets/images/avatar.png')
                                            as ImageProvider,
                              ),
                              SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Selamat Datang!',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.white70,
                                    ),
                                  ),
                                  Text(
                                    _currentUser?.username ?? 'Guest',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  if (_currentUser?.instansi != null)
                                    Text(
                                      _currentUser!.instansi,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.white70,
                                      ),
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        // Action buttons di header
                        Row(
                          children: [
                            // Tombol Favorit dengan badge
                            _buildFavoriteButton(),

                            // Tombol Notifikasi
                            IconButton(
                              icon: Icon(
                                Icons.notifications,
                                color: Colors.white,
                              ),
                              onPressed: () {
                                // Implementasi notifikasi
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Fitur notifikasi segera hadir!',
                                    ),
                                    backgroundColor: Colors.blue,
                                  ),
                                );
                              },
                              tooltip: 'Notifikasi',
                            ),
                          ],
                        ),
                      ],
                    ),
                    // Info shake gesture - tambahan
                    SizedBox(height: 8),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.vibration, size: 16, color: Colors.white),
                          SizedBox(width: 6),
                          Text(
                            'Guncang ponsel untuk akses cepat ke Panduan',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 20),

              // Logo & Description
              Center(
                child: Column(
                  children: [
                    Image.asset('assets/images/noisense.png', height: 50),
                    SizedBox(height: 4),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        "Merupakan aplikasi yang dapat membantu pengguna dalam mengetahui zona dengan tingkat kebisingan secara real-time.",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 14),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 20),

              // Image Slider
              SizedBox(
                height: 220,
                child: Column(
                  children: [
                    Expanded(
                      child: PageView(
                        controller: _pageController,
                        children: [
                          buildSliderImage('assets/images/jogja.JPG'),
                          buildSliderImage('assets/images/solo.JPG'),
                          buildSliderImage('assets/images/sukoharjo.JPG'),
                          buildSliderImage('assets/images/sragen.jpeg'),
                        ],
                      ),
                    ),
                    SizedBox(height: 10),
                    SmoothPageIndicator(
                      controller: _pageController,
                      count: 4,
                      effect: WormEffect(
                        dotHeight: 8,
                        dotWidth: 8,
                        spacing: 8,
                        dotColor: Colors.grey.shade300,
                        activeDotColor: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 24),

              // Menu Buttons - Tambahkan menu Favorit
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    buildMenuButton(
                      'NoiSense',
                      Icons.wifi_tethering,
                      () => Navigator.pushNamed(context, Routes.noisense),
                    ),
                    buildMenuButton('Favorit', Icons.favorite, () async {
                      if (_currentUser != null) {
                        final result = await Navigator.pushNamed(
                          context,
                          Routes.favorite,
                        );
                        if (result == 'updated' || result == null) {
                          _loadFavoriteCount(_currentUser!.id);
                        }
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Silakan login terlebih dahulu'),
                            backgroundColor: Colors.orange,
                          ),
                        );
                      }
                    }),
                    buildMenuButton(
                      'Feedback',
                      Icons.feedback,
                      () => Navigator.pushNamed(context, Routes.feedback),
                    ),
                    buildMenuButton(
                      'Panduan',
                      Icons.menu_book,
                      () => Navigator.pushNamed(context, Routes.panduan),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 30),

              // Sarana dan Prasarana
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'Sarana dan Prasarana',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 3 / 2,
                  children: [
                    _buildDepoCard(
                      'Depo Lokomotif Yogyakarta',
                      'assets/images/lokoj.jpg',
                      'Yogyakarta',
                    ),
                    _buildDepoCard(
                      'Depo Lokomotif Solo Balapan',
                      'assets/images/lokos.jpg',
                      'Solo Balapan',
                    ),
                    _buildDepoCard(
                      'Depo Kereta Yogyakarta',
                      'assets/images/keretaj.png',
                      'Yogyakarta',
                    ),
                    _buildDepoCard(
                      'Depo Kereta Solo Balapan',
                      'assets/images/keretas.jpeg',
                      'Solo Balapan',
                    ),
                    _buildDepoCard(
                      'Depo Gerbong Rewulu',
                      'assets/images/rewulu.JPG',
                      'Rewulu',
                    ),
                    _buildDepoCard(
                      'Depo PUK Yogyakarta',
                      'assets/images/puk.JPG',
                      'Yogyakarta',
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),

      // Bottom Navigation
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        onTap: (index) async {
          if (index == 1) {
            final result = await Navigator.pushNamed(context, Routes.profile);
            if (result == 'updated') {
              print('Refreshing user data after update');
              _loadUserData(); // refresh jika kembali dari profile
            }
          } else if (index == 2) {
            // Add case for Stasiun screen
            final result = await Navigator.pushNamed(context, Routes.stasiun);
            if (result == 'updated') {
              print('Refreshing stasiun data after update');
              // Tambahkan fungsi refresh untuk stasiun jika diperlukan
              // _loadStasiunData(); // uncomment jika ada fungsi ini
            }
          }
        },
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
          BottomNavigationBarItem(
            icon: Icon(Icons.train),
            label: 'Stasiun',
          ), // Add Stasiun item
        ],
      ),
    );
  }
}
