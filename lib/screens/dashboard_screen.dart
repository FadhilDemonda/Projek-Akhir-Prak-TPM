import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'dart:async';
import '../constants/colors.dart';
import '../routes.dart';
import '../services/auth_service.dart';
import '../models/user_model.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final AuthService _authService = AuthService();
  final PageController _pageController = PageController(viewportFraction: 0.9);
  UserModel? _currentUser;
  Timer? _autoSlideTimer;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _startAutoSlide();
  }

  @override
  void dispose() {
    _autoSlideTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    final user = await _authService.getCurrentUser();
    setState(() {
      _currentUser = user;
      _isLoading = false;
    });
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
              // Header
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF8A2387), Color(0xFFE94057)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () async {
                        final result = await Navigator.pushNamed(
                          context,
                          Routes.profile,
                        );
                        if (result == 'updated') {
                          _loadUserData(); // muat ulang data user setelah kembali
                        }
                      },
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 24,
                            backgroundImage: AssetImage(
                              'assets/images/avatar.png',
                            ),
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
                                _currentUser?.username ?? '',
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
                    IconButton(
                      icon: Icon(Icons.notifications, color: Colors.white),
                      onPressed: () {},
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

              // Menu Buttons
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    buildMenuButton(
                      'NoiSense',
                      Icons.wifi_tethering,
                      () => Navigator.pushNamed(context, Routes.noisense),
                    ),
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
              _loadUserData(); // refresh jika kembali dari profile
            }
          }
        },
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
