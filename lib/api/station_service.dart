import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:revobike/data/models/Station.dart'; // Ensure this path is correct
import 'package:revobike/api/api_constants.dart'; // Import ApiConstants
import 'package:revobike/api/auth_service.dart'; // Import AuthService

class StationService {
  final http.Client client;

  StationService({
    http.Client? client,
  }) : client = client ?? http.Client();

  Future<List<Station>> getStations() async {
    try {
      print('Fetching stations...');
      // Use ApiConstants.baseUrl and ApiConstants.stationsEndpoint
      final url =
          Uri.parse(ApiConstants.baseUrl + ApiConstants.stationsEndpoint);

      final token = await AuthService().getAuthToken();
      final headers = {'Content-Type': 'application/json'};
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }

      final response = await client.get(url, headers: headers);

      print('Stations response: ${response.body}');

      final data = jsonDecode(response.body);
      if (response.statusCode >= 200 &&
          response.statusCode < 300 &&
          data['data'] != null) {
        final List<dynamic> stationsJson = data['data'];
        return stationsJson.map((json) => Station.fromJson(json)).toList();
      } else {
        final message = data['message'] ?? 'Failed to fetch stations';
        throw Exception(message);
      }
    } catch (e) {
      print('Error in getStations: $e');
      rethrow;
    }
  }

  // Example: Method to get a single station by ID
  Future<Station> getStationById(String stationId) async {
    try {
      final url = Uri.parse(ApiConstants.baseUrl +
          ApiConstants.stationDetailsEndpoint +
          stationId);

      final token = await AuthService().getAuthToken();
      final headers = {'Content-Type': 'application/json'};
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }

      final response = await client.get(url, headers: headers);

      print('Station detail response for $stationId: ${response.body}');

      final data = jsonDecode(response.body);
      if (response.statusCode >= 200 &&
          response.statusCode < 300 &&
          data['data'] != null) {
        return Station.fromJson(data[
            'data']); // Assuming detail API returns single object in 'data'
      } else {
        final message = data['message'] ?? 'Station not found';
        throw Exception(message);
      }
    } catch (e) {
      print('Error in getStationById: $e');
      rethrow;
    }
  }
}
