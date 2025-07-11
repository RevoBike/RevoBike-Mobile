// lib/api/chapa_service.dart
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:revobike/api/api_constants.dart';
import 'package:revobike/api/auth_service.dart'; // To get the auth token for authenticated requests

import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:revobike/api/api_constants.dart';
import 'package:revobike/api/auth_service.dart'; // To get the auth token for authenticated requests

class ChapaService {
  final http.Client client;
  final AuthService _authService; // Inject AuthService to get token

  ChapaService({http.Client? client, AuthService? authService})
      : client = client ?? http.Client(),
        _authService = authService ?? AuthService(); // Initialize AuthService

  /// Initializes a payment with your backend using the new /payments/initiate/:rideId endpoint.
  /// Returns the checkout URL for the payment.
  Future<String> initiatePayment({required String rideId}) async {
    try {
      final token = await _authService.getAuthToken();
      if (token == null) {
        throw Exception('Authentication token not found. User not logged in.');
      }

      final url = Uri.parse(
          '${ApiConstants.baseUrl}${ApiConstants.paymentInitiateEndpoint}/$rideId');
      final response = await client.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('Payment initiation response status: ${response.statusCode}');
      print('Payment initiation response body: ${response.body}');

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200 && responseData['success'] == true) {
        final String checkoutUrl = responseData['checkout_url'];
        if (checkoutUrl.isNotEmpty) {
          return checkoutUrl;
        } else {
          throw Exception('Checkout URL not found in response.');
        }
      } else {
        throw Exception(
            responseData['message'] ?? 'Failed to initiate payment.');
      }
    } catch (e) {
      print('Error initiating payment: $e');
      rethrow;
    }
  }

  /// Verifies the payment status with your backend using the new /payments/callback/:tx_ref endpoint.
  /// Returns a map with status and data or message.
  Future<Map<String, dynamic>> verifyPayment(String txRef) async {
    try {
      final token = await _authService.getAuthToken();
      if (token == null) {
        throw Exception('Authentication token not found. User not logged in.');
      }

      final url = Uri.parse(
          '${ApiConstants.baseUrl}${ApiConstants.paymentCallbackEndpoint}/$txRef');
      final response = await client.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        // The backend returns plain text for success cases, so we interpret accordingly
        final responseBody = response.body;
        if (responseBody.contains('Payment verified')) {
          return {'status': 'success'};
        } else if (responseBody.contains('Payment already verified')) {
          return {'status': 'already_verified'};
        } else {
          return {'status': 'failed', 'message': responseBody};
        }
      } else if (response.statusCode == 404) {
        return {'status': 'not_found', 'message': 'Payment not found'};
      } else if (response.statusCode == 400) {
        return {
          'status': 'failed',
          'message': 'Payment failed or not completed'
        };
      } else {
        throw Exception('Unexpected response status: ${response.statusCode}');
      }
    } catch (e) {
      print('Error verifying payment: $e');
      rethrow;
    }
  }
}
