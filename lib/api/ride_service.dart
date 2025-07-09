import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';
import 'package:revobike/api/api_constants.dart';
import 'package:revobike/api/auth_service.dart';

class RideService {
  final FlutterSecureStorage _storage;
  final http.Client _client;
  final AuthService _authService;

  RideService({
    required AuthService authService,
    FlutterSecureStorage? storage,
    http.Client? client,
  })  : _authService = authService,
        _storage = storage ?? const FlutterSecureStorage(),
        _client = client ?? http.Client();

  Future<Map<String, String>> _getAuthHeaders() async {
    String? token = await _authService.getAuthToken();
    if (token == null) {
      throw Exception('Authentication token not found. User not logged in.');
    }
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  Future<Map<String, dynamic>> startRide({
    required String bikeId,
    double? initialLatitude,
    double? initialLongitude,
  }) async {
    try {
      final url = Uri.parse(
          '${ApiConstants.baseUrl}${ApiConstants.startRideEndpoint}/$bikeId');
      final headers = await _getAuthHeaders();

      final Map<String, dynamic> requestBody = {
        "bikeId": bikeId,
      };
      if (initialLatitude != null) {
        requestBody['initialLatitude'] = initialLatitude;
      }
      if (initialLongitude != null) {
        requestBody['initialLongitude'] = initialLongitude;
      }

      final response = await _client.post(
        url,
        headers: headers,
        body: jsonEncode(requestBody),
      );

      final dynamic responseData = jsonDecode(response.body);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        if (responseData is Map<String, dynamic> &&
            responseData.containsKey('data')) {
          final dynamic dataContent = responseData['data'];
          if (dataContent is Map<String, dynamic>) {
            return dataContent;
          } else {
            throw Exception(
                "Invalid 'startRide' success response format: 'data' field is not an object.");
          }
        } else {
          throw Exception(
              "Invalid 'startRide' success response format. Expected a map with 'data' key.");
        }
      } else {
        final message = (responseData is Map<String, dynamic> &&
                responseData.containsKey('message'))
            ? responseData['message']
            : 'Failed to start ride with status ${response.statusCode}';
        throw Exception(message);
      }
    } catch (e) {
      print('Error starting ride: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> endRide({
    required String rideId,
    required double finalLatitude,
    required double finalLongitude,
  }) async {
    try {
      final url = Uri.parse(
          '${ApiConstants.baseUrl}${ApiConstants.endRideEndpoint}/$rideId');
      final headers = await _getAuthHeaders();

      final body = {
        'finalLatitude': finalLatitude,
        'finalLongitude': finalLongitude,
      };

      final response = await _client.post(
        url,
        headers: headers,
        body: jsonEncode(body),
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return responseData as Map<String, dynamic>;
      } else {
        final message = responseData['message'] ?? 'Failed to end ride';
        throw Exception(message);
      }
    } catch (e) {
      print('Error ending ride: $e');
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getRideHistory() async {
    try {
      final url = Uri.parse(
          '${ApiConstants.baseUrl}${ApiConstants.rideHistoryEndpoint}');
      final headers = await _getAuthHeaders();

      final response = await _client.get(url, headers: headers);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final dynamic responseData = jsonDecode(response.body);

        if (responseData is List) {
          return List<Map<String, dynamic>>.from(responseData);
        } else if (responseData is Map<String, dynamic>) {
          if (responseData.containsKey('data') &&
              responseData['data'] is List) {
            return List<Map<String, dynamic>>.from(responseData['data']);
          } else if (responseData.containsKey('rides') &&
              responseData['rides'] is List) {
            return List<Map<String, dynamic>>.from(responseData['rides']);
          } else if (responseData.length == 1) {
            final firstValue = responseData.values.first;
            if (firstValue is List) {
              return List<Map<String, dynamic>>.from(firstValue);
            }
          }
          throw Exception(
              "Unexpected map structure for ride history. Expected 'data' or 'rides' key containing a list.");
        } else {
          throw Exception(
              "Unexpected top-level response format for ride history: ${responseData.runtimeType}");
        }
      } else {
        final responseData = jsonDecode(response.body);
        final message = (responseData is Map<String, dynamic> &&
                responseData.containsKey('message'))
            ? responseData['message']
            : 'Failed to fetch ride history with status ${response.statusCode}';
        throw Exception(message);
      }
    } catch (e) {
      print('Error fetching ride history: $e');
      rethrow;
    }
  }

  Future<void> updatePaymentStatus({
    required String rideId,
    required String status,
  }) async {
    try {
      final url =
          Uri.parse('${ApiConstants.baseUrl}/rides/payment-status/$rideId');
      final headers = await _getAuthHeaders();
      final body = jsonEncode({'paymentStatus': status});

      final response = await _client.post(
        url,
        headers: headers,
        body: body,
      );

      if (response.statusCode < 200 || response.statusCode >= 300) {
        final responseData = jsonDecode(response.body);
        final message =
            responseData['message'] ?? 'Failed to update payment status';
        throw Exception(message);
      }
    } catch (e) {
      print('Error updating payment status: $e');
      rethrow;
    }
  }
}
