import 'package:flutter/material.dart';
import 'package:kai/constants/colors.dart';

class LocationInfoScreen extends StatelessWidget {
  final String locationName;
  final String description;

  const LocationInfoScreen({
    super.key,
    required this.locationName,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(locationName),
        backgroundColor: AppColors.primary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(description, style: const TextStyle(fontSize: 16)),
      ),
    );
  }
}
