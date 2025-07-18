import 'package:flutter/material.dart';
import 'package:revobike/presentation/screens/booking/PaymentScreen.dart';
import 'package:revobike/api/ride_service.dart'; // Import RideService
import 'dart:async'; // For Timer and Future.delayed if needed for UI, but main logic is API
import 'package:revobike/api/auth_service.dart';
import 'package:location/location.dart' as loc_lib; // Uncomment if adding map
import 'dart:math'; // For math functions like sin, cos, sqrt, atan2
import 'package:flutter_svg/flutter_svg.dart';

class RideInProgressScreen extends StatefulWidget {
  final String rideId;
  final String bikeId;

  const RideInProgressScreen({
    super.key,
    required this.rideId,
    required this.bikeId,
  });

  @override
  _RideInProgressScreenState createState() => _RideInProgressScreenState();
}

class _RideInProgressScreenState extends State<RideInProgressScreen> {
  final RideService _rideService = RideService(
      authService: AuthService()); // Pass singleton AuthService instance

  String _statusMessage = 'Ride in progress...';
  bool _isEndingRide = false;
  String? _rideEndError;

// Placeholder for map-related state, if you decide to add live tracking later
// LatLng _currentLocation = const LatLng(0, 0); // User's live location
// bool _isNearStation = false; // Flag to enable 'End Ride' button
  final loc_lib.Location _location = loc_lib.Location();
  StreamSubscription<loc_lib.LocationData>? _locationSubscription;

// For demonstration, let's make _isNearStation true after a delay
// In a real app, this would be based on actual geofencing/proximity logic
  bool _isNearStationPlaceholder = false;
  Timer? _enableEndRideTimer;

  double _distanceTravelled = 0.0;
  loc_lib.LocationData? _lastLocation;

  @override
  void initState() {
    super.initState();
    _statusMessage = 'Your ride with bike ${widget.bikeId} has started.';
    _distanceTravelled = 0.0;

    // Start listening to location updates
    _startLocationUpdates();

    // For demo: simulate being near a station after 30 seconds instead of 10
    _enableEndRideTimer = Timer(const Duration(seconds: 30), () {
      if (mounted) {
        setState(() {
          _isNearStationPlaceholder = true;
          _statusMessage = 'You are near a drop-off station.';
        });
      }
    });
  }

  void _startLocationUpdates() {
    _locationSubscription = _location.onLocationChanged
        .listen((loc_lib.LocationData currentLocationData) {
      if (mounted &&
          currentLocationData.latitude != null &&
          currentLocationData.longitude != null) {
        setState(() {
          if (_lastLocation != null) {
            _distanceTravelled += _calculateDistance(
              _lastLocation!.latitude!,
              _lastLocation!.longitude!,
              currentLocationData.latitude!,
              currentLocationData.longitude!,
            );
          }
          _lastLocation = currentLocationData;
          _statusMessage =
              'Ride started. Distance travelled: ${_distanceTravelled.toStringAsFixed(2)} meters';
        });
      }
    });
  }

  double _calculateDistance(
      double lat1, double lon1, double lat2, double lon2) {
    const double earthRadius = 6371000; // meters
    double dLat = _degreesToRadians(lat2 - lat1);
    double dLon = _degreesToRadians(lon2 - lon1);

    double a = (sin(dLat / 2) * sin(dLat / 2)) +
        cos(_degreesToRadians(lat1)) *
            cos(_degreesToRadians(lat2)) *
            (sin(dLon / 2) * sin(dLon / 2));
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    double distance = earthRadius * c;
    return distance;
  }

  double _degreesToRadians(double degrees) {
    return degrees * (3.141592653589793 / 180);
  }

  @override
  void dispose() {
    _enableEndRideTimer?.cancel();
    _locationSubscription?.cancel();
    super.dispose();
  }

  void _endRide() async {
    setState(() {
      _isEndingRide = true;
      _rideEndError = null;
      _statusMessage = 'Ending ride... Please wait.';
    });

    try {
      final Map<String, dynamic> rideDetails = await _rideService.endRide(
        rideId: widget.rideId,
        finalLatitude: _lastLocation?.latitude,
        finalLongitude: _lastLocation?.longitude,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ride ended successfully!')),
        );
        // Navigate to PaymentScreen with ride details
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => PaymentScreen(rideDetails: rideDetails),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _rideEndError = e.toString();
          _statusMessage = 'Error ending ride: $_rideEndError';
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to end ride: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isEndingRide = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Ride in Progress"),
        automaticallyImplyLeading: false, // Hide default back button
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset(
                "assets/images/bike_parking.svg",
                // Ensure this Lottie asset exists
                width: 250,
                height: 250,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 30),
              Text(
                _statusMessage,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueAccent,
                ),
              ),
              const SizedBox(height: 20),
              if (_isEndingRide)
                const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.blueAccent),
                )
              else if (_rideEndError != null)
                Column(
                  children: [
                    const Icon(Icons.error, color: Colors.red, size: 60),
                    const SizedBox(height: 10),
                    Text(
                      'Error: $_rideEndError',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.red, fontSize: 16),
                    ),
                  ],
                )
              else
                ElevatedButton(
                  onPressed: _isNearStationPlaceholder && !_isEndingRide
                      ? _endRide
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isNearStationPlaceholder
                        ? Colors.redAccent
                        : Colors.grey,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 40, vertical: 15),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text(
                    "End Ride",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
