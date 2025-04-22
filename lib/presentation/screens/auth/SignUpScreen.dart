import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:revobike/api/auth_service.dart';
import 'package:dio/dio.dart';
import 'package:revobike/presentation/screens/auth/LoginScreen.dart';
import 'package:revobike/presentation/screens/auth/OtpVerificationScreen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final AuthService authService = AuthService(
    baseUrl: const String.fromEnvironment('API_BASE_URL',
        defaultValue: 'http://localhost:5000/api'),
  );
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _universityIdController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  bool _isPasswordVisible = false;

  // Error state variables
  String? _emailError;
  String? _nameError;
  String? _passwordError;
  String? _universityIdError;
  String? _phoneNumberError;
  String? _generalError;

  double _strength = 0.0;

  Widget buttonChild = const Text(
    "Sign Up",
    style: TextStyle(
        color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600),
  );

  @override
  void initState() {
    super.initState();
    // Add listener to sanitize university ID input
    _universityIdController.addListener(() {
      final text = _universityIdController.text;
      final sanitized = text.replaceAll(RegExp(r'[^0-9]'), '');
      if (text != sanitized) {
        _universityIdController.value = TextEditingValue(
          text: sanitized,
          selection: TextSelection.collapsed(offset: sanitized.length),
        );
      }
    });

    // Add listener to sanitize phone number input
    _phoneNumberController.addListener(() {
      final text = _phoneNumberController.text;
      // Allow only digits and optional leading +
      final sanitized = text.replaceAll(RegExp(r'[^\d+]'), '');
      if (text != sanitized) {
        _phoneNumberController.value = TextEditingValue(
          text: sanitized,
          selection: TextSelection.collapsed(offset: sanitized.length),
        );
      }
    });
  }

  void _checkPasswordStrength(String password) {
    double strength = 0.0;

    if (password.isEmpty) {
      strength = 0.0;
    } else if (password.length < 6) {
      strength = 0.25;
    } else if (password.length < 10) {
      strength = 0.5;
    } else if (RegExp(r'^(?=.*[A-Z])(?=.*[a-z])(?=.*\d)(?=.*[!@#\$&*~]).{10,}$')
        .hasMatch(password)) {
      strength = 1.0;
    } else {
      strength = 0.75;
    }

    setState(() {
      _strength = strength;
    });
  }

  void validateAndRegister() async {
    // Clear previous errors
    setState(() {
      _emailError = null;
      _nameError = null;
      _passwordError = null;
      _universityIdError = null;
      _phoneNumberError = null;
      _generalError = null;
    });

    // Validate fields
    if (_emailController.text.isEmpty) {
      setState(() => _emailError = 'Email is required');
    }
    if (_nameController.text.isEmpty) {
      setState(() => _nameError = 'Name is required');
    }
    if (_passwordController.text.isEmpty) {
      setState(() => _passwordError = 'Password is required');
    }
    if (_universityIdController.text.isEmpty) {
      setState(() => _universityIdError = 'University ID is required');
    }
    if (_phoneNumberController.text.isEmpty) {
      setState(() => _phoneNumberError = 'Phone number is required');
    }

    // If any field errors, stop here
    if (_emailError != null ||
        _nameError != null ||
        _passwordError != null ||
        _universityIdError != null ||
        _phoneNumberError != null) {
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

    // Validate Ethiopian phone number format
    final phoneRegex = RegExp(r'^0[79]\d{8}$');
    if (!phoneRegex.hasMatch(_phoneNumberController.text)) {
      setState(() => _phoneNumberError =
          'Enter a valid Ethiopian phone number starting with 09 or 07 (10 digits total)');
      return;
    }

    // Validate minimum lengths
    if (_nameController.text.length < 6) {
      setState(() => _nameError = 'Name must be at least 6 characters');
    }
    if (_passwordController.text.length < 6) {
      setState(() => _passwordError = 'Password must be at least 6 characters');
    }
    if (_universityIdController.text.length != 6) {
      setState(() =>
          _universityIdError = 'University ID must be 6 digits (e.g., 167314)');
    }

    if (_nameError != null ||
        _passwordError != null ||
        _universityIdError != null ||
        _phoneNumberError != null) {
      return;
    }

    try {
      setState(() {
        buttonChild =
            LoadingAnimationWidget.fallingDot(color: Colors.white, size: 20);
      });

      print('Attempting to register user...');
      print('Name: ${_nameController.text}');
      print('Email: ${_emailController.text}');
      print('University ID: ${_universityIdController.text}');
      print('Phone Number: ${_phoneNumberController.text}');
      print('API Base URL: ${authService.dio.options.baseUrl}');

      // First register the user (this will trigger OTP sending)
      final response = await authService.register(
        _nameController.text,
        _emailController.text,
        _passwordController.text,
        _universityIdController.text,
        _phoneNumberController.text,
      );

      print('Registration successful, showing success message...');

      // Show success feedback before navigation
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response['message']),
          backgroundColor: Colors.green,
        ),
      );

      print('Navigating to OTP verification screen...');

      // Navigate to OTP verification screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => OtpVerificationScreen(
            email: _emailController.text,
            name: _nameController.text,
            password: _passwordController.text,
          ),
        ),
      );
    } on DioException catch (e) {
      print('DioException occurred: ${e.message}');
      print('Response status: ${e.response?.statusCode}');
      print('Response data: ${e.response?.data}');
      print('Error type: ${e.type}');

      String errorMessage = 'Failed to register';
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

      setState(() {
        _generalError = errorMessage;
        buttonChild = const Text(
          "Sign Up",
          style: TextStyle(
              color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600),
        );
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.red,
        ),
      );
    } catch (e) {
      print('Unexpected error occurred: $e');
      print('Error type: ${e.runtimeType}');

      setState(() {
        _generalError = 'An unexpected error occurred';
        buttonChild = const Text(
          "Sign Up",
          style: TextStyle(
              color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600),
        );
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 30),
              Center(
                child: SvgPicture.asset(
                  "assets/images/signup_image.svg",
                  width: MediaQuery.of(context).size.width / 1.2,
                  height: MediaQuery.of(context).size.height / 2.7,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                "Sign Up",
                style: TextStyle(
                  fontSize: 30,
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              Form(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Icon(Icons.alternate_email, color: Colors.grey),
                        const SizedBox(width: 15),
                        Expanded(
                          child: TextFormField(
                            controller: _emailController,
                            decoration: InputDecoration(
                              hintText: "University Email",
                              hintStyle: const TextStyle(
                                  color: Colors.grey, fontSize: 16),
                              enabledBorder: const UnderlineInputBorder(
                                borderSide: BorderSide(
                                  color: Colors.grey,
                                  width: 1.0,
                                ),
                              ),
                              errorText: _emailError,
                              errorStyle: const TextStyle(color: Colors.red),
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (_emailError != null) const SizedBox(height: 5),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Icon(Icons.face, color: Colors.grey),
                        const SizedBox(width: 15),
                        Expanded(
                          child: TextFormField(
                            controller: _nameController,
                            decoration: InputDecoration(
                              hintText: "Full Name",
                              hintStyle: const TextStyle(
                                  color: Colors.grey, fontSize: 16),
                              enabledBorder: const UnderlineInputBorder(
                                borderSide: BorderSide(
                                  color: Colors.grey,
                                  width: 1.0,
                                ),
                              ),
                              errorText: _nameError,
                              errorStyle: const TextStyle(color: Colors.red),
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (_nameError != null) const SizedBox(height: 5),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Icon(Icons.school, color: Colors.grey),
                        const SizedBox(width: 15),
                        Expanded(
                          child: TextFormField(
                            controller: _universityIdController,
                            keyboardType: TextInputType.number,
                            maxLength: 6,
                            decoration: InputDecoration(
                              hintText: "University ID without slash ",
                              helperText:
                                  "Enter only the 6-digit number (e.g., 000114)",
                              helperStyle: const TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                              hintStyle: const TextStyle(
                                  color: Colors.grey, fontSize: 16),
                              enabledBorder: const UnderlineInputBorder(
                                borderSide: BorderSide(
                                  color: Colors.grey,
                                  width: 1.0,
                                ),
                              ),
                              errorText: _universityIdError,
                              errorStyle: const TextStyle(color: Colors.red),
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (_universityIdError != null) const SizedBox(height: 5),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Icon(Icons.phone, color: Colors.grey),
                        const SizedBox(width: 15),
                        Expanded(
                          child: TextFormField(
                            controller: _phoneNumberController,
                            keyboardType: TextInputType.phone,
                            decoration: InputDecoration(
                              hintText: "Phone Number (e.g., 0912345678)",
                              helperText:
                                  "Enter your Ethiopian phone number starting with 09 or 07 (10 digits total)",
                              helperStyle: const TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                              hintStyle: const TextStyle(
                                  color: Colors.grey, fontSize: 16),
                              enabledBorder: const UnderlineInputBorder(
                                borderSide: BorderSide(
                                  color: Colors.grey,
                                  width: 1.0,
                                ),
                              ),
                              errorText: _phoneNumberError,
                              errorStyle: const TextStyle(color: Colors.red),
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (_phoneNumberError != null) const SizedBox(height: 5),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const Icon(Icons.key, color: Colors.grey),
                        const SizedBox(width: 15),
                        Expanded(
                          child: TextFormField(
                            controller: _passwordController,
                            onChanged: _checkPasswordStrength,
                            decoration: InputDecoration(
                              hintText: "Password",
                              hintStyle: const TextStyle(
                                  color: Colors.grey, fontSize: 16),
                              suffixIcon: IconButton(
                                  onPressed: () {
                                    setState(() {
                                      _isPasswordVisible = !_isPasswordVisible;
                                    });
                                  },
                                  icon: _isPasswordVisible
                                      ? const Icon(Icons.visibility)
                                      : const Icon(Icons.visibility_off)),
                              enabledBorder: const UnderlineInputBorder(
                                borderSide: BorderSide(
                                  color: Colors.grey,
                                  width: 1.0,
                                ),
                              ),
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                  color: _strength == 1.0
                                      ? Colors.green
                                      : _strength >= 0.75
                                          ? Colors.blue
                                          : _strength >= 0.5
                                              ? Colors.orange
                                              : Colors.red,
                                  width: 1.0,
                                ),
                              ),
                              errorText: _passwordError,
                              errorStyle: const TextStyle(color: Colors.red),
                            ),
                            obscureText: _isPasswordVisible ? false : true,
                          ),
                        ),
                      ],
                    ),
                    if (_passwordError != null) const SizedBox(height: 5),
                    const SizedBox(height: 30),
                    ElevatedButton(
                      onPressed: () {
                        validateAndRegister();
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        backgroundColor: Colors.blueAccent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: buttonChild,
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Already have RevoBike account? "),
                        TextButton(
                            onPressed: () {
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) => const LoginScreen()));
                            },
                            child: const Text("Login",
                                style: TextStyle(
                                  color: Colors.blue,
                                  fontWeight: FontWeight.bold,
                                )))
                      ],
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
