import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:revobike/presentation/screens/auth/AuthCheckScreen.dart';
import 'package:revobike/constants/app_colors.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Import SharedPreferences

void main() async { // Make main an async function
  WidgetsFlutterBinding.ensureInitialized(); // Ensure Flutter is initialized
  await SharedPreferences.getInstance(); // Initialize SharedPreferences early
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
      home: const AuthCheckScreen(),
    );
  }
}
