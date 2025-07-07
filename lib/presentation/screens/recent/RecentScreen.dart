import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:revobike/constants/app_colors.dart';
import 'package:revobike/api/ride_service.dart'; // Import your RideService
import 'package:revobike/api/auth_service.dart'; // Import your AuthService

// If your Ride and Location models are in separate files like data/models/ride.dart
// and data/models/location.dart, uncomment/add these imports:
// import 'package:revobike/data/models/Ride.dart';
// import 'package:revobike/data/models/Location.dart';

class RecentTripsScreen extends StatefulWidget {
  const RecentTripsScreen({super.key});

  @override
  State<RecentTripsScreen> createState() => _RecentTripsScreenState();
}

class _RecentTripsScreenState extends State<RecentTripsScreen> {
  final AuthService _authService = AuthService();
  late final RideService _rideService;

  late Future<List<Ride>> _rideHistoryFuture; // Future to hold API response

  @override
  void initState() {
    super.initState();
    _rideService = RideService(authService: _authService);
    _rideHistoryFuture = _fetchRideHistory(); // Start fetching data
  }

  // Method to fetch ride history from the API
  Future<List<Ride>> _fetchRideHistory() async {
    try {
      // Call the getRideHistory method from your RideService
      final rideDataList = await _rideService.getRideHistory();
      // Map the list of dynamic maps to a list of Ride objects
      return rideDataList.map((rideData) => Ride.fromJson(rideData)).toList();
    } catch (e) {
      // Re-throw the exception to be caught by the FutureBuilder's error snapshot
      throw Exception('Failed to load ride history: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Ride>>(
      future: _rideHistoryFuture, // Provide the future here
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // Show a loading indicator while data is being fetched
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          // Show an error message if fetching data failed
          return Center(
              child: Text('Error: ${snapshot.error}',
                  style: const TextStyle(color: Colors.red)));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          // Show a message if no rides are found
          return const Center(
              child: Text('No recent rides found.',
                  style: TextStyle(fontSize: 16, color: Colors.grey)));
        } else {
          // Data is successfully fetched, display the list of rides
          final rides = snapshot.data!;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 24),
                const Text("Recent Trips",
                    style:
                        TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                _sectionTitle("Ride History"), // Unified title for all trips
                // Dynamically generate _rideCard widgets for each fetched ride
                ...rides.map((ride) => _rideCard(ride)).toList(),
                const SizedBox(height: 64),
              ],
            ),
          );
        }
      },
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
    );
  }

  // Updated _rideCard to accept a Ride object
  Widget _rideCard(Ride ride) {
    final isActive = ride.status.toLowerCase() == 'active';
    // Use the actual startLocation from the ride object
    final locationText = ride.startLocation != null
        ? 'Lat: ${ride.startLocation!.lat.toStringAsFixed(4)}, Lng: ${ride.startLocation!.lng.toStringAsFixed(4)}'
        : 'Unknown location';
    final statusText = isActive ? 'In Progress' : 'Completed';
    // duration and fare are not in the provided API response, so they remain empty
    final durationText = '';
    final fareText = '';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 4)
          ]),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // FIX: Wrapped Column with Expanded to resolve ParentDataWidget error
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(locationText,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(statusText,
                      style: TextStyle(
                          fontSize: 14,
                          color:
                              isActive ? Colors.red : AppColors.primaryGreen)),
                  // Only show duration/fare if they are not empty (i.e., if your API provides them later)
                  if (durationText.isNotEmpty || fareText.isNotEmpty)
                    Text("$durationText - $fareText",
                        style: const TextStyle(
                            fontSize: 14, color: Colors.black54)),
                ],
              ),
            ),
            // The action button/icon based on ride status
            isActive
                ? ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                    onPressed: () {
                      // TODO: Implement finish ride functionality for this specific ride (using ride.id)
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text('Finish ride for ID: ${ride.id}')),
                      );
                    },
                    child: const Text("Finish Ride"),
                  )
                : const Icon(FontAwesomeIcons.circleCheck,
                    color: Colors.green, size: 24),
          ],
        ),
      ),
    );
  }
}

// Your Ride and Location models based on the provided JSON structure
// You should ensure these are in data/models/ride.dart and data/models/location.dart
// respectively and imported, or keep them directly in this file if they are only used here.
class Ride {
  final String id;
  final String user;
  final String bike;
  final Location? startLocation; // Nullable if not always present
  final String status;

  Ride({
    required this.id,
    required this.user,
    required this.bike,
    this.startLocation,
    required this.status,
  });

  factory Ride.fromJson(Map<String, dynamic> json) {
    return Ride(
      id: json['id'] as String,
      user: json['user'] as String,
      bike: json['bike'] as String,
      startLocation: json['startLocation'] != null
          ? Location.fromJson(json['startLocation'])
          : null,
      status: json['status'] as String,
    );
  }
}

class Location {
  final double lat;
  final double lng;

  Location({required this.lat, required this.lng});

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      lat: (json['lat'] as num).toDouble(),
      lng: (json['lng'] as num).toDouble(),
    );
  }
}
