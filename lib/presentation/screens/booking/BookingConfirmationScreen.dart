import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lottie/lottie.dart';
import 'package:revobike/presentation/screens/booking/RideInProgressScreen.dart';
import 'dart:async';

class BookingConfirmationScreen extends StatefulWidget {
  const BookingConfirmationScreen({super.key});

  @override
  State<BookingConfirmationScreen> createState() => _BookingConfirmationScreenState();
}

class _BookingConfirmationScreenState extends State<BookingConfirmationScreen> {
  String stationName = "Downtown Bike Hub";
  String stationLocation = "123 Main St, City Center";
  String bikeId = "#A1023";
  double pricePerKm = 0.5;
  int batteryLife = 85;
  bool isLoading = true;
  Timer? _countdownTimer;
  int _countdownSeconds = 300;

  @override
  void initState() {
    super.initState();
    _startCountdown();
    _simulateBookingProcess();
  }

  void _simulateBookingProcess() async {
    await Future.delayed(const Duration(seconds: 2));
    setState(() {
      isLoading = false;
    });
  }

  void _startCountdown() {
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_countdownSeconds > 0) {
        setState(() {
          _countdownSeconds--;
        });
      } else {
        timer.cancel();
        _cancelBooking();
      }
    });
  }

  void _confirmBooking() {
    _countdownTimer?.cancel();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const RideInProgressScreen()),
    );
  }

  void _cancelBooking() {
    _countdownTimer?.cancel();
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Booking Confirmation", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.blue))
          : Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.shade300,
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Lottie.asset("assets/animations/bikee.json", width: 200, height: 200, fit: BoxFit.cover),
                  const SizedBox(height: 15),
                  Text(stationName, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  Text(stationLocation, style: TextStyle(fontSize: 16, color: Colors.grey.shade600)),
                  const Divider(height: 30, thickness: 1, color: Colors.blueAccent),
                  Text("Bike ID: $bikeId", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  Text("Pricing Rate: \$$pricePerKm per km", style: const TextStyle(fontSize: 16)),
                  Text("Battery Life: $batteryLife%", style: const TextStyle(fontSize: 16)),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade700,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      "Time left: ${_countdownSeconds ~/ 60}:${(_countdownSeconds % 60).toString().padLeft(2, '0')}",
                      style: const TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              icon: const Icon(FontAwesomeIcons.check),
              label: const Text("Confirm & Start Ride"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade700,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                minimumSize: const Size(double.infinity, 50),
              ),
              onPressed: _confirmBooking,
            ),
            const SizedBox(height: 10),
            TextButton.icon(
              icon: const Icon(FontAwesomeIcons.circleXmark, color: Colors.red),
              label: const Text("Cancel Booking", style: TextStyle(color: Colors.red, fontSize: 16)),
              onPressed: _cancelBooking,
            ),
          ],
        ),
      ),
    );
  }
}