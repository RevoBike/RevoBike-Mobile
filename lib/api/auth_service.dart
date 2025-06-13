import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import '../data/models/User.dart';
import 'dart:convert';

class AuthService {
  static const _tokenKey = 'jwt'; // Consistent key name with backend
  final FlutterSecureStorage _storage;
  final String baseUrl;
  final http.Client client;

  // Use factory constructor for better instance control
  AuthService({
    required this.baseUrl,
    FlutterSecureStorage? storage,
    http.Client? client,
  })  : _storage = storage ?? const FlutterSecureStorage(),
        client = client ?? http.Client();

  Future<Map<String, dynamic>> register(String name, String email,
      String password, String universityId, String phoneNumber) async {
    try {
      final url = '$baseUrl/api/users/register';
      final response = await client.post(Uri.parse(url), body: {
        'name': name,
        'email': email,
        'password': password,
        'phone_number': phoneNumber,
        'universityId': universityId
      });

      print('Backend response: ${response.body}');
      return jsonDecode(response.body);
    } catch (e) {
      print('Error registering user: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> sendPasswordResetLink(String email) async {
    try {
      final url = '${baseUrl}/api/users/register';
      final response = await http.post(Uri.parse(url), body: {'email': email});

      print('Backend response: ${response.body}');
      return jsonDecode(response.body);
    } catch (e) {
      print('Error sending password reset link: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> resetPassword(
      String email, String otp, String newPassword) async {
    try {
      final url = '${baseUrl}/api/users/register';
      final response = await http.post(Uri.parse(url), body: {
        'email': email,
        'otp': otp,
        'newPassword': newPassword,
      });

      print('Backend response: ${response.body}');
      return jsonDecode(response.body);
    } catch (e) {
      print('Error resetting password: $e');
      rethrow;
    }
  }

  Future<String> login(String email, String password) async {
    try {
      final url = '$baseUrl/api/users/login';
      final response = await client.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      print('Backend response: ${response.body}');
      final data = jsonDecode(response.body);
      if (data['success'] != true) {
        final message = data['message'] ?? 'Login failed';
        throw Exception(message);
      }
      final token = data['token'];
      if (token == null || token is! String) {
        throw Exception('Invalid token received');
      }
      await _storage.write(key: _tokenKey, value: token);
      return token;
    } catch (e) {
      print('Error logging in: $e');
      rethrow;
    }
  }

  Future<UserModel> fetchUserProfile() async {
    try {
      final url = '${baseUrl}/api/users/register';
      final response = await http.get(Uri.parse(url));
      print('Backend response: ${response.body}');
      final data = jsonDecode(response.body);
      return UserModel.fromJson(data['user']);
    } catch (e) {
      print('Error fetching user profile: $e');
      rethrow;
    }
  }

  Future<bool> verifyOtp(String email, String otp) async {
    try {
      final url = '${baseUrl}/api/users/register';
      final response = await http.post(Uri.parse(url), body: {
        'email': email,
        'otp': otp,
      });

      print('Backend response: ${response.body}');
      final data = jsonDecode(response.body);
      if (data['token'] != null) {
        await _storage.write(key: _tokenKey, value: data['token']);
        return true;
      } else {
        throw Exception('No token received in response');
      }
    } catch (e) {
      print('Error verifying OTP: $e');
      rethrow;
    }
  }

  Future<void> logout() async {
    await _storage.delete(key: _tokenKey);
  }

  Future<bool> get isAuthenticated async {
    final token = await _storage.read(key: _tokenKey);
    return token != null && !JwtDecoder.isExpired(token);
  }

  Future<void> deleteAccount() async {
    try {
      final url = '${baseUrl}/api/users/delete-account';
      final response = await http.delete(Uri.parse(url));

      if (response.statusCode == 200) {
        print('Account deleted successfully');

        // Clear local storage
        await _storage.delete(key: _tokenKey);
      } else {
        print('Error deleting account: ${response.statusCode}');
      }
    } catch (e) {
      print('Error deleting account: $e');
    }
  }
}
