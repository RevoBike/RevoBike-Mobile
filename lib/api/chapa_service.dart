// lib/api/chapa_service.dart
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

  /// Initializes a Chapa payment with your backend.
  /// Your backend should then call Chapa's initialize endpoint and return a checkout URL.
  Future<String> initializePayment({
    required String rideId,
    required String amount,
    required String currency,
    required String email,
    required String firstName,
    required String lastName,
    required String txRef,
    required String returnUrl,
    String? phoneNumber,
    String? description,
    String? title,
    String? logo,
  }) async {
    try {
      final token = await _authService.getAuthToken();
      if (token == null) {
        throw Exception('Authentication token not found. User not logged in.');
      }

      final url = Uri.parse(
          '${ApiConstants.baseUrl}${ApiConstants.chapaInitiatePaymentEndpoint}/$rideId');
      final response = await client.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token', // Include auth token
        },
        body: jsonEncode({
          'amount': amount,
          'currency': currency,
          'email': email,
          'first_name': firstName,
          'last_name': lastName,
          'tx_ref': txRef,
          'return_url': returnUrl, // This URL is crucial for Chapa's redirect
          'phone_number': phoneNumber,
          'description': description,
          'title': title,
          'logo': logo,
        }),
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        if (responseData['status'] == 'success' &&
            responseData['data'] != null) {
          final String checkoutUrl = responseData['data']['checkout_url'];
          if (checkoutUrl.isNotEmpty) {
            return checkoutUrl;
          } else {
            throw Exception('Checkout URL not found in response.');
          }
        } else {
          throw Exception(
              responseData['message'] ?? 'Failed to initialize payment.');
        }
      } else {
        throw Exception(responseData['message'] ??
            'Backend error initializing payment: ${response.statusCode}');
      }
    } catch (e) {
      print('Error initializing Chapa payment: $e');
      rethrow;
    }
  }

  /// Verifies the Chapa payment status with your backend.
  /// Your backend should then call Chapa's verify endpoint and return the status.
  Future<Map<String, dynamic>> verifyPayment(String txRef) async {
    try {
      final token = await _authService.getAuthToken();
      if (token == null) {
        throw Exception('Authentication token not found. User not logged in.');
      }

      final url = Uri.parse(
          '${ApiConstants.baseUrl}${ApiConstants.chapaVerifyPaymentEndpoint}/$txRef');
      final response = await client.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token', // Include auth token
        },
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        if (responseData['status'] == 'success') {
          return {'status': 'success', 'data': responseData['data']};
        } else {
          return {'status': 'failed', 'message': responseData['message']};
        }
      } else {
        throw Exception(responseData['message'] ??
            'Backend error verifying payment: ${response.statusCode}');
      }
    } catch (e) {
      print('Error verifying Chapa payment: $e');
      rethrow;
    }
  }
}
