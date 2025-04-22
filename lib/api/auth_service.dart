import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jwt_decoder/jwt_decoder.dart'; // Add this package
import '../data/models/User.dart';

class AuthService {
  static const _tokenKey = 'jwt'; // Consistent key name with backend
  final FlutterSecureStorage _storage;
  Dio _dio;

  // Use factory constructor for better instance control
  AuthService({
    required String baseUrl,
    FlutterSecureStorage? storage,
  })  : _storage = storage ?? const FlutterSecureStorage(),
        _dio = Dio(
          BaseOptions(
            baseUrl: baseUrl,
            connectTimeout: const Duration(seconds: 30),
            receiveTimeout: const Duration(seconds: 30),
            headers: {'Content-Type': 'application/json'},
          ),
        ) {
    // Add interceptor for automatic token handling
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        print('Making request to: ${options.uri}');
        print('Request data: ${options.data}');
        final token = await _storage.read(key: _tokenKey);
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onError: (error, handler) async {
        print('Request error: ${error.message}');
        print('Error response: ${error.response?.data}');
        if (error.response?.statusCode == 401) {
          await _storage.delete(key: _tokenKey);
        }
        return handler.next(error);
      },
    ));
  }

  // Add setter for testing
  set dio(Dio dio) => _dio = dio;
  Dio get dio => _dio;

  Future<Map<String, dynamic>> register(String name, String email,
      String password, String universityId, String phoneNumber) async {
    try {
      final response = await _dio.post(
        '/users/register',
        data: {
          'name': name,
          'email': email,
          'password': password,
          'phone_number': phoneNumber,
          'universityId': universityId
        },
      );

      if (response.data['success'] == true) {
        return {
          'success': true,
          'message': response.data['message'],
          'user': response.data['user']
        };
      } else {
        throw Exception(response.data['message'] ?? 'Registration failed');
      }
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> sendPasswordResetLink(String email) async {
    try {
      final response = await _dio.post(
        '/users/forgot-password',
        data: {'email': email},
      );
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Response> resetPassword(
      String email, String otp, String newPassword) async {
    try {
      final response = await _dio.post(
        '/users/reset-password',
        data: {
          'email': email,
          'otp': otp,
          'newPassword': newPassword,
        },
      );
      return response;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<String> login(String email, String password) async {
    try {
      final response = await _dio.post(
        '/users/login',
        data: {'email': email, 'password': password},
      );
      final token = response.data['token'] as String;
      await _storage.write(key: _tokenKey, value: token);
      return token;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<UserModel> fetchUserProfile() async {
    try {
      final response = await _dio.get('/users/profile');
      return UserModel.fromJson(response.data['user']);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<bool> verifyOtp(String email, String otp) async {
    try {
      print('Verifying OTP for email: $email');
      print('Request URL: ${_dio.options.baseUrl}/users/verify-otp');

      final response = await _dio.post(
        '/users/verify-otp',
        data: {'email': email, 'otp': otp},
      );

      print('OTP verification response: ${response.data}');

      if (response.data['token'] != null) {
        await _storage.write(key: _tokenKey, value: response.data['token']);
        return true;
      } else {
        throw Exception('No token received in response');
      }
    } on DioException catch (e) {
      print('DioException in verifyOtp: ${e.message}');
      print('Error type: ${e.type}');
      print('Response status: ${e.response?.statusCode}');
      print('Response data: ${e.response?.data}');
      throw _handleError(e);
    } catch (e) {
      print('Unexpected error in verifyOtp: $e');
      print('Error type: ${e.runtimeType}');
      rethrow;
    }
  }

  Future<void> logout() async {
    await _storage.delete(key: _tokenKey);
    _dio.options.headers.remove('Authorization');
  }

  Future<bool> get isAuthenticated async {
    final token = await _storage.read(key: _tokenKey);
    return token != null && !JwtDecoder.isExpired(token);
  }

  Future<void> deleteAccount() async {
    try {
      print('Attempting to delete account...');
      print('Request URL: ${_dio.options.baseUrl}/users/delete-account');

      await _dio.delete('/users/delete-account');

      print('Account deleted successfully');

      // Clear local storage
      await _storage.delete(key: _tokenKey);
      _dio.options.headers.remove('Authorization');
    } on DioException catch (e) {
      print('DioException in deleteAccount: ${e.message}');
      print('Error type: ${e.type}');
      print('Response status: ${e.response?.statusCode}');
      print('Response data: ${e.response?.data}');
      throw _handleError(e);
    } catch (e) {
      print('Unexpected error in deleteAccount: $e');
      print('Error type: ${e.runtimeType}');
      rethrow;
    }
  }

  static Exception _handleError(DioException e) {
    print('Handling error: ${e.message}');
    print('Error type: ${e.type}');
    print('Error response: ${e.response?.data}');

    final response = e.response;
    if (response != null) {
      final data = response.data as Map<String, dynamic>?;
      final message = data?['message'] ?? 'Unknown error occurred';
      return Exception('$message (${response.statusCode})');
    }

    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.sendTimeout) {
      return Exception(
          'Connection timeout. Please check your internet connection and try again.');
    }

    return Exception('Network error: ${e.message}');
  }
}
