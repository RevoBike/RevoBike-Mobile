// lib/api/ride_service.dart
// This file was previously booking_service.dart and has been updated
// to handle ride-specific API calls (start ride, end ride).

import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';
import 'package:revobike/api/api_constants.dart'; // Ensure this path is correct
import 'package:revobike/api/auth_service.dart';

class RideService {
  final FlutterSecureStorage _storage;
  final http.Client _client;
  final AuthService _authService;

  // Constructor for RideService
  // It takes required authService instance and optional storage and client for dependency injection and testing.
  RideService({
    required AuthService authService,
    FlutterSecureStorage? storage,
    http.Client? client,
  })  : _authService = authService,
        _storage = storage ?? const FlutterSecureStorage(),
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

  /// Starts a ride by sending the bike ID (in path and body) and optional initial location to the backend.
  ///
  /// This method makes a POST request to the `/rides/start/:bikeId` endpoint.
  /// It expects a response containing `{ "success": true, "data": { ...ride details... } }`.
  ///
  /// [bikeId]: The unique identifier of the bike to be started. This is used in the URL path AND the request body.
  /// [initialLatitude]: Optional. The latitude of the user's starting location.
  /// [initialLongitude]: Optional. The longitude of the user's starting location.
  /// Returns a [Future<Map<String, dynamic>>] containing the details of the started ride (the 'data' object).
  /// Throws an [Exception] if the API call fails or the response is invalid.
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
      // Construct the full URL using base URL and the start ride endpoint,
      // appending the bikeId directly to the path as per your API spec.
      final url = Uri.parse(
          '${ApiConstants.baseUrl}${ApiConstants.startRideEndpoint}/$bikeId');
      final headers = await _getAuthHeaders(); // Get authenticated headers

      // --- CRUCIAL MODIFICATION 1: CONSTRUCTING THE REQUEST BODY ---
      // The backend explicitly expects "bikeId" in the JSON body.
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
      // --- END OF CRUCIAL MODIFICATION 1 ---

      final response = await _client.post(
        url,
        headers: headers,
        body: jsonEncode(requestBody), // Encode the constructed body
      );

      print(
          'Start Ride response: ${response.statusCode} - ${response.body}'); // Log full response

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
          // If success status but 'data' key is missing or response is not a Map
          throw Exception(
              "Invalid 'startRide' success response format. Expected a map with 'data' key.");
        }
        // --- END OF CRUCIAL MODIFICATION 2 ---
      } else {
        // Handle non-2xx status codes (error responses from the server)
        // Extract 'message' from the response if available, otherwise provide a generic one.
        final message = (responseData is Map<String, dynamic> &&
                responseData.containsKey('message'))
            ? responseData['message']
            : 'Failed to start ride with status ${response.statusCode}';
        throw Exception(message);
      }
    } catch (e) {
      // Catch any network or parsing errors and rethrow them after logging
      print('Error starting ride: $e');
      rethrow; // Re-throw to propagate the error up the call stack
    }
  }

  /// Ends a ride by sending the ride ID and final location to the backend.
  ///
  /// This method makes a POST request to the `/rides/end/{rideId}` endpoint.
  /// It includes the final latitude and longitude in the request body.
  /// It expects a response confirming ride end and potentially ride summary details
  /// like total cost and distance.
  ///
  /// [rideId]: The unique identifier of the active ride to be ended.
  /// [finalLatitude]: The latitude of the user's location when ending the ride.
  /// [finalLongitude]: The longitude of the user's location when ending the ride.
  /// Returns a [Future<Map<String, dynamic>>] containing details of the ended ride.
  /// Throws an [Exception] if the API call fails or the response is invalid.
  Future<Map<String, dynamic>> endRide({
    required String rideId,
    required double finalLatitude,
    required double finalLongitude,
    // You can add more parameters here if your backend expects them (e.g., endTime)
  }) async {
    try {
      // Construct the full URL using base URL, end ride endpoint, and the rideId in the path.
      final url = Uri.parse(
          '${ApiConstants.baseUrl}${ApiConstants.endRideEndpoint}/$rideId');
      final headers = await _getAuthHeaders(); // Get authenticated headers

      // Create the request body with final location data
      final body = {
        'finalLatitude': finalLatitude,
        'finalLongitude': finalLongitude,
        // Add other properties your backend expects for ending a ride (e.g., 'endTime': DateTime.now().toIso8601String())
      };

      // Make a POST request to end the ride
      final response = await _client.post(
        url,
        headers: headers,
        body: jsonEncode(body), // Encode body to JSON
      );

      print(
          'End Ride response: ${response.statusCode} - ${response.body}'); // Log full response

      // Try to decode JSON response safely
      Map<String, dynamic>? responseData;
      try {
        responseData = jsonDecode(response.body) as Map<String, dynamic>;
      } catch (jsonError) {
        print('Failed to parse end ride response as JSON: $jsonError');
        throw Exception(
            'Invalid response format from server when ending ride.');
      }

      // Check for successful HTTP status code (2xx range)
      if (response.statusCode >= 200 && response.statusCode < 300) {
        // Return the entire response data as the ride details object (no 'success' field expected)
        return responseData;
      } else {
        // For non-2xx status codes, extract backend's error message or provide a generic one
        final message = responseData?['message'] ?? 'Failed to end ride';
        throw Exception(message);
      }
    } catch (e) {
      // Catch any network or parsing errors and rethrow them after logging
      print('Error ending ride: $e');
      rethrow; // Re-throw to propagate the error up the call stack
    }
  }

  /// Fetches the ride history for the authenticated user.
  ///
  /// Makes a GET request to the `/rides/history` endpoint.
  /// Returns a [Future<List<Map<String, dynamic>>] representing the list of rides.
  /// Throws an [Exception] if the API call fails or the response is invalid.
  Future<List<Map<String, dynamic>>> getRideHistory() async {
    try {
      final url = Uri.parse(
          '${ApiConstants.baseUrl}${ApiConstants.rideHistoryEndpoint}');
      final headers = await _getAuthHeaders();

      final response = await _client.get(url, headers: headers);

      print(
          'Get Ride History response: ${response.statusCode} - ${response.body}');

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
      print('Error fetching ride history: $e');
      rethrow; // Re-throw to propagate the error up
    }
  }
}
