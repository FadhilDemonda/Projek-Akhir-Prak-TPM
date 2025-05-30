import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late GoogleMapController _mapController;
  final LatLng _initialPosition = const LatLng(-7.250445, 112.768845); // Surabaya

  final List<Map<String, dynamic>> _locations = [
    {
      "id": "1",
      "name": "Gedung A",
      "description": "Ruang server utama",
      "image": "assets/images/gedung_a.jpg",
      "position": LatLng(-7.250445, 112.768845)
    },
    {
      "id": "2",
      "name": "Gedung B",
      "description": "Ruang pelatihan",
      "image": "assets/images/gedung_b.jpg",
      "position": LatLng(-7.252000, 112.770000)
    },
  ];

  void _onMarkerTapped(Map<String, dynamic> location) {
    showModalBottomSheet(
      context: context,
      builder: (_) => Container(
        padding: const EdgeInsets.all(16),
        height: 300,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(location['name'], style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Image.asset(location['image'], height: 150, width: double.infinity, fit: BoxFit.cover),
            const SizedBox(height: 8),
            Text(location['description']),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Set<Marker> markers = _locations.map((location) {
      return Marker(
        markerId: MarkerId(location['id']),
        position: location['position'],
        infoWindow: InfoWindow(title: location['name']),
        onTap: () => _onMarkerTapped(location),
      );
    }).toSet();

    return Scaffold(
      appBar: AppBar(title: const Text('Peta Lokasi')),
      body: GoogleMap(
        onMapCreated: (controller) => _mapController = controller,
        initialCameraPosition: CameraPosition(target: _initialPosition, zoom: 15),
        markers: markers,
      ),
    );
  }
}
