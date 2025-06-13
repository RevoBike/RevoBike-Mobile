import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../data/models/Station.dart';

class StationService {
  final FlutterSecureStorage _storage;
  final String baseUrl;
  final http.Client client;

  StationService({
    required this.baseUrl,
    FlutterSecureStorage? storage,
    http.Client? client,
  })  : _storage = storage ?? const FlutterSecureStorage(),
        client = client ?? http.Client();

  Future<List<Station>> getStations() async {
    try {
      print('Fetching stations...');
      final url = Uri.parse('$baseUrl/stations');

      final token = await _storage.read(key: 'jwt');
      final headers = {'Content-Type': 'application/json'};
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }

      final response = await client.get(url, headers: headers);

      print('Stations response: ${response.body}');

      final data = jsonDecode(response.body);
      if (data['success'] == true && data['data'] != null) {
        final List<dynamic> stationsJson = data['data'];
        return stationsJson.map((json) => Station.fromJson(json)).toList();
      } else {
        throw Exception('No stations found in response');
      }
    } catch (e) {
      print('Error in getStations: $e');
      rethrow;
    }
  }
}
