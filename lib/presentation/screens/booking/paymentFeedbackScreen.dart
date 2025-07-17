// lib/presentation/screens/payment/PaymentFeedbackScreen.dart
import 'package:flutter/material.dart';
import 'package:revobike/constants/app_colors.dart';
import 'package:revobike/presentation/screens/home/HomeScreen.dart'; // Assuming you want to go back to HomeScreen

class PaymentFeedbackScreen extends StatelessWidget {
  final bool isSuccess;
  final Map<String, dynamic> rideDetails; // To display summary if needed

  const PaymentFeedbackScreen({
    super.key,
    required this.isSuccess,
    required this.rideDetails,
  });

  @override
  Widget build(BuildContext context) {
    // Optional: Extract details from rideDetails for display
    final double? totalCost = (rideDetails['totalCost'] as num?)?.toDouble();

    return Scaffold(
      backgroundColor: isSuccess ? AppColors.primaryGreen : Colors.red[100],
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isSuccess ? Icons.check_circle_outline : Icons.error_outline,
                color: isSuccess ? Colors.white : Colors.red[700],
                size: 100,
              ),
              const SizedBox(height: 24),
              Text(
                isSuccess ? "payment complete, thank you" : "Payment Failed!",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: isSuccess ? Colors.white : Colors.red[700],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                isSuccess
                    ? "Your ride for Br.${totalCost?.toStringAsFixed(2) ?? 'N/A'} has been successfully paid."
                    : "There was an issue processing your payment. Please try again or contact support.",
                style: TextStyle(
                  fontSize: 16,
                  color: isSuccess ? Colors.white70 : Colors.red[600],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: () {
                  // Navigate back to the HomeScreen and clear the navigation stack
                  Navigator.of(context).popUntil((route) => route.isFirst);
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const HomeScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: isSuccess ? Colors.white : Colors.red[700],
                  foregroundColor:
                      isSuccess ? AppColors.primaryGreen : Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  isSuccess ? "back to home" : "Try Again / Go to Home",
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
