// lib/api/chapa_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:revobike/api/api_constants.dart'; // Ensure correct path

class ChapaService {
  final FlutterSecureStorage _storage;
  final http.Client _client;

  ChapaService({
    FlutterSecureStorage? storage,
    http.Client? client,
  })  : _storage = storage ?? const FlutterSecureStorage(),
        _client = client ?? http.Client();

  // Helper to get authenticated headers
  Future<Map<String, String>> _getAuthHeaders() async {
    final token = await _storage.read(key: 'jwt');
    if (token == null) {
      throw Exception('Authentication token not found. User not logged in.');
    }
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  /// Initiates a Chapa payment through your backend.
  /// Your backend will call Chapa's API and return the checkout URL.
  Future<String> initializePayment({
    required String amount,
    required String currency,
    required String email,
    required String firstName,
    required String lastName,
    required String txRef,
    String? callbackUrl, // Chapa callback URL for your backend
    String?
        returnUrl, // URL to redirect user to after payment (your Flutter app's deep link or simple success page)
    String? description,
  }) async {
    final url = Uri.parse(
        '${ApiConstants.baseUrl}${ApiConstants.chapaInitializePaymentEndpoint}');
    final headers = await _getAuthHeaders();

    final body = jsonEncode({
      'amount': amount,
      'currency': currency,
      'email': email,
      'first_name': firstName,
      'last_name': lastName,
      'tx_ref':
          txRef, // Unique transaction reference, ideally from your backend
      'callback_url': callbackUrl ??
          '${ApiConstants.baseUrl}/chapa-webhook', // Default or your specific backend webhook
      'return_url': returnUrl ??
          'revobike://payment-success', // Your app's deep link or success URL
      'description': description ?? 'RevoBike Ride Payment',
    });

    try {
      final response = await _client.post(
        url,
        headers: headers,
        body: body,
      );

      print(
          'Chapa Initialize response: ${response.statusCode} - ${response.body}');

      final responseData = jsonDecode(response.body);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        if (responseData['status'] == 'success' &&
            responseData['data'] != null &&
            responseData['data']['checkout_url'] != null) {
          return responseData['data']['checkout_url'] as String;
        } else {
          throw Exception(
              responseData['message'] ?? 'Failed to get Chapa checkout URL.');
        }
      } else {
        throw Exception(responseData['message'] ??
            'Backend failed to initialize Chapa payment.');
      }
    } catch (e) {
      print('Error initializing Chapa payment: $e');
      rethrow;
    }
  }

  /// (Optional) Verifies a Chapa transaction status via your backend.
  /// This is often handled entirely by your backend via webhooks.
  Future<Map<String, dynamic>> verifyPayment(String txRef) async {
    final url = Uri.parse(
        '${ApiConstants.baseUrl}${ApiConstants.chapaVerifyPaymentEndpoint}/$txRef');
    final headers = await _getAuthHeaders();

    try {
      final response = await _client.get(
        url,
        headers: headers,
      );

      print('Chapa Verify response: ${response.statusCode} - ${response.body}');

      final responseData = jsonDecode(response.body);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return responseData; // Contains payment status
      } else {
        throw Exception(responseData['message'] ??
            'Failed to verify payment with backend.');
      }
    } catch (e) {
      print('Error verifying Chapa payment: $e');
      rethrow;
    }
  }
}
