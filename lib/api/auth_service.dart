// lib/api/auth_service.dart
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'dart:convert';
import 'package:revobike/data/models/User.dart';
import 'package:revobike/api/api_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class AuthService {
  // Singleton instance
  static final AuthService _instance = AuthService._internal();

  // Factory constructor to return the same instance
  factory AuthService() {
    return _instance;
  }

  // Private constructor
  AuthService._internal({
    FlutterSecureStorage? secureStorage,
    http.Client? client,
  })  : _secureStorage = secureStorage ?? const FlutterSecureStorage(),
        client = client ?? http.Client();

  static const _tokenKey = 'jwt';
  static const _userProfileKey = 'user_profile';
  static const _onboardingSeenKey = 'onboarding_seen';

  final FlutterSecureStorage _secureStorage;
  final http.Client client;

  // Helper method to delete keys from storage
  Future<void> _deleteKey(String key) async {
    // For _onboardingSeenKey, always use SharedPreferences for deletion
    if (key == _onboardingSeenKey) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(key);
      return;
    }

    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(key);
    } else {
      await _secureStorage.delete(key: key);
    }
  }

  Future<String?> getAuthToken() async {
    String? token;
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      token = prefs.getString(_tokenKey);
    } else {
      token = await _secureStorage.read(key: _tokenKey);
    }
    return token;
  }

  Future<void> _saveUserProfile(UserModel user) async {
    final userJson = jsonEncode(user.toJson());
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_userProfileKey, userJson);
    } else {
      await _secureStorage.write(key: _userProfileKey, value: userJson);
    }
  }

  Future<UserModel?> _loadUserProfile() async {
    String? userJson;
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      userJson = prefs.getString(_userProfileKey);
    } else {
      userJson = await _secureStorage.read(key: _userProfileKey);
    }
    if (userJson != null) {
      return UserModel.fromJson(jsonDecode(userJson));
    }
    return null;
  }

  // Method to set onboarding as seen - ALWAYS uses SharedPreferences
  Future<void> setOnboardingSeen() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_onboardingSeenKey, 'true');
  }

  // Method to check if onboarding has been seen - ALWAYS uses SharedPreferences
  Future<bool> hasSeenOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    String? seen = prefs.getString(_onboardingSeenKey);
    return seen == 'true';
  }

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

      final responseData = jsonDecode(response.body);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return responseData;
      } else {
        final message = responseData['message'] ?? 'Registration failed';
        throw Exception(message);
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> sendPasswordResetLink(String email) async {
    try {
      final url =
          Uri.parse(ApiConstants.baseUrl + ApiConstants.forgotPasswordEndpoint);
      final response = await client.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return responseData;
      } else {
        final message = responseData['message'] ?? 'Failed to send reset link';
        throw Exception(message);
      }
    } catch (e) {
      rethrow;
    }
  }

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

      final responseData = jsonDecode(response.body);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return responseData;
      } else {
        final message = responseData['message'] ?? 'Failed to reset password';
        throw Exception(message);
      }
    } catch (e) {
      rethrow;
    }
  }

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

      final data = jsonDecode(response.body);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final token = data['token'];
        if (token == null || token is! String) {
          throw Exception('Invalid or missing token received');
        }
        if (kIsWeb) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString(_tokenKey, token);
          // Verify immediate read after saving
        } else {
          await _secureStorage.write(key: _tokenKey, value: token);
          // Verify immediate read after saving
        }

        final Map<String, dynamic>? userData = data['user'];
        if (userData != null) {
          await _saveUserProfile(UserModel.fromJson(userData));
        }
        await setOnboardingSeen(); // Set onboarding as seen on successful login
        return token;
      } else {
        final message = data['message'] ?? 'Login failed';
        throw Exception(message);
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<UserModel?> fetchUserProfile() async {
    return await _loadUserProfile();
  }

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

      final data = jsonDecode(response.body);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final token = data['token'];
        if (token != null) {
          if (kIsWeb) {
            final prefs = await SharedPreferences.getInstance();
            await prefs.setString(_tokenKey, token);
          } else {
            await _secureStorage.write(key: _tokenKey, value: token);
          }
          return true;
        } else {
          return data['success'] == true;
        }
      } else {
        final message = data['message'] ?? 'OTP verification failed';
        throw Exception(message);
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> logout() async {
    await _deleteKey(_tokenKey);
    await _deleteKey(_userProfileKey);
    await _deleteKey(
        _onboardingSeenKey); // Ensure onboarding is reset on logout for testing
  }

  Future<bool> get isAuthenticated async {
    String? token = await getAuthToken(); // Use the getter to log retrieval
    if (token == null) {
      return false;
    }
    bool expired = JwtDecoder.isExpired(token);
    return !expired;
  }
}
