// lib/api/auth_service.dart
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'dart:convert';
import 'package:revobike/data/models/User.dart';
import 'package:revobike/api/api_constants.dart';

class AuthService {
  static const _tokenKey = 'jwt';
  static const _userProfileKey = 'user_profile';
  static const _onboardingSeenKey =
      'onboarding_seen'; // NEW: Key for onboarding flag

  final FlutterSecureStorage _storage;
  final http.Client client;

  AuthService({
    FlutterSecureStorage? storage,
    http.Client? client,
  })  : _storage = storage ?? const FlutterSecureStorage(),
        client = client ?? http.Client();

  Future<String?> getAuthToken() async {
    final prefs = await _storage.read(key: _tokenKey);
    return prefs;
  }

  Future<void> _saveUserProfile(UserModel user) async {
    final userJson = jsonEncode(user.toJson());
    await _storage.write(key: _userProfileKey, value: userJson);
  }

  Future<UserModel?> _loadUserProfile() async {
    final userJson = await _storage.read(key: _userProfileKey);
    if (userJson != null) {
      return UserModel.fromJson(jsonDecode(userJson));
    }
    return null;
  }

  // NEW: Method to set onboarding as seen
  Future<void> setOnboardingSeen() async {
    await _storage.write(
        key: _onboardingSeenKey,
        value: 'true'); // Store as string as secure_storage only takes strings
  }

  // NEW: Method to check if onboarding has been seen
  Future<bool> hasSeenOnboarding() async {
    final String? seen = await _storage.read(key: _onboardingSeenKey);
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

      print('Backend response: ${response.body}');
      final responseData = jsonDecode(response.body);

      if (response.statusCode >= 200 && response.statusCode < 300) {
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

        final Map<String, dynamic>? userData = data['user'];
        if (userData != null) {
          await _saveUserProfile(UserModel.fromJson(userData));
        } else {
          print('Warning: No user data found in login response.');
        }

        await setOnboardingSeen(); // NEW: Set onboarding as seen on successful login

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

      print('Backend response: ${response.body}');
      final data = jsonDecode(response.body);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final token = data['token'];
        if (token != null) {
          await _storage.write(key: _tokenKey, value: token);
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

  Future<void> logout() async {
    await _storage.delete(key: _tokenKey);
    await _storage.delete(key: _userProfileKey);
    // Optionally, you might *not* delete _onboardingSeenKey on logout
    // if you want users who've logged in once to never see onboarding again.
    // If you want them to potentially see it again (e.g., if you update onboarding),
    // you could delete it here:
    // await _storage.delete(key: _onboardingSeenKey);
  }

  Future<bool> get isAuthenticated async {
    final token = await _storage.read(key: _tokenKey);
    return token != null && !JwtDecoder.isExpired(token);
  }
}
