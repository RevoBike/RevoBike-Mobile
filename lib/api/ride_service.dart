// lib/api/ride_service.dart
// This file was previously booking_service.dart and has been updated
// to handle ride-specific API calls (start ride, end ride).

import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';
import 'package:revobike/api/api_constants.dart'; // Ensure this path is correct

class RideService {
  final FlutterSecureStorage _storage;
  final http.Client _client;

  // Constructor for RideService
  // It takes optional storage and client instances for dependency injection and testing.
  RideService({
    FlutterSecureStorage? storage,
    http.Client? client,
  })  : _storage = storage ??
            const FlutterSecureStorage(), // Use provided storage or default
        _client = client ?? http.Client(); // Use provided client or default

  // Helper method to retrieve the JWT token from secure storage
  // and format it into the Authorization header.
  Future<Map<String, String>> _getAuthHeaders() async {
    final token =
        await _storage.read(key: 'jwt'); // Read JWT token from storage
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

  /// Starts a ride by sending the bike ID to the backend.
  ///
  /// This method makes a POST request to the `/rides/start/{bikeId}` endpoint.
  /// It expects a response containing 'success: true' and a 'ride' object
  /// which should include the `rideId` and potentially other initial ride details.
  ///
  /// [bikeId]: The unique identifier of the bike to be started.
  /// Returns a [Future<Map<String, dynamic>>] containing the details of the started ride.
  /// Throws an [Exception] if the API call fails or the response is invalid.
  Future<Map<String, dynamic>> startRide({
    required String bikeId,
  }) async {
    try {
      // Construct the full URL using base URL and the start ride endpoint,
      // appending the bikeId directly to the path as per your API spec.
      final url = Uri.parse(
          '${ApiConstants.baseUrl}${ApiConstants.startRideEndpoint}/$bikeId');
      final headers = await _getAuthHeaders(); // Get authenticated headers

      // Make a POST request. Assuming no specific body is required for this endpoint
      // other than the bikeId in the URL path. If your backend requires an empty JSON body,
      // you can uncomment `body: jsonEncode({})`.
      final response = await _client.post(
        url,
        headers: headers,
        // body: jsonEncode({}), // Uncomment if your backend expects an empty JSON body for this POST
      );

      print(
          'Start Ride response: ${response.statusCode} - ${response.body}'); // Log full response

      final responseData = jsonDecode(response.body); // Decode JSON response

      // Check for successful HTTP status code (2xx range)
      if (response.statusCode >= 200 && response.statusCode < 300) {
        // Return the entire response data as the ride object (no 'success' field expected)
        return responseData as Map<String, dynamic>;
      } else {
        // For non-2xx status codes, extract backend's error message or provide a generic one
        final message = responseData['message'] ?? 'Failed to start ride';
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

      final responseData = jsonDecode(response.body); // Decode JSON response

      // Check for successful HTTP status code (2xx range)
      if (response.statusCode >= 200 && response.statusCode < 300) {
        // Return the entire response data as the ride details object (no 'success' field expected)
        return responseData as Map<String, dynamic>;
      } else {
        // For non-2xx status codes, extract backend's error message or provide a generic one
        final message = responseData['message'] ?? 'Failed to end ride';
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
      final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.rideHistoryEndpoint}');
      final headers = await _getAuthHeaders();

      final response = await _client.get(url, headers: headers);

      print('Get Ride History response: ${response.statusCode} - ${response.body}');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final List<dynamic> responseData = jsonDecode(response.body);
        // Ensure the response is a list of maps
        return responseData.cast<Map<String, dynamic>>();
      } else {
        final responseData = jsonDecode(response.body);
        final message = responseData['message'] ?? 'Failed to fetch ride history';
        throw Exception(message);
      }
    } catch (e) {
      print('Error fetching ride history: $e');
      rethrow;
    }
  }
}
