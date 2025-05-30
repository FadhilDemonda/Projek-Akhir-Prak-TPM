import 'package:flutter/material.dart';
import '../../constants/colors.dart';
import '../../constants/string.dart';
import '../../routes.dart';

class NoisenseScreen extends StatelessWidget {
  const NoisenseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppStrings.noisense,
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF8A2387), Color(0xFFE94057)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Image.asset(
                'assets/images/kereta.jpg', // Pastikan file ini tersedia
                height: 180,
                fit: BoxFit.contain,
              ),
            ),
            SizedBox(height: 10),
            // Info Card
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Noisense',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Scan QR code untuk mendapatkan informasi lokasi. '
                      'Anda dapat memindai QR code yang tersedia di berbagai lokasi.',
                      style: TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 24),

            // Scan QR Button
            ElevatedButton.icon(
              onPressed: () => Navigator.pushNamed(context, Routes.barcodeScanner),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFEB6A28), // warna oranye
                foregroundColor: Colors.black, // warna teks & ikon
                padding: EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: Icon(Icons.qr_code_scanner),
              label: Text(
                "Pindai QR Code",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black, // pastikan teks tetap hitam
                ),
              ),
            ),

            SizedBox(height: 24),

            // Recent Scans
            Text(
              'Pemindaian Terakhir',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),

            // Empty state or list of recent scans would go here
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.history, size: 64, color: AppColors.textLight),
                    SizedBox(height: 16),
                    Text(
                      'Belum ada pemindaian terbaru',
                      style: TextStyle(
                        fontSize: 16,
                        color: AppColors.textLight,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
