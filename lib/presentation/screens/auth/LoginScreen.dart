import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:revobike/api/auth_service.dart';
import 'package:revobike/data/models/User.dart';
import 'package:revobike/presentation/screens/auth/SignUpScreen.dart';
import 'package:revobike/presentation/screens/home/HomeScreen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthService _authService = AuthService(
    baseUrl: const String.fromEnvironment('API_BASE_URL',
        defaultValue: 'http://localhost:5000/api'),
  );
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isPasswordVisible = false;

  String? _emailError;
  String? _passwordError;

  String _errorMessage = '';

  Widget buttonChild = const Text(
    "Login",
    style: TextStyle(
        color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600),
  );

  void _validateAndLogin() async {
    setState(() {
      _errorMessage = '';
      _emailError = _emailController.text.isEmpty ? 'Email is required' : null;
      _passwordError =
          _passwordController.text.isEmpty ? 'Password is required' : null;
    });

    if (_emailError == null && _passwordError == null) {
      try {
        setState(() {
          buttonChild =
              LoadingAnimationWidget.fallingDot(color: Colors.white, size: 20);
        });
        await _authService.login(
          _emailController.text,
          _passwordController.text,
        );
        UserModel user = await _authService.fetchUserProfile();
        print(user); // Successfully logged in user profile
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      } catch (e) {
        setState(() {
          _errorMessage = e.toString(); // Display specific error message
        });
      } finally {
        setState(() {
          buttonChild = const Text(
            "Login",
            style: TextStyle(
                color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600),
          );
        });
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 30),
              Center(
                child: SvgPicture.asset(
                  "assets/images/bike_parking.svg",
                  width: MediaQuery.of(context).size.width / 1.2,
                  height: MediaQuery.of(context).size.height / 2.7,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                "Login",
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
                      children: [
                        const Icon(Icons.key, color: Colors.grey),
                        const SizedBox(width: 15),
                        Expanded(
                          child: TextFormField(
                            controller: _passwordController,
                            decoration: InputDecoration(
                                hintText: "Password",
                                hintStyle: const TextStyle(
                                    color: Colors.grey, fontSize: 16),
                                enabledBorder: const UnderlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Colors.grey,
                                    width: 1.0,
                                  ),
                                ),
                                suffixIcon: IconButton(
                                    onPressed: () {
                                      setState(() {
                                        _isPasswordVisible =
                                            !_isPasswordVisible;
                                      });
                                    },
                                    icon: _isPasswordVisible
                                        ? const Icon(Icons.visibility)
                                        : const Icon(Icons.visibility_off))),
                            obscureText: _isPasswordVisible ? false : true,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      "Forgot Password?",
                      style: TextStyle(
                          fontWeight: FontWeight.w900,
                          color: Colors.blueAccent,
                          fontSize: 14),
                      textAlign: TextAlign.end,
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () {
                        _validateAndLogin();
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
                        const Text("New to RevoBike? "),
                        TextButton(
                            onPressed: () {
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) => const SignUpScreen()));
                            },
                            child: const Text("Register",
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
