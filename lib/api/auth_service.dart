// lib/api/auth_service.dart
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'dart:convert';
import 'package:revobike/data/models/User.dart'; // Ensure this path is correct
import 'package:revobike/api/api_constants.dart'; // Ensure this path is correct for your project structure

class AuthService {
  static const _tokenKey = 'jwt';
  static const _userProfileKey =
      'user_profile'; // New key for storing user profile JSON
  final FlutterSecureStorage _storage;
  final http.Client client;

  AuthService({
    FlutterSecureStorage? storage,
    http.Client? client,
  })  : _storage = storage ?? const FlutterSecureStorage(),
        client = client ?? http.Client();

  // Helper for getting the stored token (remains the same)
  Future<String?> getAuthToken() async {
    final prefs = await _storage.read(key: _tokenKey);
    return prefs;
  }

  // --- Helper to save User Profile to secure storage ---
  Future<void> _saveUserProfile(UserModel user) async {
    final userJson =
        jsonEncode(user.toJson()); // Convert UserModel to JSON string
    await _storage.write(key: _userProfileKey, value: userJson);
  }

  // --- Helper to load User Profile from secure storage ---
  Future<UserModel?> _loadUserProfile() async {
    final userJson = await _storage.read(key: _userProfileKey);
    if (userJson != null) {
      return UserModel.fromJson(jsonDecode(userJson));
    }
    return null; // Return null if no user profile is stored
  }

  // --- Registration Function (remains mostly same, but can store token if API returns it) ---
  Future<Map<String, dynamic>> register(String name, String email,
      String password, String universityId, String phoneNumber) async {
    try {
      final url =
          Uri.parse(ApiConstants.baseUrl + ApiConstants.registerEndpoint);
      final response = await client.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
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
        // If your registration API also returns a token AND user data, store it here:
        // final String? token = responseData['token'];
        // final Map<String, dynamic>? userData = responseData['user'];
        // if (token != null && userData != null) {
        //   await _storage.write(key: _tokenKey, value: token);
        //   await _saveUserProfile(UserModel.fromJson(userData));
        // }
        return responseData;
      } else {
        final message = responseData['message'] ?? 'Registration failed';
        throw Exception(message);
      }
    } catch (e) {
      print('Error registering user: $e');
      rethrow;
    }
  }

  // --- Send Password Reset Link (remains same) ---
  Future<Map<String, dynamic>> sendPasswordResetLink(String email) async {
    try {
      final url =
          Uri.parse(ApiConstants.baseUrl + ApiConstants.forgotPasswordEndpoint);
      final response = await client.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
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

  // --- Reset Password (remains same) ---
  Future<Map<String, dynamic>> resetPassword(
      String email, String otp, String newPassword) async {
    try {
      final url =
          Uri.parse(ApiConstants.baseUrl + ApiConstants.resetPasswordEndpoint);
      final response = await client.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
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

  // --- Login Function (UPDATED to store user profile) ---
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
        final token = data['token'];
        if (token == null || token is! String) {
          throw Exception('Invalid or missing token received');
        }
        await _storage.write(key: _tokenKey, value: token);

        // Store user profile from login response
        final Map<String, dynamic>? userData = data['user'];
        if (userData != null) {
          await _saveUserProfile(UserModel.fromJson(userData));
        } else {
          print('Warning: No user data found in login response.');
        }

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

  // --- Fetch User Profile Function (UPDATED to load from storage) ---
  Future<UserModel?> fetchUserProfile() async {
    // This method now loads the profile from secure storage, not from an API endpoint
    return await _loadUserProfile();
  }

  // --- Verify OTP (remains same) ---
  Future<bool> verifyOtp(String email, String otp) async {
    try {
      final url =
          Uri.parse(ApiConstants.baseUrl + ApiConstants.verifyOtpEndpoint);
      final response = await client.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
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
          // If verifyOtp also returns user data, store it:
          // final Map<String, dynamic>? userData = data['user'];
          // if (userData != null) {
          //   await _saveUserProfile(UserModel.fromJson(userData));
          // }
          return true;
        } else {
          return data['success'] == true;
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

  // --- Logout Function (UPDATED to also clear user profile) ---
  Future<void> logout() async {
    await _storage.delete(key: _tokenKey);
    await _storage.delete(key: _userProfileKey); // Clear stored user profile
  }

  // --- Check if user is authenticated (remains same) ---
  Future<bool> get isAuthenticated async {
    final token = await _storage.read(key: _tokenKey);
    return token != null && !JwtDecoder.isExpired(token);
  }

  // --- Delete Account (remains same in functionality, assuming it's an authenticated endpoint) ---
}
