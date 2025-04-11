import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:revobike/api/auth_service.dart';
import 'package:revobike/data/models/User.dart';

// Generate mocks
@GenerateMocks([Dio, FlutterSecureStorage])
import 'auth_service_test.mocks.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AuthService authService;
  late MockDio mockDio;
  late MockFlutterSecureStorage mockStorage;
  const baseUrl = 'http://10.0.2.2:5000/api';

  setUp(() {
    mockDio = MockDio();
    mockStorage = MockFlutterSecureStorage();
    authService = AuthService(
      baseUrl: baseUrl,
      storage: mockStorage,
    );
    // Replace the actual dio instance with our mock
    authService.dio = mockDio;
  });

  group('AuthService Tests', () {
    test('register - successful registration', () async {
      // Arrange
      when(mockDio.post(
        '/users/register',
        data: {
          'name': 'Test User',
          'email': 'test@aastustudent.edu.et',
          'password': 'password123',
          'universityId': '12345'
        },
      )).thenAnswer((_) async => Response(
            requestOptions: RequestOptions(path: '/users/register'),
            statusCode: 201,
          ));

      // Act
      await authService.register(
        'Test User',
        'test@aastustudent.edu.et',
        'password123',
        '12345',
      );

      // Assert
      verify(mockDio.post(
        '/users/register',
        data: {
          'name': 'Test User',
          'email': 'test@aastustudent.edu.et',
          'password': 'password123',
          'universityId': '12345'
        },
      )).called(1);
    });

    test('register - handles error', () async {
      // Arrange
      when(mockDio.post(
        '/users/register',
        data: anyNamed('data'),
      )).thenThrow(DioException(
        requestOptions: RequestOptions(path: '/users/register'),
        response: Response(
          requestOptions: RequestOptions(path: '/users/register'),
          statusCode: 400,
          data: {'message': 'Email already exists'},
        ),
      ));

      // Act & Assert
      expect(
        () => authService.register(
          'Test User',
          'test@aastustudent.edu.et',
          'password123',
          '12345',
        ),
        throwsException,
      );
    });

    test('login - successful login', () async {
      // Arrange
      const token = 'test_token';
      when(mockDio.post(
        '/users/login',
        data: {
          'email': 'test@aastustudent.edu.et',
          'password': 'password123',
        },
      )).thenAnswer((_) async => Response(
            requestOptions: RequestOptions(path: '/users/login'),
            statusCode: 200,
            data: {'token': token},
          ));

      // Mock storage write
      when(mockStorage.write(
        key: 'jwt',
        value: token,
      )).thenAnswer((_) async => null);

      // Act
      final result = await authService.login(
        'test@aastustudent.edu.et',
        'password123',
      );

      // Assert
      expect(result, token);
      verify(mockDio.post(
        '/users/login',
        data: {
          'email': 'test@aastustudent.edu.et',
          'password': 'password123',
        },
      )).called(1);
      verify(mockStorage.write(
        key: 'jwt',
        value: token,
      )).called(1);
    });

    test('login - handles error', () async {
      // Arrange
      when(mockDio.post(
        '/users/login',
        data: anyNamed('data'),
      )).thenThrow(DioException(
        requestOptions: RequestOptions(path: '/users/login'),
        response: Response(
          requestOptions: RequestOptions(path: '/users/login'),
          statusCode: 401,
          data: {'message': 'Invalid credentials'},
        ),
      ));

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
