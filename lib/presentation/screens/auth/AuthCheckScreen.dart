import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:revobike/api/auth_service.dart';
import 'package:revobike/data/models/User.dart';
import 'package:revobike/presentation/screens/auth/LoginScreen.dart';
import 'package:revobike/presentation/screens/home/HomeScreen.dart';
import 'package:revobike/constants/app_colors.dart';

class AuthCheckScreen extends StatefulWidget {
  const AuthCheckScreen({super.key});

  @override
  _AuthCheckScreenState createState() => _AuthCheckScreenState();
}

class _AuthCheckScreenState extends State<AuthCheckScreen> {
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _checkAuthentication();
  }

  Future<void> _checkAuthentication() async {
    bool isAuthenticated = await _authService.isAuthenticated;

    if (isAuthenticated) {
      // Fetch user profile from local storage. It returns UserModel?, so handle null.
      final UserModel? user = await _authService.fetchUserProfile();

      if (user != null) {
        // If user profile is found, proceed to HomeScreen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      } else {
        // If authenticated but no local user profile (e.g., corrupted storage), force re-login
        print(
            'AuthCheckScreen: User authenticated but profile not found locally. Logging out.');
        await _authService.logout(); // Clear token too
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      }
    } else {
      // Not authenticated, navigate to LoginScreen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
          child: LoadingAnimationWidget.fallingDot(
              color: AppColors.secondaryGreen, size: 35)),
    );
  }
}
