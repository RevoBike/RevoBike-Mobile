import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:revobike/api/auth_service.dart';
import 'package:revobike/presentation/screens/auth/LoginScreen.dart';
import 'package:revobike/presentation/screens/auth/OtpVerificationScreen.dart';
import 'package:revobike/constants/app_colors.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final AuthService authService = AuthService();
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
      final sanitized = text.replaceAll(RegExp(r'[^0-9a-zA-Z\/]'), '');
      if (text != sanitized) {
        final upperSanitized = sanitized.toUpperCase();
        _universityIdController.value = TextEditingValue(
          text: upperSanitized,
          selection: TextSelection.collapsed(offset: upperSanitized.length),
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

    final universityIdPattern = RegExp(r'^[A-Za-z]{3}\d{4}\/\d{2}$');
    if (!universityIdPattern.hasMatch(_universityIdController.text)) {
      setState(() => _universityIdError =
          'University ID must be in format: 3 letters, 4 digits, "/", 2 digits (e.g., ETS1673/14)');
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

      // First register the user (this will trigger OTP sending)
      final response = await authService.register(
        _nameController.text,
        _emailController.text,
        _passwordController.text,
        _universityIdController.text,
        _phoneNumberController.text,
      );

      if (!mounted) return;

      if (response['success'] == true) {
        // Show success feedback before navigation
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response['message']),
            backgroundColor: Colors.green,
          ),
        );

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
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Registration failed: ${response['message']}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
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
  void dispose() {
    _emailController.dispose();
    _nameController.dispose();
    _passwordController.dispose();
    _universityIdController.dispose();
    _phoneNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 30),
              Center(
                child: SvgPicture.asset(
                  "assets/images/signup_bike.svg",
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
                        const SizedBox(width: 15),
                        Expanded(
                          child: TextFormField(
                            controller: _emailController,
                            decoration: InputDecoration(
                              prefixIcon: const Icon(Icons.alternate_email,
                                  color: AppColors.primaryGreen),
                              labelText: "University Email",
                              hintText: "name.fathername@aastustudent.edu.et",
                              hintStyle: const TextStyle(
                                  color: Colors.grey, fontSize: 16),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(25.0),
                                borderSide: const BorderSide(),
                              ),
                              errorText: _emailError,
                              errorStyle: const TextStyle(color: Colors.red),
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (_emailError != null) const SizedBox(height: 5),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const SizedBox(width: 15),
                        Expanded(
                          child: TextFormField(
                            controller: _nameController,
                            decoration: InputDecoration(
                              prefixIcon: const Icon(Icons.face,
                                  color: AppColors.primaryGreen),
                              labelText: "Full Name",
                              hintText: "John Doe",
                              hintStyle: const TextStyle(
                                  color: Colors.grey, fontSize: 16),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(25.0),
                                borderSide: const BorderSide(),
                              ),
                              errorText: _nameError,
                              errorStyle: const TextStyle(color: Colors.red),
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (_nameError != null) const SizedBox(height: 5),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const SizedBox(width: 15),
                        Expanded(
                          child: TextFormField(
                            controller: _universityIdController,
                            keyboardType: TextInputType.number,
                            maxLength: 10,
                            decoration: InputDecoration(
                              prefixIcon: const Icon(Icons.school,
                                  color: AppColors.primaryGreen),
                              labelText: "University ID",
                              hintText: "ETS1234/14",
                              helperText: "Enter full ID",
                              helperStyle: const TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                              hintStyle: const TextStyle(
                                  color: Colors.grey, fontSize: 16),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(25.0),
                                borderSide: const BorderSide(),
                              ),
                              errorText: _universityIdError,
                              errorStyle: const TextStyle(color: Colors.red),
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (_universityIdError != null) const SizedBox(height: 5),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const SizedBox(width: 15),
                        Expanded(
                          child: TextFormField(
                            controller: _phoneNumberController,
                            keyboardType: TextInputType.phone,
                            decoration: InputDecoration(
                              prefixIcon: const Icon(Icons.phone,
                                  color: AppColors.primaryGreen),
                              labelText: "Phone Number",
                              hintText: "0912345678",
                              helperText:
                                  "Enter your phone number starting with 09 or 07 (10 digits total)",
                              helperStyle: const TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                              hintStyle: const TextStyle(
                                  color: Colors.grey, fontSize: 16),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(25.0),
                                borderSide: const BorderSide(),
                              ),
                              errorText: _phoneNumberError,
                              errorStyle: const TextStyle(color: Colors.red),
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (_phoneNumberError != null) const SizedBox(height: 5),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        const SizedBox(width: 15),
                        Expanded(
                          child: TextFormField(
                            controller: _passwordController,
                            onChanged: _checkPasswordStrength,
                            decoration: InputDecoration(
                              prefixIcon: const Icon(Icons.key,
                                  color: AppColors.primaryGreen),
                              labelText: "Password",
                              hintText: "********",
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
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(25.0),
                                borderSide: const BorderSide(),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(25.0),
                                borderSide: BorderSide(
                                  color: _strength == 1.0
                                      ? Colors.green
                                      : _strength >= 0.75
                                          ? AppColors.primaryGreen
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
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        backgroundColor: AppColors.secondaryGreen,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
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
                                  color: AppColors.primaryGreen,
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
