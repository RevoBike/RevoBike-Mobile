import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:revobike/api/station_service.dart';
import 'package:revobike/data/models/Station.dart'; // Ensure this is the updated model
import 'package:revobike/presentation/screens/booking/BookingConfirmationScreen.dart';
import 'package:revobike/presentation/screens/stations/StationDetails.dart';
import 'package:revobike/api/api_constants.dart'; // Import ApiConstants

class StationScreen extends StatefulWidget {
  const StationScreen({super.key});

  @override
  State<StationScreen> createState() => _StationScreenState();
}

class _StationScreenState extends State<StationScreen> {
  // Initialize StationService without baseUrl parameter, as it uses ApiConstants directly
  final StationService _stationService = StationService();
  List<Station> _stations = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchStations();
  }

  Future<void> _fetchStations() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final stations = await _stationService.getStations();

      setState(() {
        _stations = stations;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString().contains('Exception:')
            ? e.toString().split('Exception: ')[1]
            : e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Error: $_error',
              style: const TextStyle(color: Colors.red),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _fetchStations,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_stations.isEmpty) {
      return const Center(
        child: Text(
          'No stations available at the moment.',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView.builder(
          itemCount: _stations.length,
          itemBuilder: (context, index) {
            final station = _stations[index];
            // Get the first available bike ID for the "Book" button
            final String? firstAvailableBikeId =
                station.availableBikes.isNotEmpty
                    ? station.availableBikes.first.bikeId
                    : null;

            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          station.name,
                          style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Icon(
                        station.status?.toLowerCase() == "open"
                            ? FontAwesomeIcons.circleCheck
                            : FontAwesomeIcons.circleXmark,
                        color: station.status?.toLowerCase() == "open"
                            ? Colors.green
                            : Colors.red,
                        size: 18,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(
                        FontAwesomeIcons.locationDot,
                        size: 16,
                        color: Colors.blue,
                      ),
                      const SizedBox(width: 8),
                      // Use station.address for location display
                      Text(
                          station.address ??
                              station.name, // Prefer address, fallback to name
                          style: const TextStyle(
                              fontSize: 14, color: Colors.grey)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(FontAwesomeIcons.bicycle,
                          size: 16, color: Colors.blue),
                      const SizedBox(width: 8),
                      // Use .length for availableBikes as it's a List<BikeModel>
                      Text("${station.availableBikes.length} Bikes Available",
                          style: const TextStyle(
                              fontSize: 14, color: Colors.blueGrey)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(FontAwesomeIcons.route,
                          size: 16, color: Colors.blue),
                      const SizedBox(width: 8),
                      // Access coordinates from the nested location object
                      Text(
                          "${station.location.coordinates[1].toStringAsFixed(2)}, ${station.location.coordinates[0].toStringAsFixed(2)}",
                          style: const TextStyle(
                              fontSize: 14, color: Colors.blueGrey)),
                      const Spacer(),
                      const Icon(FontAwesomeIcons.dollarSign,
                          size: 16, color: Colors.blue),
                      const SizedBox(width: 8),
                      // Safely display rate with a fallback if null
                      Text("Br.${station.rate?.toStringAsFixed(2) ?? 'N/A'}/km",
                          style: const TextStyle(
                              fontSize: 14, color: Colors.blueGrey)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) =>
                                  StationDetailsScreen(station: station),
                            ));
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                                side: const BorderSide(
                                  color: Colors.blue,
                                  width: 1.0,
                                )),
                          ),
                          child: const Text("View",
                              style: TextStyle(
                                  color: Colors.blue,
                                  fontWeight: FontWeight.bold)),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton(
                          // Enable/disable based on status AND available bikes
                          onPressed: station.status?.toLowerCase() == "open" &&
                                  firstAvailableBikeId != null
                              ? () => Navigator.of(context).push(
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          BookingConfirmationScreen(
                                            station: station,
                                            selectedBikeId:
                                                firstAvailableBikeId, // Pass the first available bike ID
                                          )))
                              : () {
                                  // Show snackbar if no bikes or not open
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        firstAvailableBikeId == null
                                            ? 'No bikes available at this station.'
                                            : 'This station is currently ${station.status ?? 'closed'}.',
                                      ),
                                    ),
                                  );
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                station.status?.toLowerCase() == "open" &&
                                        firstAvailableBikeId != null
                                    ? Colors.blue
                                    : Colors.grey,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                          ),
                          child: Text(
                            firstAvailableBikeId == null ? "No Bikes" : "Book",
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
