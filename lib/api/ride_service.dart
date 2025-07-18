// lib/api/ride_service.dart
// This file was previously booking_service.dart and has been updated
// to handle ride-specific API calls (start ride, end ride).

import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';
import 'package:revobike/api/api_constants.dart'; // Ensure this path is correct
import 'package:revobike/api/auth_service.dart';

class RideService {
  final http.Client _client;
  final AuthService _authService;

  // Constructor for RideService
  // It takes required authService instance and optional storage and client for dependency injection and testing.
  RideService({
    required AuthService authService,
    FlutterSecureStorage? storage,
    http.Client? client,
  })  : _authService = authService,
        _client = client ?? http.Client();

  // Helper method to retrieve the JWT token from AuthService
  // and format it into the Authorization header.
  Future<Map<String, String>> _getAuthHeaders() async {
    String? token = await _authService.getAuthToken();
    if (token == null) {
      // If no token is found, throw an exception indicating the user is not logged in.
      throw Exception('Authentication token not found. User not logged in.');
    }
    // Return standard JSON content type header plus the Authorization Bearer token
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  Future<Map<String, dynamic>> startRide({
    required String bikeId,
    // Keep these optional parameters as they might be sent from the UI
    double? initialLatitude,
    double? initialLongitude,
  }) async {
    if (bikeId.isEmpty) {
      throw Exception('Bike ID must be a non-empty string.');
    }
    try {
      final url = Uri.parse(
          '${ApiConstants.baseUrl}${ApiConstants.startRideEndpoint}/$bikeId');
      final headers = await _getAuthHeaders(); // Get authenticated headers

      final Map<String, dynamic> requestBody = {
        "bikeId": bikeId, // Required in body as per backend info
      };
      // Add optional initial location if provided
      if (initialLatitude != null) {
        requestBody['initialLatitude'] =
            initialLatitude; // Ensure correct key name for backend
      }
      if (initialLongitude != null) {
        requestBody['initialLongitude'] =
            initialLongitude; // Ensure correct key name for backend
      }

      final response = await _client.post(
        url,
        headers: headers,
        body: jsonEncode(requestBody), // Encode the constructed body
      );

      final dynamic responseData =
          jsonDecode(response.body); // Decode JSON response

      // Check for successful HTTP status code (2xx range), typically 201 for creation
      if (response.statusCode >= 200 && response.statusCode < 300) {
        // --- CRUCIAL MODIFICATION 2: PARSING THE SUCCESS RESPONSE ---
        // Backend specifies response: { "success": true, "data": { ...ride details... } }
        if (responseData is Map<String, dynamic> &&
            responseData.containsKey('data')) {
          final dynamic dataContent = responseData['data'];
          if (dataContent is Map<String, dynamic>) {
            // Return the 'data' object which contains the ride details
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
      rethrow; // Re-throw to propagate the error up the call stack
    }
  }

  Future<Map<String, dynamic>> endRide({
    required String rideId,
    double? finalLatitude,
    double? finalLongitude,
  }) async {
    try {
      final url = Uri.parse(
          '${ApiConstants.baseUrl}${ApiConstants.endRideEndpoint}/$rideId');
      final headers = await _getAuthHeaders();

      Map<String, dynamic>? requestBody;
      if (finalLatitude != null && finalLongitude != null) {
        requestBody = {
          'destination': {
            'type': 'Point',
            'coordinates': [finalLongitude, finalLatitude],
          }
        };
      }

      final response = await _client.post(
        url,
        headers: headers,
        body: requestBody != null ? jsonEncode(requestBody) : null,
      );

      Map<String, dynamic>? responseData;
      try {
        responseData = jsonDecode(response.body) as Map<String, dynamic>;
      } catch (jsonError) {
        if (response.statusCode >= 400) {
          throw Exception(
              'Server returned an error: HTTP ${response.statusCode}. Please try again later.');
        } else {
          throw Exception(
              'Invalid response format from server when ending ride.');
        }
      }

      if (response.statusCode >= 200 && response.statusCode < 300) {
        if (responseData['success'] == true &&
            responseData.containsKey('data')) {
          return responseData['data'] as Map<String, dynamic>;
        } else {
          throw Exception(
              'Invalid response format from server when ending ride.');
        }
      } else {
        final message = responseData['message'] ?? 'Failed to end ride';
        throw Exception(message);
      }
    } catch (e) {
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
        final dynamic responseData =
            jsonDecode(response.body); // Decode to dynamic first

        if (responseData is List) {
          // Case 1: The response is directly an array (as your initial example showed)
          return List<Map<String, dynamic>>.from(responseData);
        } else if (responseData is Map<String, dynamic>) {
          // Case 2: The response is a map, check for common keys that contain the list of rides
          if (responseData.containsKey('data') &&
              responseData['data'] is List) {
            return List<Map<String, dynamic>>.from(responseData['data']);
          } else if (responseData.containsKey('rides') &&
              responseData['rides'] is List) {
            // Check for a 'rides' key
            return List<Map<String, dynamic>>.from(responseData['rides']);
          } else if (responseData.length == 1) {
            // If the map has only one key and its value is a list, return that list
            final firstValue = responseData.values.first;
            if (firstValue is List) {
              return List<Map<String, dynamic>>.from(firstValue);
            }
          }
          // If it's a map but doesn't contain a known list key ('data' or 'rides')
          throw Exception(
              "Unexpected map structure for ride history. Expected 'data' or 'rides' key containing a list.");
        } else {
          // If the top-level response is neither a List nor a Map (e.g., null, string, number directly)
          throw Exception(
              "Unexpected top-level response format for ride history: ${responseData.runtimeType}");
        }
      } else {
        // Handle non-2xx status codes (error responses from the server)
        final responseData = jsonDecode(response.body);
        final message = (responseData is Map<String, dynamic> &&
                responseData.containsKey('message'))
            ? responseData[
                'message'] // Extract 'message' if available in the error response
            : 'Failed to fetch ride history with status ${response.statusCode}';
        throw Exception(message);
      }
    } catch (e) {
      rethrow; // Re-throw to propagate the error up
    }
  }
}
