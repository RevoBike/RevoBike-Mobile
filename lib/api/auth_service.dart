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
      print(
          'AuthService: Deleting key: $key from SecureStorage'); // Debug print
      await _secureStorage.delete(key: key);
    }
  }

  Future<String?> getAuthToken() async {
    String? token;
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      token = prefs.getString(_tokenKey);
      print(
          'AuthService: getAuthToken (Web) - retrieved: ${token != null ? 'YES' : 'NO'}'); // Debug print
    } else {
      token = await _secureStorage.read(key: _tokenKey);
      print(
          'AuthService: getAuthToken (Mobile) - retrieved: ${token != null ? 'YES' : 'NO'}'); // Debug print
      if (token == null) {
        print(
            'AuthService: Token is NULL after read from SecureStorage'); // Debug print
      }
    }
    return token;
  }

  Future<void> _saveUserProfile(UserModel user) async {
    final userJson = jsonEncode(user.toJson());
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_userProfileKey, userJson);
      print('AuthService: User profile saved (Web)'); // Debug print
    } else {
      await _secureStorage.write(key: _userProfileKey, value: userJson);
      print('AuthService: User profile saved (Mobile)'); // Debug print
    }
  }

  Future<UserModel?> _loadUserProfile() async {
    String? userJson;
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      userJson = prefs.getString(_userProfileKey);
    } else {
      // <--- THIS IS THE CRUCIAL ADDITION FOR MOBILE
      userJson = await _secureStorage.read(key: _userProfileKey);
    }

    if (userJson == null) {
      print('AuthService: User profile JSON is null.'); // Debug print
      return null; // If no user data is found, return null
    }

    try {
      final user = UserModel.fromJson(jsonDecode(userJson));
      print('AuthService: User profile decoded successfully.'); // Debug print
      return user;
    } catch (e) {
      print(
          "AuthService: Error decoding user profile from storage: $e"); // Debug print
      // Consider deleting the corrupted user profile from storage here:
      // await _deleteKey(_userProfileKey);
      return null;
    }
  }

  // Method to set onboarding as seen - ALWAYS uses SharedPreferences
  Future<void> setOnboardingSeen() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_onboardingSeenKey, 'true');
    print('AuthService: Onboarding set as seen.'); // Debug print
  }

  // Method to check if onboarding has been seen - ALWAYS uses SharedPreferences
  Future<bool> hasSeenOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    String? seen = prefs.getString(_onboardingSeenKey);
    print('AuthService: Has seen onboarding? ${seen == 'true'}'); // Debug print
    return seen == 'true';
  }

  Future<Map<String, dynamic>> register(String name, String email,
      String password, String universityId, String phoneNumber) async {
    try {
      final url =
          Uri.parse(ApiConstants.baseUrl + ApiConstants.registerEndpoint);
      print('AuthService: Registering user to $url'); // Debug print
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
      print(
          'AuthService: Register response status: ${response.statusCode}, body: ${response.body}'); // Debug print

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return responseData;
      } else {
        final message = responseData['message'] ?? 'Registration failed';
        throw Exception(message);
      }
    } catch (e) {
      print('AuthService: Register error: $e'); // Debug print
      rethrow;
    }
  }

  Future<Map<String, dynamic>> sendPasswordResetLink(String email) async {
    try {
      final url =
          Uri.parse(ApiConstants.baseUrl + ApiConstants.forgotPasswordEndpoint);
      print('AuthService: Sending password reset link to $url'); // Debug print
      final response = await client.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
      );

      final responseData = jsonDecode(response.body);
      print(
          'AuthService: Password reset link response status: ${response.statusCode}, body: ${response.body}'); // Debug print

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return responseData;
      } else {
        final message = responseData['message'] ?? 'Failed to send reset link';
        throw Exception(message);
      }
    } catch (e) {
      print('AuthService: Send password reset link error: $e'); // Debug print
      rethrow;
    }
  }

  Future<Map<String, dynamic>> resetPassword(
      String email, String otp, String newPassword) async {
    try {
      final url =
          Uri.parse(ApiConstants.baseUrl + ApiConstants.resetPasswordEndpoint);
      print('AuthService: Resetting password to $url'); // Debug print
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
      print(
          'AuthService: Reset password response status: ${response.statusCode}, body: ${response.body}'); // Debug print

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return responseData;
      } else {
        final message = responseData['message'] ?? 'Failed to reset password';
        throw Exception(message);
      }
    } catch (e) {
      print('AuthService: Reset password error: $e'); // Debug print
      rethrow;
    }
  }

  Future<String> login(String email, String password) async {
    try {
      final url = Uri.parse(ApiConstants.baseUrl + ApiConstants.loginEndpoint);
      print('AuthService: Attempting login to $url'); // Debug print
      final response = await client.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      final data = jsonDecode(response.body);
      print(
          'AuthService: Login response status: ${response.statusCode}, body: ${response.body}'); // Debug print

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final token = data['token'];
        if (token == null || token is! String) {
          print(
              'AuthService: Login failed - Invalid or missing token in response.'); // Debug print
          throw Exception('Invalid or missing token received');
        }
        if (kIsWeb) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString(_tokenKey, token);
          print(
              'AuthService: Token saved to SharedPreferences (Web).'); // Debug print
        } else {
          await _secureStorage.write(key: _tokenKey, value: token);
          print(
              'AuthService: Token saved to SecureStorage (Mobile).'); // Debug print
        }

        // Verify immediate read after saving
        final String? verifiedToken = await getAuthToken();
        print(
            'AuthService: Verified token after save: ${verifiedToken != null ? 'YES' : 'NO'}'); // Debug print
        if (verifiedToken == null) {
          print(
              'AuthService: WARNING! Token did not verify immediately after save!'); // Critical debug
        }

        final Map<String, dynamic>? userData = data['user'];
        if (userData != null) {
          await _saveUserProfile(UserModel.fromJson(userData));
        } else {
          print(
              'AuthService: User data is null in login response.'); // Debug print
        }
        await setOnboardingSeen(); // Set onboarding as seen on successful login
        print('AuthService: Login successful, returning token.'); // Debug print
        return token;
      } else {
        final message = data['message'] ?? 'Login failed';
        print(
            'AuthService: Login failed with message: $message'); // Debug print
        throw Exception(message);
      }
    } catch (e) {
      print('AuthService: Login error: $e'); // Debug print
      rethrow;
    }
  }

  Future<UserModel?> fetchUserProfile() async {
    print('AuthService: Fetching user profile...'); // Debug print
    return await _loadUserProfile();
  }

  Future<bool> verifyOtp(String email, String otp) async {
    try {
      final url =
          Uri.parse(ApiConstants.baseUrl + ApiConstants.verifyOtpEndpoint);
      print('AuthService: Verifying OTP to $url'); // Debug print
      final response = await client.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'otp': otp,
        }),
      );

      final data = jsonDecode(response.body);
      print(
          'AuthService: OTP verification response status: ${response.statusCode}, body: ${response.body}'); // Debug print

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
      print('AuthService: Verify OTP error: $e'); // Debug print
      rethrow;
    }
  }

  Future<void> logout() async {
    print('AuthService: Logging out...'); // Debug print
    await _deleteKey(_tokenKey);
    await _deleteKey(_userProfileKey);
    await _deleteKey(_onboardingSeenKey);
    print('AuthService: Logout complete.'); // Debug print
  }

  Future<bool> get isAuthenticated async {
    print('AuthService: Checking if authenticated...'); // Debug print
    String? token = await getAuthToken();
    print(
        'AuthService: isAuthenticated - Token retrieved: ${token != null ? 'YES' : 'NO'}'); // Debug print

    if (token == null) {
      print('AuthService: isAuthenticated - No token found.'); // Debug print
      return false;
    }
    bool expired = JwtDecoder.isExpired(token);
    print(
        'AuthService: isAuthenticated - Token is expired: $expired'); // Debug print
    if (expired) {
      print(
          'AuthService: isAuthenticated - Token found but is expired. Initiating logout...'); // Debug print
      await logout(); // Consider logging out if token is expired
    }
    return !expired;
  }
}
