import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:revobike/data/models/Station.dart';
import 'package:revobike/presentation/screens/booking/RideInProgressScreen.dart';
import 'package:revobike/presentation/screens/booking/PaymentScreen.dart'; // Import PaymentScreen
import 'package:revobike/api/ride_service.dart'; // Import the RideService
import 'dart:async';
import 'package:revobike/api/auth_service.dart';
import 'package:revobike/presentation/screens/recent/RecentScreen.dart'; // Import RecentTripsScreen

class BookingConfirmationScreen extends StatefulWidget {
  final Station station;
  final String selectedBikeId;

  const BookingConfirmationScreen({
    super.key,
    required this.station,
    required this.selectedBikeId,
  });

  @override
  State<BookingConfirmationScreen> createState() =>
      _BookingConfirmationScreenState();
}

class _BookingConfirmationScreenState extends State<BookingConfirmationScreen> {
  final RideService _rideService = RideService(
      authService: AuthService()); // Pass singleton AuthService instance

  String? _rideId;
  bool _isLoadingRideStart = false;
  String? _rideStartError;

  Timer? _countdownTimer;
  int _countdownSeconds =
      30; // 30 seconds countdown for demo, replace with real geofence later

  @override
  void initState() {
    super.initState();
    _startCountdown();
    // Call the actual API to start the ride
    _startRideApiCall();
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  // Actual API call to start the ride
  void _startRideApiCall() async {
    setState(() {
      _isLoadingRideStart = true;
      _rideStartError = null;
    });

    try {
      final Map<String, dynamic> rideResponse =
          await _rideService.startRide(bikeId: widget.selectedBikeId);

      print('Ride start API response: \$rideResponse'); // Debug print

      if (mounted) {
        setState(() {
          _rideId = rideResponse['_id']
              as String; // Use '_id' as per backend response for the new ride
          _isLoadingRideStart = false;
        });
      }
    } catch (e) {
      if (mounted) {
        String errorMessage = e.toString();
        if (errorMessage.contains('unpaid ride')) {
          // Show dialog to inform user and redirect to payment screen
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Unpaid Ride Detected'),
              content: const Text(
                  'You have an unpaid ride. Please complete the payment first.'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const RecentTripsScreen(),
                      ),
                    );
                  },
                  child: const Text('Go to Payment'),
                ),
              ],
            ),
          );
        } else {
          setState(() {
            _rideStartError = errorMessage;
            _isLoadingRideStart = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to start ride: $errorMessage')),
          );
        }
      }
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
          _cancelRideStart();
        }
      }
    });
  }

  void _navigateToRideInProgress() {
    _countdownTimer?.cancel();
    // Navigate to RideInProgressScreen, passing actual rideId and bikeId
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => RideInProgressScreen(
          rideId: _rideId!, // Ensure _rideId is not null before navigating
          bikeId: widget.selectedBikeId,
        ),
      ),
    );
  }

  void _navigateToPaymentScreen(Map<String, dynamic> rideDetails) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => PaymentScreen(rideDetails: rideDetails),
      ),
    );
  }

  void _cancelRideStart() {
    _countdownTimer?.cancel();
    // Potentially call an API to cancel the initiated ride if it wasn't picked up
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
                  child: _isLoadingRideStart
                      ? Column(
                          children: [
                            SvgPicture.asset("assets/images/bike_parking.svg",
                                width: 200, height: 200, fit: BoxFit.cover),
                            const SizedBox(height: 15),
                            const CircularProgressIndicator(),
                            const SizedBox(height: 10),
                            const Text('Initiating ride via API...',
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
                                      _startRideApiCall, // Allow retry for API call
                                  child: const Text('Retry Ride Start'),
                                ),
                              ],
                            )
                          : Column(
                              children: [
                                SvgPicture.asset(
                                    "assets/images/bike_parking.svg",
                                    width: 200,
                                    height: 200,
                                    fit: BoxFit.cover),
                                const SizedBox(height: 15),
                                Text(widget.station.name,
                                    style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold)),
                                Text(
                                    widget.station.address ??
                                        widget.station.name,
                                    style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.grey.shade600)),
                                const Divider(
                                    height: 30,
                                    thickness: 1,
                                    color: Colors.blueAccent),
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
                      child: const Text("Cancel Ride"),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      // Enable button only if not loading, no error, and _rideId is set by API
                      onPressed: _isLoadingRideStart ||
                              _rideStartError != null ||
                              _rideId == null
                          ? null
                          : _navigateToRideInProgress,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isLoadingRideStart ||
                                _rideStartError != null ||
                                _rideId == null
                            ? Colors.grey
                            : Colors.blue,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text("Start Ride"),
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
