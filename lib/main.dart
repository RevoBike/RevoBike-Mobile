import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:revobike/presentation/screens/auth/AuthCheckScreen.dart';
import 'package:revobike/presentation/screens/home/HomeScreen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RevoBike',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
          textTheme: GoogleFonts.rubikTextTheme()
      ),
      debugShowCheckedModeBanner: false,
      home: const HomeScreen()
    );
  }
}
