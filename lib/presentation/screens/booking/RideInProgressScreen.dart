import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lottie/lottie.dart';
import 'package:revobike/presentation/screens/booking/PaymentScreen.dart';
import 'package:revobike/api/ride_service.dart'; // Import RideService
import 'dart:async'; // For Timer and Future.delayed if needed for UI, but main logic is API
// import 'package:google_maps_flutter/google_maps_flutter.dart'; // Uncomment if adding map
// import 'package:location/location.dart' as loc_lib; // Uncomment if adding map

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
  final RideService _rideService = RideService(); // Instantiate RideService

  String _statusMessage = 'Ride in progress...';
  bool _isEndingRide = false;
  String? _rideEndError;

  // Placeholder for map-related state, if you decide to add live tracking later
  // LatLng _currentLocation = const LatLng(0, 0); // User's live location
  // bool _isNearStation = false; // Flag to enable 'End Ride' button
  // loc_lib.Location _location = loc_lib.Location();
  // StreamSubscription<loc_lib.LocationData>? _locationSubscription;

  // For demonstration, let's make _isNearStation true after a delay
  // In a real app, this would be based on actual geofencing/proximity logic
  bool _isNearStationPlaceholder = false;
  Timer? _enableEndRideTimer;

  @override
  void initState() {
    super.initState();
    _statusMessage = 'Your ride with bike ${widget.bikeId} has started.';

    // Simulate being near a station to enable the end ride button after a few seconds
    _enableEndRideTimer = Timer(const Duration(seconds: 10), () {
      if (mounted) {
        setState(() {
          _isNearStationPlaceholder = true;
          _statusMessage = 'You are near a drop-off station.';
        });
      }
    });

    // If you integrate live location tracking:
    // _startLocationUpdates();
  }

  @override
  void dispose() {
    _enableEndRideTimer?.cancel();
    // _locationSubscription?.cancel(); // Uncomment if using location updates
    super.dispose();
  }

  // Example for real-time location updates (uncomment and integrate if needed)
  /*
  void _startLocationUpdates() {
    _locationSubscription = _location.onLocationChanged.listen((loc_lib.LocationData currentLocationData) {
      if (mounted && currentLocationData.latitude != null && currentLocationData.longitude != null) {
        setState(() {
          _currentLocation = LatLng(currentLocationData.latitude!, currentLocationData.longitude!);
          // TODO: Implement logic to check if _currentLocation is near a valid end station
          // For now, _isNearStationPlaceholder handles the button activation
          // _isNearStation = checkProximityToStation(_currentLocation);
        });
      }
    });
  }
  */

  void _endRide() async {
    setState(() {
      _isEndingRide = true;
      _rideEndError = null;
      _statusMessage = 'Ending ride... Please wait.';
    });

    try {
      // In a real app, get the actual current location
      // For now, use a dummy final location
      // final loc_lib.LocationData finalLocation = await _location.getLocation();
      // double finalLatitude = finalLocation.latitude ?? 0.0;
      // double finalLongitude = finalLocation.longitude ?? 0.0;
      double finalLatitude = 8.883137025013506; // Dummy end location latitude
      double finalLongitude = 38.80912475266776; // Dummy end location longitude

      final Map<String, dynamic> rideDetails = await _rideService.endRide(
        rideId: widget.rideId,
        finalLatitude: finalLatitude,
        finalLongitude: finalLongitude,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ride ended successfully!')),
        );
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
              Lottie.asset(
                "assets/animations/bike_ride.json", // Ensure this Lottie asset exists
                width: 250,
                height: 250,
                fit: BoxFit.contain,
                repeat: true, // Animation repeats indefinitely during ride
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
