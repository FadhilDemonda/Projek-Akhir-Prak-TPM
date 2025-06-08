// import 'package:flutter/material.dart';
// import '../constants/colors.dart';

// class PanduanScreen extends StatelessWidget {
//   const PanduanScreen({super.key});

//   final List<String> panduanLangkah = const [
//     '1. Masukkan username dan instansi Anda di halaman login.',
//     '2. Setelah login, Anda akan diarahkan ke dashboard.',
//     '3. Gunakan menu Noisense untuk scan QR lokasi.',
//     '4. Menu Feedback digunakan untuk mengirim saran atau kritik.',
//     '5. Menu Panduan ini berisi petunjuk penggunaan aplikasi.',
//     '6. Menu Sarana Prasarana menampilkan informasi fasilitas yang tersedia.',
//     '7. Gunakan tombol Logout untuk keluar dari aplikasi.',
//   ];

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Panduan Penggunaan'),
//         backgroundColor: AppColors.primary,
//       ),
//       body: ListView.builder(
//         padding: const EdgeInsets.all(16),
//         itemCount: panduanLangkah.length,
//         itemBuilder: (context, index) {
//           return Padding(
//             padding: const EdgeInsets.symmetric(vertical: 8.0),
//             child: Text(
//               panduanLangkah[index],
//               style: const TextStyle(fontSize: 16),
//             ),
//           );
//         },
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import '../constants/colors.dart';

class PanduanScreen extends StatelessWidget {
  const PanduanScreen({super.key});

  // Data panduan dengan kategori dan icon
  final List<Map<String, dynamic>> panduanSections = const [
    {
      'title': 'Memulai Aplikasi',
      'icon': Icons.login,
      'color': Colors.blue,
      'steps': [
        'Masukkan username dan instansi Anda di halaman login.',
        'Setelah login berhasil, Anda akan diarahkan ke dashboard utama.',
        'Dashboard menampilkan informasi akun dan menu utama aplikasi.',
      ],
    },
    {
      'title': 'Menu NoiSense',
      'icon': Icons.wifi_tethering,
      'color': Colors.green,
      'steps': [
        'Gunakan menu NoiSense untuk scan QR code di lokasi stasiun.',
        'Aplikasi akan menampilkan data tingkat kebisingan real-time.',
        'Data kebisingan ditampilkan dalam bentuk grafik dan angka.',
      ],
    },
    {
      'title': 'Menu Stasiun',
      'icon': Icons.train,
      'color': Colors.orange,
      'steps': [
        'Menu Stasiun menampilkan daftar lengkap semua stasiun.',
        'Klik salah satu stasiun untuk melihat detail informasi.',
        'Di halaman detail stasiun, Anda dapat melihat lokasi pada peta.',
        'Gunakan tombol "Tambah ke Favorit" untuk menyimpan stasiun favorit.',
        'Stasiun favorit akan ditandai dengan icon hati berwarna merah.',
      ],
    },
    {
      'title': 'Menu Favorit',
      'icon': Icons.favorite,
      'color': Colors.red,
      'steps': [
        'Menu Favorit menampilkan daftar stasiun yang telah Anda simpan.',
        'Klik stasiun favorit untuk langsung ke halaman detail.',
        'Gunakan tombol "Hapus dari Favorit" untuk menghapus dari daftar.',
        'Badge angka di icon favorit menunjukkan jumlah stasiun favorit.',
        'Akses cepat favorit juga tersedia di header dashboard.',
      ],
    },
    {
      'title': 'Fitur Lainnya',
      'icon': Icons.more_horiz,
      'color': Colors.purple,
      'steps': [
        'Menu Feedback untuk mengirim saran, kritik, atau laporan bug.',
        'Menu Sarana Prasarana menampilkan informasi fasilitas kereta api.',
        'Halaman Profile untuk mengelola informasi akun Anda.',
        'Gunakan tombol Logout untuk keluar dari aplikasi dengan aman.',
      ],
    },
    {
      'title': 'Tips & Trik',
      'icon': Icons.lightbulb,
      'color': Colors.amber,
      'steps': [
        'Guncang ponsel di dashboard untuk membuka panduan dengan cepat.',
        'Gunakan notifikasi untuk mendapat update terbaru aplikasi.',
        'Bookmark stasiun yang sering Anda kunjungi ke favorit.',
        'Periksa koneksi internet untuk data real-time yang akurat.',
      ],
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        title: const Text(
          'Panduan Penggunaan',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: AppColors.primary,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.primary, Color(0xFF8A2387)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header dengan animasi
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary.withOpacity(0.1),
                    Colors.transparent,
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: Column(
                children: [
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.3),
                          blurRadius: 20,
                          offset: Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.menu_book,
                      size: 48,
                      color: AppColors.primary,
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Selamat Datang di NoiSense!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Panduan lengkap untuk menggunakan semua fitur aplikasi monitoring kebisingan stasiun kereta api',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),

            // Quick access cards
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Akses Cepat',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                  SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildQuickAccessCard(
                          'Shake Gesture',
                          'Guncang ponsel untuk buka panduan',
                          Icons.vibration,
                          Colors.blue,
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: _buildQuickAccessCard(
                          'Favorit',
                          'Simpan stasiun favorit Anda',
                          Icons.favorite,
                          Colors.red,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 24),
                ],
              ),
            ),

            // Panduan sections
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Panduan Lengkap',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                  SizedBox(height: 12),
                  ...panduanSections
                      .map(
                        (section) => _buildPanduanSection(
                          section['title'],
                          section['icon'],
                          section['color'],
                          section['steps'],
                        ),
                      )
                      .toList(),
                ],
              ),
            ),

            // Footer
            Container(
              margin: EdgeInsets.all(16),
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.primary, Color(0xFF8A2387)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 10,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Icon(Icons.support_agent, size: 32, color: Colors.white),
                  SizedBox(height: 12),
                  Text(
                    'Butuh Bantuan?',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Jika Anda mengalami kendala atau memiliki pertanyaan, gunakan menu Feedback untuk menghubungi tim support.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.9),
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickAccessCard(
    String title,
    String subtitle,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 24, color: color),
          ),
          SizedBox(height: 12),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          SizedBox(height: 4),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildPanduanSection(
    String title,
    IconData icon,
    Color color,
    List<String> steps,
  ) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: ExpansionTile(
        leading: Container(
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
        ),
        tilePadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        childrenPadding: EdgeInsets.only(left: 16, right: 16, bottom: 16),
        iconColor: color,
        collapsedIconColor: color,
        children:
            steps
                .map(
                  (step) => Container(
                    margin: EdgeInsets.only(bottom: 12),
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: color.withOpacity(0.2)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          margin: EdgeInsets.only(top: 6, right: 12),
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            step,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[700],
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
                .toList(),
      ),
    );
  }
}
