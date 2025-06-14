import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart' as loc_lib; // Alias location package
import 'package:geolocator/geolocator.dart'; // Already imported
import 'package:revobike/api/ride_service.dart'; // Import RideService
import 'package:revobike/presentation/screens/booking/PaymentScreen.dart'; // Ensure correct path for PaymentScreen
import 'dart:math';

class RideInProgressScreen extends StatefulWidget {
  final String rideId; // NEW: Requires the ride ID
  // You might also pass other initial ride details like bike ID, start time, etc.
  final String bikeId; // Assuming you might want to display this

  const RideInProgressScreen({
    super.key,
    required this.rideId,
    this.bikeId = 'N/A', // Default to N/A if not passed
  });

  @override
  _RideInProgressScreenState createState() => _RideInProgressScreenState();
}

class _RideInProgressScreenState extends State<RideInProgressScreen> {
  GoogleMapController? _controller;
  final loc_lib.Location _location = loc_lib.Location(); // Use aliased Location
  LatLng? _currentPosition;
  final List<LatLng> _routeCoordinates = [];
  double _distanceTraveled = 0.0;
  bool _isNearStation = false;
  final double _stationRadius = 100.0; // Meters
  bool _isLoadingEndRide = false; // Tracks loading state for ending ride API
  String? _endRideError; // Stores error message for ending ride API

  // Hardcoded station locations (ideally fetched from API like in MapScreen)
  final List<LatLng> _stations = [
    const LatLng(9.0069631, 38.7622717), // Meskel Square
    const LatLng(9.0016631, 38.723503), // Tor Hayloch
    const LatLng(8.9812889, 38.7596757), // Saris Abo
  ];

  final RideService _rideService = RideService(); // Instantiate RideService

  @override
  void initState() {
    super.initState();
    print(
        'RideInProgressScreen: Ride ID: ${widget.rideId}, Bike ID: ${widget.bikeId}');
    _startTracking();
  }

  // Starts tracking user's location and updates route/distance
  void _startTracking() {
    _location.onLocationChanged.listen((loc_lib.LocationData currentLocation) {
      if (currentLocation.latitude == null || currentLocation.longitude == null)
        return;
      LatLng newPosition =
          LatLng(currentLocation.latitude!, currentLocation.longitude!);

      if (_currentPosition != null) {
        // Calculate distance between previous and new point
        double segmentDistance = Geolocator.distanceBetween(
          _currentPosition!.latitude,
          _currentPosition!.longitude,
          newPosition.latitude,
          newPosition.longitude,
        );
        setState(() {
          _distanceTraveled += segmentDistance;
          _routeCoordinates.add(newPosition);
          _isNearStation = _checkProximityToStations(newPosition);
        });
      } else {
        // Add initial position if it's the first one
        setState(() {
          _routeCoordinates.add(newPosition);
        });
      }

      setState(() {
        _currentPosition = newPosition;
      });

      _controller?.animateCamera(CameraUpdate.newLatLng(newPosition));
    });
  }

  // Checks if the current position is near any of the predefined stations
  bool _checkProximityToStations(LatLng position) {
    for (var station in _stations) {
      if (Geolocator.distanceBetween(position.latitude, position.longitude,
              station.latitude, station.longitude) <=
          _stationRadius) {
        return true;
      }
    }
    return false;
  }

  // Initiates the end ride process with the backend
  void _endRide() async {
    // Ensure we have a current position to send as final location
    if (_currentPosition == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Cannot end ride: Current location not available.")),
      );
      return;
    }

    // Check proximity again just before ending
    if (!_isNearStation) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("You can only end your ride near a station.")),
      );
      return;
    }

    setState(() {
      _isLoadingEndRide = true;
      _endRideError = null;
    });

    try {
      final rideEndDetails = await _rideService.endRide(
        rideId: widget.rideId,
        finalLatitude: _currentPosition!.latitude,
        finalLongitude: _currentPosition!.longitude,
      );

      setState(() {
        _isLoadingEndRide = false;
      });

      // Navigate to payment screen, potentially passing rideEndDetails
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => PaymentScreen(rideDetails: rideEndDetails)),
      );
    } catch (e) {
      setState(() {
        _endRideError = e.toString().contains('Exception:')
            ? e.toString().split('Exception: ')[1]
            : e.toString();
        _isLoadingEndRide = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to end ride: ${_endRideError!}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _currentPosition ??
                  _stations[
                      0], // Use current position or first station as fallback
              zoom: 15,
            ),
            markers: {
              // Add a marker for the current position
              if (_currentPosition != null)
                Marker(
                  markerId: const MarkerId('currentPosition'),
                  position: _currentPosition!,
                  icon: BitmapDescriptor.defaultMarkerWithHue(
                      BitmapDescriptor.hueAzure),
                  infoWindow: const InfoWindow(title: 'Your Location'),
                ),
              // Markers for all stations (re-added for visibility)
              ..._stations
                  .map((station) => Marker(
                        markerId: MarkerId(station.toString()),
                        position: station,
                        icon: BitmapDescriptor.defaultMarkerWithHue(
                            BitmapDescriptor.hueGreen),
                        infoWindow: InfoWindow(
                            title:
                                'Station ${station.latitude.toStringAsFixed(2)}, ${station.longitude.toStringAsFixed(2)}'),
                      ))
                  .toSet(),
            },
            polylines: {
              Polyline(
                polylineId: const PolylineId("route"),
                points: _routeCoordinates,
                color: Colors.blue,
                width: 5,
              ),
            },
            myLocationEnabled: true, // Show the blue dot on map
            myLocationButtonEnabled:
                false, // Hide built-in button, use custom if needed
            zoomControlsEnabled: false,
            onMapCreated: (GoogleMapController controller) {
              _controller = controller;
              // Animate camera to current position if available on map creation
              if (_currentPosition != null) {
                _controller?.animateCamera(
                    CameraUpdate.newLatLngZoom(_currentPosition!, 15));
              }
            },
          ),
          Positioned(
            top: 40,
            left: 20,
            child: Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: const [
                        BoxShadow(color: Colors.grey, blurRadius: 4)
                      ]),
                  child: IconButton(
                    onPressed: () {
                      // Logic for exiting ride screen - typically not allowed mid-ride without ending it
                      // You might show a dialog asking to end ride first
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text("Please end your ride first.")),
                      );
                    },
                    icon: const Icon(FontAwesomeIcons.arrowLeft),
                  ),
                ),
                const SizedBox(
                  width: 20,
                ),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(10)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Bike ID: ${widget.bikeId}",
                          style: const TextStyle(color: Colors.white)),
                      Text(
                          "Distance: ${_distanceTraveled.toStringAsFixed(2)} m",
                          style: const TextStyle(color: Colors.white)),
                      Text(
                          _isNearStation
                              ? "You can end the ride"
                              : "Ride must end near a station",
                          style: const TextStyle(color: Colors.yellow)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 30,
            left: 20,
            right: 20,
            child: ElevatedButton(
              onPressed: _isNearStation && !_isLoadingEndRide
                  ? _endRide
                  : null, // Enable only if near station and not loading
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 15),
                backgroundColor: _isNearStation
                    ? Colors.blueAccent
                    : Colors.grey, // Grey out if disabled
              ),
              child: _isLoadingEndRide
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text(
                      "End Ride",
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16),
                    ),
            ),
          ),
          // Error display for ending ride
          if (_endRideError != null)
            Positioned(
              top: 120, // Adjust position as needed
              left: 20,
              right: 20,
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Error ending ride: $_endRideError',
                  style: const TextStyle(color: Colors.white),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
