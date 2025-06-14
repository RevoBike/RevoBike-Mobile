// lib/api/auth_service.dart (assuming this is the correct path)
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'dart:convert';
import 'package:revobike/data/models/User.dart'; // Ensure this path is correct
import 'package:revobike/api/api_constants.dart'; // Ensure this path is correct for your project structure

class AuthService {
  static const _tokenKey = 'jwt'; // Key used for storing the JWT token
  final FlutterSecureStorage _storage;
  final http.Client client;

  // Use factory constructor or simple constructor
  AuthService({
    FlutterSecureStorage? storage,
    http.Client? client,
  })  : _storage = storage ?? const FlutterSecureStorage(),
        client = client ?? http.Client();

  // Helper to get authenticated headers
  Future<Map<String, String>> _getAuthHeaders() async {
    final token = await _storage.read(key: _tokenKey);
    if (token == null) {
      throw Exception('Authentication token not found. User not logged in.');
    }
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // --- Registration Function ---
  Future<Map<String, dynamic>> register(String name, String email,
      String password, String universityId, String phoneNumber) async {
    try {
      final url =
          Uri.parse(ApiConstants.baseUrl + ApiConstants.registerEndpoint);
      final response = await client.post(
        url,
        headers: {
          'Content-Type': 'application/json'
        }, // IMPORTANT: Set content type
        body: jsonEncode({
          // IMPORTANT: Encode body to JSON
          'name': name,
          'email': email,
          'password': password,
          'phone_number': phoneNumber,
          'universityId': universityId
        }),
      );

      print('Backend response: ${response.body}');
      final responseData = jsonDecode(response.body);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        // Handle successful registration. Your backend might return a token or a success message.
        // If it returns a token, you can store it here similar to login.
        // final String? token = responseData['token'];
        // if (token != null) {
        //   await _storage.write(key: _tokenKey, value: token);
        // }
        return responseData; // Return the full response data
      } else {
        final message = responseData['message'] ?? 'Registration failed';
        throw Exception(message);
      }
    } catch (e) {
      print('Error registering user: $e');
      rethrow;
    }
  }

  // --- Send Password Reset Link Function ---
  Future<Map<String, dynamic>> sendPasswordResetLink(String email) async {
    try {
      final url =
          Uri.parse(ApiConstants.baseUrl + ApiConstants.forgotPasswordEndpoint);
      final response = await client.post(
        url,
        headers: {
          'Content-Type': 'application/json'
        }, // IMPORTANT: Set content type
        body: jsonEncode({'email': email}), // IMPORTANT: Encode body to JSON
      );

      print('Backend response: ${response.body}');
      final responseData = jsonDecode(response.body);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return responseData;
      } else {
        final message = responseData['message'] ?? 'Failed to send reset link';
        throw Exception(message);
      }
    } catch (e) {
      print('Error sending password reset link: $e');
      rethrow;
    }
  }

  // --- Reset Password Function ---
  Future<Map<String, dynamic>> resetPassword(
      String email, String otp, String newPassword) async {
    try {
      final url = Uri.parse(ApiConstants.baseUrl +
          ApiConstants
              .resetPasswordEndpoint); // Assuming a separate resetPasswordEndpoint or handling by forgotPasswordEndpoint
      final response = await client.post(
        url,
        headers: {
          'Content-Type': 'application/json'
        }, // IMPORTANT: Set content type
        body: jsonEncode({
          // IMPORTANT: Encode body to JSON
          'email': email,
          'otp': otp,
          'newPassword': newPassword,
        }),
      );

      print('Backend response: ${response.body}');
      final responseData = jsonDecode(response.body);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return responseData;
      } else {
        final message = responseData['message'] ?? 'Failed to reset password';
        throw Exception(message);
      }
    } catch (e) {
      print('Error resetting password: $e');
      rethrow;
    }
  }

  // --- Login Function ---
  Future<String> login(String email, String password) async {
    try {
      final url = Uri.parse(ApiConstants.baseUrl + ApiConstants.loginEndpoint);
      final response = await client.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      print('Backend response: ${response.body}');
      final data = jsonDecode(response.body);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        // Assuming your backend returns { "success": true, "token": "...", "user": { ... } }
        final token = data['token'];
        if (token == null || token is! String) {
          throw Exception('Invalid or missing token received');
        }
        await _storage.write(key: _tokenKey, value: token);
        return token;
      } else {
        final message = data['message'] ?? 'Login failed';
        throw Exception(message);
      }
    } catch (e) {
      print('Error logging in: $e');
      rethrow;
    }
  }

  // --- Fetch User Profile Function (Requires Auth Token) ---
  Future<UserModel> fetchUserProfile() async {
    try {
      final url = Uri.parse(ApiConstants.baseUrl +
          ApiConstants
              .userProfileEndpoint); // IMPORTANT: Use correct profile endpoint
      final headers =
          await _getAuthHeaders(); // IMPORTANT: Get authenticated headers
      final response = await client.get(
        url,
        headers: headers, // IMPORTANT: Send headers with token
      );

      print('Backend profile response: ${response.body}');
      final data = jsonDecode(response.body);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        // Assuming your backend returns { "success": true, "user": { ... } } or just the user object
        // Adjust 'data['user']' based on your actual backend response structure
        return UserModel.fromJson(data['user'] ?? data);
      } else {
        final message = data['message'] ?? 'Failed to fetch user profile';
        throw Exception(message);
      }
    } catch (e) {
      print('Error fetching user profile: $e');
      rethrow;
    }
  }

  // --- Verify OTP Function ---
  Future<bool> verifyOtp(String email, String otp) async {
    try {
      final url =
          Uri.parse(ApiConstants.baseUrl + ApiConstants.verifyOtpEndpoint);
      final response = await client.post(
        url,
        headers: {
          'Content-Type': 'application/json'
        }, // IMPORTANT: Set content type
        body: jsonEncode({
          // IMPORTANT: Encode body to JSON
          'email': email,
          'otp': otp,
        }),
      );

      print('Backend response: ${response.body}');
      final data = jsonDecode(response.body);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final token = data['token'];
        if (token != null) {
          await _storage.write(key: _tokenKey, value: token);
          return true;
        } else {
          // It's possible verifyOtp doesn't return a token, just success.
          // Adjust logic based on your backend.
          return data['success'] ==
              true; // Example: if backend sends {'success': true}
        }
      } else {
        final message = data['message'] ?? 'OTP verification failed';
        throw Exception(message);
      }
    } catch (e) {
      print('Error verifying OTP: $e');
      rethrow;
    }
  }

  // --- Logout Function ---
  Future<void> logout() async {
    await _storage.delete(key: _tokenKey);
  }

  // --- Check if user is authenticated (token exists and not expired) ---
  Future<bool> get isAuthenticated async {
    final token = await _storage.read(key: _tokenKey);
    return token != null && !JwtDecoder.isExpired(token);
  }

  // --- Delete Account Function (Requires Auth Token) ---
}
