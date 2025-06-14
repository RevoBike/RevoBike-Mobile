import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:revobike/data/models/Station.dart'; // Ensure this is the updated model
import 'package:revobike/presentation/screens/booking/BookingConfirmationScreen.dart';

class StationDetailsScreen extends StatelessWidget {
  final Station station;

  const StationDetailsScreen({super.key, required this.station});

  @override
  Widget build(BuildContext context) {
    // Find the first available bike ID for the "Book" button
    final String? firstAvailableBikeId = station.availableBikes.isNotEmpty
        ? station.availableBikes.first.bikeId
        : null;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 250,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage("assets/images/station.png"),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(station.name,
                          style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.black)),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.location_on,
                              color: Colors.grey, size: 18),
                          const SizedBox(width: 4),
                          // Use station.address for specific address if available, fallback to name
                          Text(station.address ?? station.name,
                              style: TextStyle(
                                  fontSize: 14, color: Colors.grey.shade700)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.phone, color: Colors.blue, size: 18),
                              SizedBox(width: 4),
                              Text(
                                  "+251989341234", // This is hardcoded; consider making it dynamic from station.contact or similar
                                  style: TextStyle(
                                      fontSize: 14, color: Colors.blue)),
                            ],
                          ),
                          Row(
                            children: [
                              Icon(Icons.star, color: Colors.orange, size: 18),
                              SizedBox(width: 4),
                              Text(
                                  "4.7 (83 Reviews)", // This is hardcoded; consider making it dynamic
                                  style: TextStyle(
                                      fontSize: 14, color: Colors.black87)),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          // Use .length for availableBikes as it's a List<BikeModel>
                          _infoCard("${station.availableBikes.length}",
                              "Available Bikes"),
                          // Safely display rate with a fallback if null
                          _infoCard(
                              "Br.${station.rate?.toStringAsFixed(2) ?? 'N/A'}/KM",
                              "Price"),
                          _infoCard("2 hrs",
                              "Maximum Time"), // This is hardcoded; consider making it dynamic
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: Colors.blue,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    side: const BorderSide(
                                        color: Colors.blueAccent, width: 1)),
                              ),
                              onPressed: () {
                                // Add logic for Get Direction here, e.g., launching maps app
                                // Use station.location.coordinates[1] for latitude, [0] for longitude
                                // Example:
                                // final Uri googleMapsUrl = Uri.parse(
                                //     'https://www.google.com/maps/dir/?api=1&destination=${station.location.coordinates[1]},${station.location.coordinates[0]}');
                                // if (await canLaunchUrl(googleMapsUrl)) {
                                //   await launchUrl(googleMapsUrl);
                                // } else {
                                //   ScaffoldMessenger.of(context).showSnackBar(
                                //       const SnackBar(content: Text('Could not launch map.')));
                                // }
                              },
                              child: const Text("Get Direction"),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8)),
                              ),
                              // Enable/disable based on status AND available bikes
                              onPressed:
                                  station.status?.toLowerCase() == "open" &&
                                          firstAvailableBikeId != null
                                      ? () {
                                          Navigator.of(context).push(
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      BookingConfirmationScreen(
                                                        station: station,
                                                        selectedBikeId:
                                                            firstAvailableBikeId, // Pass the first available bike ID
                                                      )));
                                        }
                                      : () {
                                          // Show snackbar if no bikes or not open
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                firstAvailableBikeId == null
                                                    ? 'No bikes available at this station.'
                                                    : 'This station is currently ${station.status ?? 'closed'}.',
                                              ),
                                            ),
                                          );
                                        },
                              child: Text(
                                firstAvailableBikeId == null
                                    ? "No Bikes"
                                    : "Book",
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 18),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Text("About",
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      // Consider using station.description if your API provides it
                      const Text(
                        "This station is strategically located to provide convenient access to bikes for commuters and visitors. It features state-of-the-art security and easy-to-use booking system for a seamless experience.", // Example description, replace with dynamic data if available
                        style: TextStyle(fontSize: 14, color: Colors.black54),
                      ),
                      const SizedBox(height: 16),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: SizedBox(
                          height: 200,
                          child: GoogleMap(
                            initialCameraPosition: CameraPosition(
                              // Access coordinates from the nested location object
                              target: LatLng(station.location.coordinates[1],
                                  station.location.coordinates[0]),
                              zoom: 14,
                            ),
                            markers: {
                              Marker(
                                markerId: MarkerId(station.id),
                                // Access coordinates from the nested location object
                                position: LatLng(
                                    station.location.coordinates[1],
                                    station.location.coordinates[0]),
                                infoWindow: InfoWindow(
                                  title: station.name,
                                  snippet:
                                      'Available: ${station.availableBikes.length}',
                                ),
                              ),
                            },
                            zoomControlsEnabled: false, // Hide zoom controls
                            myLocationButtonEnabled:
                                false, // Hide my location button
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: 25,
            left: 20,
            child: Container(
              width: 45,
              height: 45,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: IconButton(
                icon: const Icon(FontAwesomeIcons.arrowLeft, size: 20),
                color: Colors.black,
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoCard(String title, String subtitle) {
    return Column(
      children: [
        Text(title,
            style: const TextStyle(
                fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blue)),
        const SizedBox(height: 4),
        Text(subtitle,
            style: const TextStyle(fontSize: 12, color: Colors.black54)),
      ],
    );
  }
}
