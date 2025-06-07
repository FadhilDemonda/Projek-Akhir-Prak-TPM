import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/stasiun_model.dart';

class StasiunService {
  final String apiUrl =
      'https://684246a3e1347494c31c4b24.mockapi.io/api/event/Stasiun';

  Future<List<Stasiun>> getStasiun() async {
    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        return data.map((stasiun) => Stasiun.fromJson(stasiun)).toList();
      } else {
        throw Exception('Failed to load stasiun');
      }
    } catch (e) {
      rethrow;
    }
  }
}
