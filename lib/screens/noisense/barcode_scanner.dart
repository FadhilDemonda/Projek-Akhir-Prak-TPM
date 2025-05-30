import 'package:flutter/material.dart';
import 'package:kai/screens/dashboard_screen.dart';
import 'package:kai/screens/noisense/noisense_screen.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:kai/screens/noisense/LBS.dart';

class BarcodeScannerPage extends StatefulWidget {
  const BarcodeScannerPage({super.key});

  @override
  State<BarcodeScannerPage> createState() => _BarcodeScannerPageState();
}

class _BarcodeScannerPageState extends State<BarcodeScannerPage> {
  bool _isScanned = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          'Barcode Scanner',
          style: TextStyle(
            color: Color(0xFF2C2A6B), // Warna teks
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: Color(0xFF2C2A6B)), // Warna ikon navigasi (misalnya panah back)
        elevation: 1, // Tambahan opsional agar ada bayangan tipis
      ),

      body: Stack(
        children: [
          MobileScanner(
            onDetect: (capture) {
              if (_isScanned) return;

              final List<Barcode> barcodes = capture.barcodes;
              final Barcode barcodeDetected = barcodes.first;
              final String? value = barcodeDetected.rawValue;

              if (value != null && value.isNotEmpty) {
                setState(() => _isScanned = true);

                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => LBS(barcode: value)),
                ).then((_) {
                  // Reset scanner
                  setState(() => _isScanned = false);
                });
              }
            },
          ),

          // Keterangan teks di atas
          Positioned(
            top: 100, // atur sesuai kebutuhan untuk posisi atas
            left: 0,
            right: 0,
            child: Column(
              children: const [
                Text(
                  'Arahkan Kode QR ke dalam kotak untuk\nmulai memindai',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
                SizedBox(height: 24),
                Center(
                  child: SizedBox(
                    width: 250,
                    height: 250,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        border: Border.fromBorderSide(
                          BorderSide(color: Colors.white, width: 1.5),
                        ),
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
