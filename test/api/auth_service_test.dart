import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:http/http.dart' as http;
// import 'package:http/testing.dart'; // No longer strictly needed as we're mocking http.Client directly
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:revobike/api/auth_service.dart';
import 'package:revobike/api/api_constants.dart'; // <--- NEW: Import ApiConstants
import 'package:revobike/data/models/User.dart'; // <--- NEW: Import UserModel
import 'dart:convert';

// Generate mocks for FlutterSecureStorage and http.Client
@GenerateMocks([FlutterSecureStorage, http.Client])
import 'auth_service_test.mocks.dart';

void main() {
  TestWidgetsFlutterBinding
      .ensureInitialized(); // Ensures Flutter services are initialized for tests

  late AuthService authService;
  late MockClient mockClient;
  late MockFlutterSecureStorage mockStorage;

  // Define a sample user model for testing user profile storage
  final testUser = UserModel(
    id: 'user123',
    name: 'Test User',
    email: 'test@aastustudent.edu.et',
    role: 'user',
  );

  setUp(() {
    mockClient =
        MockClient(); // Initialize mockClient without a default handler
    mockStorage = MockFlutterSecureStorage();
    authService = AuthService(
      storage: mockStorage,
      client: mockClient,
    );

    // Reset mocks before each test to ensure clean state
    reset(mockClient);
    reset(mockStorage);
  });

  group('AuthService Tests', () {
    test('register - successful registration', () async {
      // Arrange
      final url =
          Uri.parse(ApiConstants.baseUrl + ApiConstants.registerEndpoint);
      when(mockClient.post(
        url,
        headers: anyNamed('headers'),
        body: anyNamed('body'),
      )).thenAnswer((_) async {
        return http.Response(
            jsonEncode({'message': 'User registered successfully'}), 201);
      });

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
      // Verify that a POST request was made to the correct registration endpoint
      verify(mockClient.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': 'Test User',
          'email': 'test@aastustudent.edu.et',
          'password': 'password123',
          'phone_number': '0912345678',
          'universityId': '12345',
        }),
      )).called(1);
    });

    test('register - handles error', () async {
      // Arrange
      final url =
          Uri.parse(ApiConstants.baseUrl + ApiConstants.registerEndpoint);
      when(mockClient.post(
        url,
        headers: anyNamed('headers'),
        body: anyNamed('body'),
      )).thenAnswer((_) async {
        return http.Response(
            jsonEncode({'message': 'Email already exists'}), 400);
      });

      // Act & Assert
      await expectLater(
        () => authService.register(
          'Test User',
          'test@aastustudent.edu.et', // Corrected email for consistency
          'password123',
          '12345',
          '0912345678',
        ),
        throwsA(predicate((e) => e is Exception && e.toString().contains('Email already exists'))),
      );
    });

    test('login - successful login and stores token and user profile',
        () async {
      // Arrange
      final url = Uri.parse(ApiConstants.baseUrl + ApiConstants.loginEndpoint);
      const token = 'test_jwt_token_123';
      final loginResponseData = {
        'token': token,
        'user': testUser.toJson(), // Include user data in login response
      };

      when(mockClient.post(
        url,
        headers: anyNamed('headers'),
        body: anyNamed('body'),
      )).thenAnswer((_) async {
        return http.Response(jsonEncode(loginResponseData), 200);
      });

      // Mock storage writes
      when(mockStorage.write(key: 'jwt', value: token))
          .thenAnswer((_) async {});
      when(mockStorage.write(
              key: 'user_profile', value: jsonEncode(testUser.toJson())))
          .thenAnswer((_) async {});

      // Act
      final result = await authService.login(
        'test@aastustudent.edu.et',
        'password123',
      );

      // Assert
      expect(result, token);
      verify(mockStorage.write(key: 'jwt', value: token)).called(1);
      // Verify user profile is stored
      verify(mockStorage.write(
              key: 'user_profile', value: jsonEncode(testUser.toJson())))
          .called(1);
    });

    test('login - handles error', () async {
      // Arrange
      final url = Uri.parse(ApiConstants.baseUrl + ApiConstants.loginEndpoint);
      when(mockClient.post(
        url,
        headers: anyNamed('headers'),
        body: anyNamed('body'),
      )).thenAnswer((_) async {
        return http.Response(
            jsonEncode({'message': 'Invalid credentials'}), 401);
      });

      // Act & Assert
      await expectLater(
        () => authService.login(
          'test@aastustudent.edu.et',
          'wrongpassword',
        ),
        throwsA(predicate((e) => e is Exception && e.toString().contains('Invalid credentials'))),
      );
      // Verify storage write was NOT called on error
      verifyNever(
          mockStorage.write(key: anyNamed('key'), value: anyNamed('value')));
    });

    test('fetchUserProfile - loads user profile from storage', () async {
      // Arrange
      final userJsonString = jsonEncode(testUser.toJson());
      when(mockStorage.read(key: 'user_profile'))
          .thenAnswer((_) async => userJsonString);

      // Act
      final userProfile = await authService.fetchUserProfile();

      // Assert
      expect(userProfile, isA<UserModel>());
      expect(userProfile?.email, testUser.email);
      expect(userProfile?.name, testUser.name);
      verify(mockStorage.read(key: 'user_profile')).called(1);
    });

    test('fetchUserProfile - returns null if no user profile in storage',
        () async {
      // Arrange
      when(mockStorage.read(key: 'user_profile')).thenAnswer((_) async => null);

      // Act
      final userProfile = await authService.fetchUserProfile();

      // Assert
      expect(userProfile, isNull);
      verify(mockStorage.read(key: 'user_profile')).called(1);
    });

    test('logout - clears token and user profile from storage', () async {
      // Arrange
      when(mockStorage.delete(key: 'jwt')).thenAnswer((_) async {});
      when(mockStorage.delete(key: 'user_profile')).thenAnswer((_) async {});

      // Act
      await authService.logout();

      // Assert
      verify(mockStorage.delete(key: 'jwt')).called(1);
      verify(mockStorage.delete(key: 'user_profile')).called(1);
    });

    test('sendPasswordResetLink - successful send', () async {
      // Arrange
      final url =
          Uri.parse(ApiConstants.baseUrl + ApiConstants.forgotPasswordEndpoint);
      when(mockClient.post(
        url,
        headers: anyNamed('headers'),
        body: anyNamed('body'),
      )).thenAnswer((_) async {
        return http.Response(
            jsonEncode({'message': 'Password reset link sent'}), 200);
      });

      // Act
      final response =
          await authService.sendPasswordResetLink('test@example.com');

      // Assert
      expect(response['message'], 'Password reset link sent');
      verify(mockClient.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': 'test@example.com'}),
      )).called(1);
    });

    test('sendPasswordResetLink - handles error', () async {
      // Arrange
      final url =
          Uri.parse(ApiConstants.baseUrl + ApiConstants.forgotPasswordEndpoint);
      when(mockClient.post(
        url,
        headers: anyNamed('headers'),
        body: anyNamed('body'),
      )).thenAnswer((_) async {
        return http.Response(jsonEncode({'message': 'User not found'}), 404);
      });

      // Act & Assert
      await expectLater(
        () => authService.sendPasswordResetLink('nonexistent@example.com'),
        throwsA(predicate((e) => e is Exception && e.toString().contains('User not found'))),
      );
    });

    test('resetPassword - successful reset', () async {
      // Arrange
      final url =
          Uri.parse(ApiConstants.baseUrl + ApiConstants.resetPasswordEndpoint);
      when(mockClient.post(
        url,
        headers: anyNamed('headers'),
        body: anyNamed('body'),
      )).thenAnswer((_) async {
        return http.Response(
            jsonEncode({'message': 'Password reset successfully'}), 200);
      });

      // Act
      final response = await authService.resetPassword(
          'test@example.com', '123456', 'newPassword123');

      // Assert
      expect(response['message'], 'Password reset successfully');
      verify(mockClient.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': 'test@example.com',
          'otp': '123456',
          'newPassword': 'newPassword123',
        }),
      )).called(1);
    });

    test('resetPassword - handles error', () async {
      // Arrange
      final url =
          Uri.parse(ApiConstants.baseUrl + ApiConstants.resetPasswordEndpoint);
      when(mockClient.post(
        url,
        headers: anyNamed('headers'),
        body: anyNamed('body'),
      )).thenAnswer((_) async {
        return http.Response(jsonEncode({'message': 'Invalid OTP'}), 400);
      });

      // Act & Assert
      await expectLater(
        () => authService.resetPassword(
            'test@example.com', 'wrongotp', 'newPassword123'),
        throwsA(predicate((e) => e is Exception && e.toString().contains('Invalid OTP'))),
      );
    });

    test('verifyOtp - successful verification and token storage', () async {
      // Arrange
      final url =
          Uri.parse(ApiConstants.baseUrl + ApiConstants.verifyOtpEndpoint);
      const token = 'verified_token';
      when(mockClient.post(
        url,
        headers: anyNamed('headers'),
        body: anyNamed('body'),
      )).thenAnswer((_) async {
        return http.Response(
            jsonEncode({'success': true, 'token': token}), 200);
      });
      when(mockStorage.write(key: 'jwt', value: token))
          .thenAnswer((_) async {});

      // Act
      final result = await authService.verifyOtp('test@example.com', '654321');

      // Assert
      expect(result, isTrue);
      verify(mockStorage.write(key: 'jwt', value: token)).called(1);
      verify(mockClient.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': 'test@example.com',
          'otp': '654321',
        }),
      )).called(1);
    });

    test('verifyOtp - successful verification without token in response',
        () async {
      // Arrange
      final url =
          Uri.parse(ApiConstants.baseUrl + ApiConstants.verifyOtpEndpoint);
      when(mockClient.post(
        url,
        headers: anyNamed('headers'),
        body: anyNamed('body'),
      )).thenAnswer((_) async {
        return http.Response(jsonEncode({'success': true}), 200);
      });

      // Act
      final result = await authService.verifyOtp('test@example.com', '654321');

      // Assert
      expect(result, isTrue);
      verifyNever(mockStorage.write(
          key: 'jwt',
          value: anyNamed('value'))); // Should not write token if not returned
    });

    test('verifyOtp - handles error', () async {
      // Arrange
      final url =
          Uri.parse(ApiConstants.baseUrl + ApiConstants.verifyOtpEndpoint);
      when(mockClient.post(
        url,
        headers: anyNamed('headers'),
        body: anyNamed('body'),
      )).thenAnswer((_) async {
        return http.Response(jsonEncode({'message': 'Invalid OTP'}), 400);
      });

      // Act & Assert
      await expectLater(
        () => authService.verifyOtp('test@example.com', 'wrongotp'),
        throwsA(predicate((e) => e is Exception && e.toString().contains('Invalid OTP'))),
      );
    });
  });
}
