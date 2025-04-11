import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../data/models/Station.dart';

class StationService {
  final FlutterSecureStorage _storage;
  Dio _dio;

  StationService({
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
        final token = await _storage.read(key: 'jwt');
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onError: (error, handler) async {
        print('Request error: ${error.message}');
        print('Error response: ${error.response?.data}');
        if (error.response?.statusCode == 401) {
          await _storage.delete(key: 'jwt');
        }
        return handler.next(error);
      },
    ));
  }

  // Add setter for testing
  set dio(Dio dio) => _dio = dio;
  Dio get dio => _dio;

  Future<List<Station>> getStations() async {
    try {
      print('Fetching stations...');
      print('Request URL: ${_dio.options.baseUrl}/stations');

      final response = await _dio.get('/stations');

      print('Stations response: ${response.data}');

      if (response.data['success'] == true && response.data['data'] != null) {
        final List<dynamic> stationsJson = response.data['data'];
        return stationsJson.map((json) => Station.fromJson(json)).toList();
      } else {
        throw Exception('No stations found in response');
      }
    } on DioException catch (e) {
      print('DioException in getStations: ${e.message}');
      print('Error type: ${e.type}');
      print('Response status: ${e.response?.statusCode}');
      print('Response data: ${e.response?.data}');
      throw _handleError(e);
    } catch (e) {
      print('Unexpected error in getStations: $e');
      print('Error type: ${e.runtimeType}');
      rethrow;
    }
  }

  static Exception _handleError(DioException e) {
    if (e.response?.statusCode == 401) {
      return Exception('Unauthorized: Please login again');
    } else if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.sendTimeout) {
      return Exception(
          'Connection timeout. Please check your internet connection.');
    } else if (e.type == DioExceptionType.connectionError) {
      return Exception(
          'Could not connect to the server. Please check your internet connection.');
    } else if (e.response?.statusCode == 400) {
      return Exception(e.response?.data['message'] ?? 'Bad request');
    } else {
      return Exception(e.message ?? 'An unexpected error occurred');
    }
  }
}
