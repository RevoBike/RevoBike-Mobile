import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:revobike/presentation/screens/auth/AuthCheckScreen.dart'; // Import AuthCheckScreen
import 'package:revobike/constants/app_colors.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'StepGreen',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primaryGreen),
        useMaterial3: true,
        textTheme: GoogleFonts.rubikTextTheme(),
      ),
      debugShowCheckedModeBanner: false,
      home:
          const AuthCheckScreen(), // IMPORTANT: Set AuthCheckScreen as the initial home widget
    );
  }
}

// You no longer need a custom SplashScreen widget if AuthCheckScreen handles the initial loading.
// If you want a branding splash screen before AuthCheckScreen, you could build it
// as a separate, very short-lived screen that then navigates to AuthCheckScreen.
// For simplicity, AuthCheckScreen will now serve as your initial loading/check screen.

// If you still want a visual splash screen before AuthCheckScreen:
/*
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Future.delayed(const Duration(milliseconds: 500), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const AuthCheckScreen()),
      );
    });

    return const Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'StepGreen',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryGreen,
              ),
            ),
            SizedBox(height: 20),
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryGreen),
            ),
          ],
        ),
      ),
    );
  }
}
*/
