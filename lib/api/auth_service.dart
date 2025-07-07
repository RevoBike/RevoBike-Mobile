// lib/api/auth_service.dart
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'dart:convert';
import 'package:revobike/data/models/User.dart';
import 'package:revobike/api/api_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io' show Platform;
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
      print('AuthService: DEBUG - Deleted onboarding_seen from SharedPreferences');
      return;
    }

    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(key);
      print('AuthService (Web): DEBUG - Deleted key: $key from SharedPreferences');
    } else {
      await _secureStorage.delete(key: key);
      print('AuthService (Mobile): DEBUG - Deleted key: $key from SecureStorage');
    }
  }

  Future<String?> getAuthToken() async {
    String? token;
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      token = prefs.getString(_tokenKey);
      print('AuthService (Web): DEBUG - getAuthToken - Retrieved token: ${token != null ? "FOUND" : "NULL"}');
    } else {
      token = await _secureStorage.read(key: _tokenKey);
      print('AuthService (Mobile): DEBUG - getAuthToken - Retrieved token: ${token != null ? "FOUND" : "NULL"}');
    }
    return token;
  }

  Future<void> _saveUserProfile(UserModel user) async {
    final userJson = jsonEncode(user.toJson());
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_userProfileKey, userJson);
      print('AuthService (Web): DEBUG - Saved user profile to SharedPreferences');
    } else {
      await _secureStorage.write(key: _userProfileKey, value: userJson);
      print('AuthService (Mobile): DEBUG - Saved user profile to SecureStorage');
    }
  }

  Future<UserModel?> _loadUserProfile() async {
    String? userJson;
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      userJson = prefs.getString(_userProfileKey);
      print('AuthService (Web): DEBUG - Loaded user profile from SharedPreferences: ${userJson != null}');
    } else {
      userJson = await _secureStorage.read(key: _userProfileKey);
      print('AuthService (Mobile): DEBUG - Loaded user profile from SecureStorage: ${userJson != null}');
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
    final String? verifiedSeen = prefs.getString(_onboardingSeenKey);
    print('AuthService: DEBUG - setOnboardingSeen - Set $_onboardingSeenKey to "true". Verified read: "$verifiedSeen"');
  }

  // Method to check if onboarding has been seen - ALWAYS uses SharedPreferences
  Future<bool> hasSeenOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    String? seen = prefs.getString(_onboardingSeenKey);
    print('AuthService: DEBUG - hasSeenOnboarding - Retrieved $_onboardingSeenKey: "$seen"');
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
      print('Error registering user: $e'); // Keep error logs
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
      print('Error sending password reset link: $e'); // Keep error logs
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
      print('Error resetting password: $e'); // Keep error logs
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
          print('AuthService (Web): DEBUG - Login - Saved token to SharedPreferences');
          // Verify immediate read after saving
          final String? verifiedToken = prefs.getString(_tokenKey);
          print('AuthService (Web): DEBUG - Login - Verified token read: ${verifiedToken != null ? "FOUND" : "NULL"}');
        } else {
          await _secureStorage.write(key: _tokenKey, value: token);
          print('AuthService (Mobile): DEBUG - Login - Saved token to SecureStorage');
          // Verify immediate read after saving
          final String? verifiedToken = await _secureStorage.read(key: _tokenKey);
          print('AuthService (Mobile): DEBUG - Login - Verified token read: ${verifiedToken != null ? "FOUND" : "NULL"}');
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
      print('Error logging in: $e'); // Keep error logs
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
      print('Error verifying OTP: $e'); // Keep error logs
      rethrow;
    }
  }

  Future<void> logout() async {
    await _deleteKey(_tokenKey);
    await _deleteKey(_userProfileKey);
    await _deleteKey(_onboardingSeenKey); // Ensure onboarding is reset on logout for testing
  }

  Future<bool> get isAuthenticated async {
    String? token = await getAuthToken(); // Use the getter to log retrieval
    if (token == null) {
      print('AuthService: DEBUG - isAuthenticated - Token is NULL.');
      return false;
    }
    bool expired = JwtDecoder.isExpired(token);
    print('AuthService: DEBUG - isAuthenticated - Token found. Expired: $expired');
    return !expired;
  }
}
