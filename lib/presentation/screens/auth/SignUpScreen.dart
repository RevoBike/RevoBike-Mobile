import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:revobike/api/auth_service.dart';
import 'package:revobike/data/models/User.dart';
import 'package:revobike/presentation/screens/auth/LoginScreen.dart';
import 'package:revobike/presentation/screens/home/HomeScreen.dart';

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
  bool _isPasswordVisible = false;

  double _strength = 0.0;

  Widget buttonChild = const Text(
    "Sign Up",
    style: TextStyle(
        color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600),
  );

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
    if (_emailController.text.isEmpty ||
        _nameController.text.isEmpty ||
        _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill all fields'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    if (_emailController.text.length < 6 ||
        _nameController.text.length < 6 ||
        _passwordController.text.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Minimum length is 6 characters'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    try {
      setState(() {
        buttonChild =
            LoadingAnimationWidget.fallingDot(color: Colors.white, size: 20);
      });
      await authService.register(
        _nameController.text,
        _emailController.text,
        _passwordController.text,
      );
      await authService
          .fetchUserProfile(); // Successfully registered user profile
      UserModel user = await authService.fetchUserProfile();
      print(user); // Successfully registered user profile
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        buttonChild = const Text(
          "Sign Up",
          style: TextStyle(
              color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600),
        );
      });
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
                            decoration: const InputDecoration(
                              hintText: "Email ID",
                              hintStyle:
                                  TextStyle(color: Colors.grey, fontSize: 16),
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                  color: Colors.grey,
                                  width: 1.0,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Icon(Icons.face, color: Colors.grey),
                        const SizedBox(width: 15),
                        Expanded(
                          child: TextFormField(
                            controller: _nameController,
                            decoration: const InputDecoration(
                              hintText: "Full Name",
                              hintStyle:
                                  TextStyle(color: Colors.grey, fontSize: 16),
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                  color: Colors.grey,
                                  width: 1.0,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
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
                                        _isPasswordVisible =
                                            !_isPasswordVisible;
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
                                )),
                            obscureText: _isPasswordVisible ? false : true,
                          ),
                        ),
                      ],
                    ),
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
