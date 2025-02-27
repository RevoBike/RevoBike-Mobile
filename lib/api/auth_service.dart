import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:revobike/data/models/User.dart';

class AuthService {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  final String _baseUrl = "http://10.0.2.2:5000/api";

  Future<String?> register(
      String name, String email, String password) async {
    Dio dio = Dio();
    Response response = await dio.post('$_baseUrl/users/register', data: {
      'name': name,
      'email': email,
      'password': password,
    });

    if (response.statusCode == 201) {
      final data = json.decode(response.toString());
      String token = data['token'];

      await _storage.write(key: 'jwt_token', value: token);

      return token;
    } else if (response.statusCode == 400) {
      final data = json.decode(response.toString());
      if (data['error'] == 'Email already exists') {
        throw Exception('Email is already taken');
      } else {
        throw Exception('User already exists');
      }
    } else {
      throw Exception('Failed to register');
    }
  }

  Future<String?> login(String email, String password) async {
    Dio dio = Dio();
    Response response = await dio.post('$_baseUrl/users/login', data: {
      'email': email,
      'password': password,
    });

    if (response.statusCode == 200) {
      final data = json.decode(response.toString());
      String token = data['token'];

      await _storage.write(key: 'jwt_token', value: token);

      return token;
    } else {
      throw Exception('Failed to authenticate');
    }
  }

  Future<bool> isAuthenticated() async {
    String? token = await _storage.read(key: 'jwt_token');
    if (token == null) {
      return false;
    }

    bool isExpired = isTokenExpired(token);
    if (isExpired) {
      return false;
    } else {
      try {
        await fetchUserProfile();
        return true;
      } catch (e) {
        return false;
      }
    }
  }

  Future<String?> getToken() async {
    return await _storage.read(key: 'jwt_token');
  }

  Future<void> logout() async {
    try {
      await _storage.delete(key: 'jwt_token');
    } catch (e) {
      print('Failed to delete token');
    }
  }

  bool isTokenExpired(String token) {
    final decodedToken = json.decode(utf8
        .decode(base64Url.decode(base64Url.normalize(token.split('.')[1]))));
    final exp = decodedToken['exp'];
    final expirationDate = DateTime.fromMillisecondsSinceEpoch(exp * 1000);

    return expirationDate.isBefore(DateTime.now());
  }

  Future<UserModel> fetchUserProfile() async {
    final token = await getToken();
    Dio dio = Dio();

    Response response = await dio.get('$_baseUrl/users/profile',
        options: Options(
          headers: {
            'x-auth-token': token!,
            'Content-Type': 'application/json',
          },
        ));

    if (response.statusCode != 200) {
      throw Exception('Failed to fetch user profile');
    }

    final data = json.decode(response.toString());
    final user = UserModel.fromJson(data['user']);

    return user;
  }
}