import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lottie/lottie.dart';
import 'package:revobike/data/models/Station.dart'; // Ensure this is the updated Station model
import 'package:revobike/presentation/screens/booking/RideInProgressScreen.dart';
import 'package:revobike/api/ride_service.dart'; // Import the RideService
import 'dart:async';

class BookingConfirmationScreen extends StatefulWidget {
  final Station station;
  final String selectedBikeId; // NEW: Requires the specific bike ID

  const BookingConfirmationScreen({
    super.key,
    required this.station,
    required this.selectedBikeId, // Make selectedBikeId required
  });

  @override
  State<BookingConfirmationScreen> createState() =>
      _BookingConfirmationScreenState();
}

class _BookingConfirmationScreenState extends State<BookingConfirmationScreen> {
  final RideService _rideService = RideService(); // Instantiate RideService
  String? _rideId; // To store the rideId received from start ride API
  bool _isLoadingRideStart =
      true; // Tracks the API call state for starting ride
  String? _rideStartError; // Stores API error message for starting ride

  Timer? _countdownTimer;
  int _countdownSeconds = 300; // 5 minutes

  @override
  void initState() {
    super.initState();
    _startCountdown();
    _startRideWithBackend(); // Initiate ride start with backend
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  // Method to initiate ride start with the backend
  Future<void> _startRideWithBackend() async {
    setState(() {
      _isLoadingRideStart = true;
      _rideStartError = null;
    });

    try {
      final rideDetails = await _rideService.startRide(
        bikeId: widget.selectedBikeId,
      );

      setState(() {
        _rideId = rideDetails['rideId'] as String?; // Adjust key if different
        // If your backend returns bike details (like battery life) here,
        // you can capture them:
        // _bookedBatteryLife = rideDetails['bike']['batteryLife'] as int?;
        _isLoadingRideStart = false;
      });

      // If ride started successfully, the countdown continues as a "time to get on bike"
    } catch (e) {
      setState(() {
        _rideStartError = e.toString().contains('Exception:')
            ? e.toString().split('Exception: ')[1]
            : e.toString();
        _isLoadingRideStart = false;
      });
      // Immediately cancel countdown and show error if ride fails to start
      _countdownTimer?.cancel();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to start ride: ${_rideStartError!}')),
      );
      // Automatically navigate back if ride couldn't start
      Navigator.pop(context);
    }
  }

  void _startCountdown() {
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_countdownSeconds > 0) {
        if (mounted) {
          setState(() {
            _countdownSeconds--;
          });
        }
      } else {
        timer.cancel();
        if (mounted) {
          // If time runs out before 'Confirm', it should cancel the initiated ride
          _cancelRideStart();
        }
      }
    });
  }

  // Navigates to RideInProgressScreen if ride has successfully started
  void _navigateToRideInProgress() {
    _countdownTimer?.cancel();
    if (_rideId != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => RideInProgressScreen(
            rideId: _rideId!, // Pass the rideId to the next screen
            // You might also pass initial location and other ride details
          ),
        ),
      );
    } else {
      // This case should ideally not be reachable if 'Confirm' button is disabled until _rideId is set
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content:
                Text('Ride not initiated. Cannot start ride in progress.')),
      );
    }
  }

  // Handles cancellation before ride fully begins (e.g., user cancels during countdown)
  void _cancelRideStart() {
    _countdownTimer?.cancel();
    // Potentially call an API here to 'cancel' the ride initiation on backend if it has a cancellable state
    // For now, simply pop the screen.
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
                    onPressed: _cancelRideStart,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    "Ride Confirmation", // Changed to Ride Confirmation
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
                  child: _isLoadingRideStart
                      ? Column(
                          children: [
                            Lottie.asset("assets/animations/bikee.json",
                                width: 200, height: 200, fit: BoxFit.cover),
                            const SizedBox(height: 15),
                            const CircularProgressIndicator(),
                            const SizedBox(height: 10),
                            const Text('Attempting to start your ride...',
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: 16)),
                          ],
                        )
                      : _rideStartError != null
                          ? Column(
                              children: [
                                const Icon(Icons.error,
                                    color: Colors.red, size: 60),
                                const SizedBox(height: 15),
                                Text(
                                  'Ride Start Error: ${_rideStartError!}',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                      fontSize: 16, color: Colors.red),
                                ),
                                const SizedBox(height: 15),
                                ElevatedButton(
                                  onPressed:
                                      _startRideWithBackend, // Allow retry
                                  child: const Text('Retry Ride Start'),
                                ),
                              ],
                            )
                          : Column(
                              children: [
                                Lottie.asset("assets/animations/bikee.json",
                                    width: 200, height: 200, fit: BoxFit.cover),
                                const SizedBox(height: 15),
                                Text(widget.station.name,
                                    style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold)),
                                // Using station.name for the textual location, adjust if 'location' string is better
                                Text(widget.station.name,
                                    style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.grey.shade600)),
                                const Divider(
                                    height: 30,
                                    thickness: 1,
                                    color: Colors.blueAccent),
                                // Display selected bike ID
                                Text("Bike ID: ${widget.selectedBikeId}",
                                    style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold)),
                                Text(
                                    "Pricing Rate: Br.${widget.station.rate?.toStringAsFixed(2) ?? 'N/A'} per km",
                                    style: const TextStyle(fontSize: 16)),
                                // Removed hardcoded battery life, as it might come from API or be calculated
                                // Text("Battery Life: $_bookedBatteryLife%",
                                //     style: const TextStyle(fontSize: 16)),
                                const SizedBox(height: 20),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 10),
                                  decoration: BoxDecoration(
                                    color: Colors.blue.shade700,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    "Time left to unlock: ${_countdownSeconds ~/ 60}:${(_countdownSeconds % 60).toString().padLeft(2, '0')}",
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
                      onPressed: _cancelRideStart,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.blue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: const BorderSide(color: Colors.blue),
                        ),
                      ),
                      child:
                          const Text("Cancel Ride"), // Changed to "Cancel Ride"
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      // Only allow Confirm if ride started successfully and not loading/error
                      onPressed: _isLoadingRideStart ||
                              _rideStartError != null ||
                              _rideId == null
                          ? null // Disable button
                          : _navigateToRideInProgress, // Enable button
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isLoadingRideStart ||
                                _rideStartError != null ||
                                _rideId == null
                            ? Colors.grey // Grey out if not ready
                            : Colors.blue,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child:
                          const Text("Start Ride"), // Changed to "Start Ride"
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
