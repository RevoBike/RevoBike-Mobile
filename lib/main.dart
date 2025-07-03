import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:revobike/presentation/screens/auth/AuthCheckScreen.dart'; // Use AuthCheckScreen as home
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
      home: const AuthCheckScreen(), // Changed from SplashScreen to AuthCheckScreen
    );
  }
}
