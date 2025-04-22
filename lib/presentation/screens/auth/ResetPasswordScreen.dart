import 'package:flutter/material.dart';
import 'package:revobike/api/auth_service.dart';
import 'package:revobike/presentation/screens/auth/LoginScreen.dart';
import 'package:dio/dio.dart';

class ResetPasswordScreen extends StatefulWidget {
  final String email;

  const ResetPasswordScreen({
    super.key,
    required this.email,
  });

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final AuthService authService = AuthService(
    baseUrl: const String.fromEnvironment('API_BASE_URL',
        defaultValue: 'http://localhost:5000/api'),
  );
  final TextEditingController _otpController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  bool _isPasswordVisible = false;
  bool _isLoading = false;

  String? _otpError;
  String? _passwordError;
  String? _confirmPasswordError;
  String? _generalError;

  @override
  void dispose() {
    _otpController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _resetPassword() async {
    // Clear previous errors
    setState(() {
      _otpError = null;
      _passwordError = null;
      _confirmPasswordError = null;
      _generalError = null;
    });

    // Validate fields
    if (_otpController.text.isEmpty) {
      setState(() => _otpError = 'OTP is required');
      return;
    }
    if (_newPasswordController.text.isEmpty) {
      setState(() => _passwordError = 'New password is required');
      return;
    }
    if (_confirmPasswordController.text.isEmpty) {
      setState(() => _confirmPasswordError = 'Please confirm your password');
      return;
    }
    if (_newPasswordController.text != _confirmPasswordController.text) {
      setState(() => _confirmPasswordError = 'Passwords do not match');
      return;
    }

    try {
      setState(() => _isLoading = true);

      final Response response = await authService.resetPassword(
        widget.email,
        _otpController.text,
        _newPasswordController.text,
      );

      if (response.statusCode == 200) {
        // Navigate back to login screen first
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
          (route) => false, // This removes all previous routes
        );

        // Show success message after navigation
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.data['message']),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        setState(() => _generalError = response.data['message']);
      }
    } on DioException catch (e) {
      String errorMessage = 'Failed to reset password';
      if (e.response?.statusCode == 400) {
        errorMessage = e.response?.data['message'] ?? errorMessage;
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
        title: const Text('Reset Password'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 40),
              const Text(
                'Reset Your Password',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Enter the OTP sent to ${widget.email} and your new password.',
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 32),
              TextFormField(
                controller: _otpController,
                keyboardType: TextInputType.number,
                maxLength: 6,
                decoration: InputDecoration(
                  labelText: 'OTP',
                  hintText: 'Enter 6-digit OTP',
                  errorText: _otpError,
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _newPasswordController,
                obscureText: !_isPasswordVisible,
                decoration: InputDecoration(
                  labelText: 'New Password',
                  hintText: 'Enter new password',
                  errorText: _passwordError,
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isPasswordVisible
                          ? Icons.visibility_off
                          : Icons.visibility,
                    ),
                    onPressed: () {
                      setState(() {
                        _isPasswordVisible = !_isPasswordVisible;
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _confirmPasswordController,
                obscureText: !_isPasswordVisible,
                decoration: InputDecoration(
                  labelText: 'Confirm Password',
                  hintText: 'Confirm new password',
                  errorText: _confirmPasswordError,
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
                onPressed: _isLoading ? null : _resetPassword,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.blueAccent,
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'Reset Password',
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
