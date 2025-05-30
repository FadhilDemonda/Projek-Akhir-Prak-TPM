import 'package:flutter/material.dart';
import '/constants/colors.dart';

class SaranaPrasaranaScreen extends StatelessWidget {
  const SaranaPrasaranaScreen({super.key});

  final List<Map<String, String>> fasilitas = const [
    {'nama': 'Ruang Rapat', 'lokasi': 'Gedung A, Lantai 2'},
    {'nama': 'Aula Utama', 'lokasi': 'Gedung B, Lantai 1'},
    {'nama': 'Kantin', 'lokasi': 'Dekat Lobby Utama'},
    {'nama': 'Toilet Umum', 'lokasi': 'Setiap lantai'},
    {'nama': 'Ruang IT', 'lokasi': 'Gedung A, Lantai 3'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sarana & Prasarana'),
        backgroundColor: AppColors.primary,
      ),
      body: ListView.builder(
        itemCount: fasilitas.length,
        itemBuilder: (context, index) {
          final item = fasilitas[index];
          return ListTile(
            title: Text(item['nama']!),
            subtitle: Text(item['lokasi']!),
            leading: const Icon(Icons.location_on_outlined),
          );
        },
      ),
    );
  }
}
