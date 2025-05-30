import 'package:flutter/material.dart';
import '../constants/colors.dart';

class PanduanScreen extends StatelessWidget {
  const PanduanScreen({super.key});

  final List<String> panduanLangkah = const [
    '1. Masukkan username dan instansi Anda di halaman login.',
    '2. Setelah login, Anda akan diarahkan ke dashboard.',
    '3. Gunakan menu Noisense untuk scan QR lokasi.',
    '4. Menu Feedback digunakan untuk mengirim saran atau kritik.',
    '5. Menu Panduan ini berisi petunjuk penggunaan aplikasi.',
    '6. Menu Sarana Prasarana menampilkan informasi fasilitas yang tersedia.',
    '7. Gunakan tombol Logout untuk keluar dari aplikasi.',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Panduan Penggunaan'),
        backgroundColor: AppColors.primary,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: panduanLangkah.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Text(
              panduanLangkah[index],
              style: const TextStyle(fontSize: 16),
            ),
          );
        },
      ),
    );
  }
}
