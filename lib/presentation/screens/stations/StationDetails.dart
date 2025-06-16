import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_svg/flutter_svg.dart'; // Import flutter_svg
import 'package:revobike/data/models/Station.dart' as station_model;
import 'package:revobike/data/models/Bike.dart' as bike_model;
import 'package:revobike/presentation/screens/booking/BikeDetailsScreen.dart'
    as bike_details_screen;
import 'package:revobike/utils/location_utils.dart'; // Ensure this file exists and has calculateDistance
// Removed redundant dart:math as LocationUtils should encapsulate math if needed

import 'package:revobike/presentation/widget/CustomAppBar.dart'; // Import CustomAppBar
import 'package:revobike/constants/app_colors.dart';

class StationDetailsScreen extends StatefulWidget {
  final station_model.Station startStation;
  final station_model.Station endStation;

  const StationDetailsScreen({
    super.key,
    required this.startStation,
    required this.endStation,
  });

  @override
  State<StationDetailsScreen> createState() => _StationDetailsScreenState();
}

class _StationDetailsScreenState extends State<StationDetailsScreen> {
  List<bike_model.BikeModel> _availableBikes = [];
  bool _isLoadingBikes = true;
  String? _errorLoadingBikes;
  double _distanceToDestinationKm = 0.0;

  @override
  void initState() {
    super.initState();
    _loadStationDetails();
  }

  Future<void> _loadStationDetails() async {
    setState(() {
      _isLoadingBikes = true;
      _errorLoadingBikes = null;
    });

    try {
      _availableBikes = List.from(
          widget.startStation.availableBikes.cast<bike_model.BikeModel>());

      _distanceToDestinationKm = LocationUtils.calculateDistance(
        widget.startStation.location.coordinates[1], // Latitude
        widget.startStation.location.coordinates[0], // Longitude
        widget.endStation.location.coordinates[1], // Latitude
        widget.endStation.location.coordinates[0], // Longitude
      );

      setState(() {
        _isLoadingBikes = false;
      });
    } catch (e) {
      setState(() {
        _errorLoadingBikes = e.toString();
        _isLoadingBikes = false;
      });
    }
  }

  bool _isBatterySufficient(bike_model.BikeModel bike, double distanceKm) {
    if (bike.batteryLevel == null || bike.batteryLevel! <= 0) {
      return false;
    }
    // Assuming BikeModel has a 'maxRangeKm' property or a default is defined
    // If your BikeModel doesn't have maxRangeKm, you'll need a default here.
    final double maxRangeKm =
        bike.maxRangeKm ?? 50.0; // Example default max range

    final double estimatedRangeKm = (bike.batteryLevel! / 100.0) * maxRangeKm;
    final double requiredRangeWithBuffer = distanceKm * 1.1; // 10% buffer

    return estimatedRangeKm >= requiredRangeWithBuffer;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      extendBodyBehindAppBar:
          true, // Crucial: Allows body content to go behind the AppBar
      appBar: const CustomAppBar(), // Use your CustomAppBar here
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image container - now using SvgPicture.asset as child directly
            SizedBox(
              height: 250, // Fixed height for the image section
              width: double.infinity, // Ensures it takes full width
              // No decoration image; SvgPicture is the direct child
              child: SvgPicture.asset(
                "assets/images/bike_parking.svg", // Use your SVG asset path
                fit: BoxFit.cover, // Ensures the SVG covers the container
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.startStation.name,
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
                      Text(
                          widget.startStation.address ??
                              widget.startStation.name,
                          style: TextStyle(
                              fontSize: 14, color: Colors.grey.shade700)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _infoCard("${widget.startStation.availableBikes.length}",
                          "Bikes at Station"),
                      _infoCard(
                          "${_distanceToDestinationKm.toStringAsFixed(1)} KM",
                          "Trip Distance"),
                      _infoCard(
                          "Br.${widget.startStation.rate?.toStringAsFixed(2) ?? 'N/A'}/KM",
                          "Rate"),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text("Available Bikes",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),

                  _isLoadingBikes
                      ? const Center(child: CircularProgressIndicator())
                      : _errorLoadingBikes != null
                          ? Center(
                              child: Text(
                                  'Error loading bikes: ${_errorLoadingBikes!}'),
                            )
                          : _availableBikes.isEmpty
                              ? const Center(
                                  child: Text(
                                    'No bikes found at this station.',
                                    style: TextStyle(
                                        fontSize: 16, color: Colors.grey),
                                  ),
                                )
                              : ListView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: _availableBikes.length,
                                  itemBuilder: (context, index) {
                                    final bike = _availableBikes[index];
                                    final bool isSufficient =
                                        _isBatterySufficient(
                                            bike, _distanceToDestinationKm);

                                    return Card(
                                      margin: const EdgeInsets.only(bottom: 10),
                                      elevation: 2,
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10)),
                                      child: ListTile(
                                        leading: Icon(
                                          FontAwesomeIcons.bicycle,
                                          color: isSufficient
                                              ? AppColors.primaryGreen
                                              : Colors.red,
                                        ),
                                        title: Text('Bike ID: ${bike.bikeId}',
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold)),
                                        subtitle: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Battery: ${bike.batteryLevel ?? 'N/A'}%',
                                              style: TextStyle(
                                                color: isSufficient
                                                    ? Colors.green
                                                    : Colors.orange,
                                              ),
                                            ),
                                            Text(
                                                'Model: ${bike.model ?? 'Standard'}'),
                                            Text(
                                              isSufficient
                                                  ? 'Sufficient for trip'
                                                  : 'Insufficient battery for trip',
                                              style: TextStyle(
                                                color: isSufficient
                                                    ? Colors.green.shade700
                                                    : Colors.red,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                        trailing: const Icon(
                                            Icons.arrow_forward_ios,
                                            size: 16),
                                        onTap: () {
                                          Navigator.of(context).push(
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  bike_details_screen
                                                      .BikeDetailsScreen(
                                                selectedBike: bike,
                                                startStation:
                                                    widget.startStation,
                                                endStation: widget.endStation,
                                                isBatterySufficient:
                                                    isSufficient,
                                                distanceToDestinationKm:
                                                    _distanceToDestinationKm,
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    );
                                  },
                                ),
                  const SizedBox(height: 16),
                  // Removed old GoogleMap widget
                ],
              ),
            ),
          ],
        ),
      ),
      // Removed the redundant Positioned back button, as CustomAppBar handles it
    );
  }

  Widget _infoCard(String title, String subtitle) {
    return Column(
      children: [
        Text(title,
            style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryGreen)),
        const SizedBox(height: 4),
        Text(subtitle,
            style: const TextStyle(fontSize: 12, color: Colors.black54)),
      ],
    );
  }
}
