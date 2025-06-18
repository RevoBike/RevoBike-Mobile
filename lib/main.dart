import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:revobike/presentation/screens/auth/AuthCheckScreen.dart'; // Keep this import for later
import 'package:revobike/presentation/screens/onBoarding/OnBoardingScreen.dart'; // Import OnboardingScreen
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
          const SplashScreen(), // IMPORTANT: Set SplashScreen as the initial home widget
    );
  }
}

// Your SplashScreen widget
class SplashScreen extends StatefulWidget {
  // Changed to StatefulWidget to manage its own timer
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToNextScreen();
  }

  _navigateToNextScreen() async {
    // You can make this duration longer if your splash animation/branding takes more time
    await Future.delayed(
        const Duration(seconds: 2)); // Display splash for 2 seconds
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
            builder: (context) =>
                const OnboardingScreen()), // Navigate to OnboardingScreen
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Or your desired splash background color
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // You can replace this with an Image.asset for your logo
            Text(
              'StepGreen',
              style: GoogleFonts.rubik(
                // Use GoogleFonts for consistency
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryGreen,
              ),
            ),
            const SizedBox(height: 20),
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryGreen),
            ),
          ],
        ),
      ),
    );
  }
}
