import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lottie/lottie.dart';
import 'package:revobike/data/models/Station.dart';
import 'package:revobike/presentation/screens/booking/RideInProgressScreen.dart';
import 'dart:async';

class BookingConfirmationScreen extends StatefulWidget {
  final Station station;

  const BookingConfirmationScreen({super.key, required this.station});

  @override
  State<BookingConfirmationScreen> createState() =>
      _BookingConfirmationScreenState();
}

class _BookingConfirmationScreenState extends State<BookingConfirmationScreen> {
  String bikeId = "#A1023";
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
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconButton(
                    icon: const Icon(FontAwesomeIcons.arrowLeft),
                    onPressed: _cancelBooking,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    "Booking Confirmation",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Lottie.asset("assets/animations/bikee.json",
                          width: 200, height: 200, fit: BoxFit.cover),
                      const SizedBox(height: 15),
                      Text(widget.station.name,
                          style: const TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold)),
                      Text(widget.station.location,
                          style: TextStyle(
                              fontSize: 16, color: Colors.grey.shade600)),
                      const Divider(
                          height: 30, thickness: 1, color: Colors.blueAccent),
                      Text("Bike ID: $bikeId",
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      Text("Pricing Rate: Br.${widget.station.rate} per km",
                          style: const TextStyle(fontSize: 16)),
                      Text("Battery Life: $batteryLife%",
                          style: const TextStyle(fontSize: 16)),
                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade700,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          "Time left: ${_countdownSeconds ~/ 60}:${(_countdownSeconds % 60).toString().padLeft(2, '0')}",
                          style: const TextStyle(
                              fontSize: 18,
                              color: Colors.white,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 30),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _cancelBooking,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.blue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: const BorderSide(color: Colors.blue),
                        ),
                      ),
                      child: const Text("Cancel"),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _confirmBooking,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text("Confirm"),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
