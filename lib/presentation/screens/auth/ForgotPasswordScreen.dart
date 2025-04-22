import 'package:flutter/material.dart';
import 'package:revobike/api/auth_service.dart';
import 'package:revobike/presentation/screens/auth/ResetPasswordScreen.dart';
import 'package:dio/dio.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final AuthService authService = AuthService(
    baseUrl: const String.fromEnvironment('API_BASE_URL',
        defaultValue: 'http://localhost:5000/api'),
  );
  final TextEditingController _emailController = TextEditingController();
  String? _emailError;
  String? _generalError;
  bool _isLoading = false;

  Future<void> _sendResetLink() async {
    // Clear previous errors
    setState(() {
      _emailError = null;
      _generalError = null;
    });

    // Validate email
    if (_emailController.text.isEmpty) {
      setState(() => _emailError = 'Email is required');
      return;
    }

    // Validate institutional email format
    final emailRegex = RegExp(
        r'^[a-zA-Z]+\.[a-zA-Z]+@aastu(student|staff)\.edu\.et$',
        caseSensitive: false);
    if (!emailRegex.hasMatch(_emailController.text)) {
      setState(() => _emailError = 'Use AASTU institutional email');
      return;
    }

    try {
      setState(() => _isLoading = true);

      final response =
          await authService.sendPasswordResetLink(_emailController.text);

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response['message']),
          backgroundColor: Colors.green,
        ),
      );

      // Navigate to reset password screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ResetPasswordScreen(
            email: _emailController.text,
          ),
        ),
      );
    } on DioException catch (e) {
      String errorMessage = 'Failed to send reset link';
      if (e.response?.statusCode == 400) {
        errorMessage = e.response?.data['message'] ?? errorMessage;
      } else if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        errorMessage =
            'Connection timeout. Please check your internet connection and try again.';
      } else if (e.type == DioExceptionType.connectionError) {
        errorMessage =
            'Could not connect to the server. Please check your internet connection.';
      }

      setState(() => _generalError = errorMessage);
    } catch (e) {
      setState(() => _generalError = 'An unexpected error occurred');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Forgot Password'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 40),
              const Text(
                'Reset Password',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Enter your email address and we\'ll send you a link to reset your password.',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 32),
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'Email',
                  hintText: 'Enter your AASTU email',
                  errorText: _emailError,
                  border: const OutlineInputBorder(),
                ),
              ),
              if (_generalError != null) ...[
                const SizedBox(height: 16),
                Text(
                  _generalError!,
                  style: const TextStyle(color: Colors.red),
                ),
              ],
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isLoading ? null : _sendResetLink,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.blueAccent,
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'Send Reset Link',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
