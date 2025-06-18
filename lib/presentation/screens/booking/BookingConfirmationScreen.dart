import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lottie/lottie.dart';
import 'package:revobike/data/models/Station.dart'; // Ensure this is the updated Station model
import 'package:revobike/presentation/screens/booking/RideInProgressScreen.dart';
import 'package:revobike/api/ride_service.dart'; // Import the RideService
import 'dart:async';
import 'package:revobike/constants/app_colors.dart'; // Import your AppColors

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
  bool _isLoadingRideStart = false; // Initial state: not loading
  String? _rideStartError; // Stores API error message for starting ride

  Timer? _countdownTimer;
  int _countdownSeconds = 300; // 5 minutes

  @override
  void initState() {
    super.initState();
    _startCountdown(); // Start the countdown for confirmation
    // Removed _startRideWithBackend() from initState()
    // The ride will now start only when the user presses the "Start Ride" button.
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  // Method to initiate ride start with the backend
  Future<void> _startRideWithBackend() async {
    // Only attempt to start ride if not already loading and no error occurred
    if (_isLoadingRideStart || _rideStartError != null) return;

    setState(() {
      _isLoadingRideStart = true;
      _rideStartError = null; // Clear previous errors
    });

    try {
      final rideDetails = await _rideService.startRide(
        bikeId: widget.selectedBikeId,
        // You might need to pass initial location (lat/lng) here
        // if your API requires it for the startRide endpoint.
        // Example: initialLatitude: widget.station.location.lat,
        //          initialLongitude: widget.station.location.lng,
      );

      // Assuming your startRide API returns a map with an 'id' key for the new ride
      setState(() {
        _rideId = rideDetails['id'] as String?;
        _isLoadingRideStart = false;
      });

      if (_rideId != null) {
        _countdownTimer
            ?.cancel(); // Cancel countdown once ride successfully started
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => RideInProgressScreen(
              rideId: _rideId!,
              bikeId:
                  widget.selectedBikeId, // Pass bikeId to RideInProgressScreen
            ),
          ),
        );
      } else {
        // If API call was successful but rideId is null (unexpected)
        setState(() {
          _rideStartError = "Failed to get ride ID from response.";
        });
        _countdownTimer?.cancel(); // Stop timer on unexpected success
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to start ride: ${_rideStartError!}')),
        );
      }
    } catch (e) {
      // Handle API call errors
      setState(() {
        _rideStartError = e.toString().contains('Exception:')
            ? e.toString().split('Exception: ')[1]
            : 'Unknown error: $e'; // Provide a more user-friendly message
        _isLoadingRideStart = false;
      });
      _countdownTimer?.cancel(); // Stop timer on error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to start ride: ${_rideStartError!}')),
      );
      // Optionally pop the screen or show a retry button here
      // Navigator.pop(context); // You might want to remove this if you have a retry button
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
          // If time runs out, automatically cancel the booking/confirmation
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Booking confirmation expired.')),
          );
          _cancelRideStart(); // This will pop the screen
        }
      }
    });
  }

  // Handles cancellation before ride fully begins (e.g., user cancels during countdown)
  void _cancelRideStart() {
    _countdownTimer?.cancel();
    // TODO: Potentially call an API here to 'cancel' the booking on backend
    // if the user decides not to proceed within the countdown.
    Navigator.pop(
        context); // Go back to the previous screen (e.g., bike selection)
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
                    "Ride Confirmation",
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
                  child: _isLoadingRideStart // Show loading when starting ride
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
                      : _rideStartError !=
                              null // Show error if ride start failed
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
                          : // Show confirmation details if not loading and no error
                          Column(
                              children: [
                                Lottie.asset("assets/animations/bikee.json",
                                    width: 200, height: 200, fit: BoxFit.cover),
                                const SizedBox(height: 15),
                                Text(widget.station.name,
                                    style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold)),
                                Text(widget.station.name,
                                    style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.grey.shade600)),
                                const Divider(
                                    height: 30,
                                    thickness: 1,
                                    color: AppColors.secondaryGreen),
                                // Display selected bike ID
                                Text("Bike ID: ${widget.selectedBikeId}",
                                    style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold)),
                                Text(
                                    "Pricing Rate: Br.${widget.station.rate?.toStringAsFixed(2) ?? 'N/A'} per km",
                                    style: const TextStyle(fontSize: 16)),
                                const SizedBox(height: 20),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 10),
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryGreen,
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
                        foregroundColor: AppColors.primaryGreen,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: const BorderSide(color: AppColors.primaryGreen),
                        ),
                      ),
                      child: const Text("Cancel Ride"),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      // Only enable if not loading and no error
                      onPressed: (_isLoadingRideStart ||
                              _rideStartError != null)
                          ? null
                          : _startRideWithBackend, // Call the method to start the ride
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            (_isLoadingRideStart || _rideStartError != null)
                                ? Colors.grey
                                : AppColors.primaryGreen,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isLoadingRideStart
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text("Start Ride"),
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
