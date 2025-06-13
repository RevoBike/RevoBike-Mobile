import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:revobike/api/auth_service.dart';
import 'dart:convert';

// Generate mocks
@GenerateMocks([FlutterSecureStorage])
import 'auth_service_test.mocks.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AuthService authService;
  late MockClient mockClient;
  late MockFlutterSecureStorage mockStorage;
  const baseUrl = 'https://revobike-web-3.onrender.com';

  setUp(() {
    mockClient = MockClient((request) async {
      // Default mock response for all requests
      return http.Response(jsonEncode({'message': 'Default response'}), 200);
    });
    mockStorage = MockFlutterSecureStorage();
    authService = AuthService(
      baseUrl: baseUrl,
      storage: mockStorage,
      client: mockClient,
    );
  });

  group('AuthService Tests', () {
    test('register - successful registration', () async {
      // Arrange
      final url = Uri.parse('$baseUrl/users/register');
      mockClient = MockClient((request) async {
        if (request.url == url && request.method == 'POST') {
          final body = request.bodyFields;
          if (body['email'] == 'test@aastustudent.edu.et') {
            return http.Response(
                jsonEncode({'message': 'User registered successfully'}), 201);
          }
        }
        return http.Response('Not Found', 404);
      });
      authService = AuthService(
        baseUrl: baseUrl,
        storage: mockStorage,
        client: mockClient,
      );

      // Act
      final response = await authService.register(
        'Test User',
        'test@aastustudent.edu.et',
        'password123',
        '12345',
        '0912345678',
      );

      // Assert
      expect(response['message'], 'User registered successfully');
    });

    test('register - handles error', () async {
      // Arrange
      final url = Uri.parse('$baseUrl/users/register');
      mockClient = MockClient((request) async {
        if (request.url == url && request.method == 'POST') {
          return http.Response(
              jsonEncode({'message': 'Email already exists'}), 400);
        }
        return http.Response('Not Found', 404);
      });
      authService = AuthService(
        baseUrl: baseUrl,
        storage: mockStorage,
        client: mockClient,
      );

      // Act & Assert
      expect(
        () => authService.register(
          'Test User',
          'test@aastudent.edu.et',
          'password123',
          '12345',
          '0912345678',
        ),
        throwsException,
      );
    });

    test('login - successful login', () async {
      // Arrange
      final url = Uri.parse('$baseUrl/users/login');
      const token = 'test_token';
      mockClient = MockClient((request) async {
        if (request.url == url && request.method == 'POST') {
          return http.Response(jsonEncode({'token': token}), 200);
        }
        return http.Response('Not Found', 404);
      });
      when(mockStorage.write(key: 'jwt', value: token))
          .thenAnswer((_) async {});

      authService = AuthService(
        baseUrl: baseUrl,
        storage: mockStorage,
        client: mockClient,
      );

      // Act
      final result = await authService.login(
        'test@aastustudent.edu.et',
        'password123',
      );

      // Assert
      expect(result, token);
      verify(mockStorage.write(key: 'jwt', value: token)).called(1);
    });

    test('login - handles error', () async {
      // Arrange
      final url = Uri.parse('$baseUrl/users/login');
      mockClient = MockClient((request) async {
        if (request.url == url && request.method == 'POST') {
          return http.Response(
              jsonEncode({'message': 'Invalid credentials'}), 401);
        }
        return http.Response('Not Found', 404);
      });
      authService = AuthService(
        baseUrl: baseUrl,
        storage: mockStorage,
        client: mockClient,
      );

      // Act & Assert
      expect(
        () => authService.login(
          'test@aastustudent.edu.et',
          'wrongpassword',
        ),
        throwsException,
      );
    });
  });
}
