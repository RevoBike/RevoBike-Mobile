import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:revobike/api/auth_service.dart';
import 'package:revobike/data/models/User.dart';
import 'package:revobike/presentation/screens/auth/LoginScreen.dart';
import 'package:revobike/presentation/screens/home/HomeScreen.dart';
import 'package:revobike/presentation/screens/onBoarding/OnBoardingScreen.dart';
import 'package:revobike/constants/app_colors.dart';

class AuthCheckScreen extends StatefulWidget {
  const AuthCheckScreen({super.key});

  @override
  _AuthCheckScreenState createState() => _AuthCheckScreenState();
}

class _AuthCheckScreenState extends State<AuthCheckScreen> {
  // Use the singleton instance
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _checkInitialFlow();
  }

  Future<void> _checkInitialFlow() async {
    try {
      // 1. Check if onboarding has been seen
      final bool hasSeenOnboarding = await _authService.hasSeenOnboarding();

      if (!hasSeenOnboarding) {
        // First-time user, navigate to Onboarding Screen
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const OnboardingScreen()),
          );
        }
        return; // Stop further checks
      }

      // 2. If onboarding has been seen, proceed with authentication check
      bool isAuthenticated = await _authService.isAuthenticated;

      if (isAuthenticated) {
        final UserModel? user = await _authService.fetchUserProfile();

        if (user != null) {
          // Authenticated and profile found, go to HomeScreen
          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const HomeScreen()),
            );
          }
        } else {
          // Authenticated but no local user profile (corrupted storage?), force re-login
          await _authService.logout();
          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const LoginScreen()),
            );
          }
        }
      } else {
        // Not authenticated, navigate to LoginScreen (onboarding already seen)
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const LoginScreen()),
          );
        }
      }
    } catch (e) {
      // Handle any errors that occur during the authentication check
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error checking authentication: $e')),
        );
        // Optionally, navigate to LoginScreen on error
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      }
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
