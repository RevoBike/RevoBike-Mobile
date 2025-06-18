import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:revobike/data/models/Bike.dart' as bike_model;
import 'package:revobike/data/models/Station.dart' as station_model;
import 'package:revobike/presentation/screens/booking/BookingConfirmationScreen.dart';

class BikeDetailsScreen extends StatelessWidget {
  final bike_model.BikeModel selectedBike;
  final station_model.Station startStation;
  final station_model.Station endStation;
  final bool isBatterySufficient;
  final double distanceToDestinationKm;

  const BikeDetailsScreen({
    super.key,
    required this.selectedBike,
    required this.startStation,
    required this.endStation,
    required this.isBatterySufficient,
    required this.distanceToDestinationKm,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bike Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            SvgPicture.asset(
              'assets/images/bike.svg',
              height: 200,
              width: double.infinity,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 20),
            Text(
              'Bike ID: ${selectedBike.bikeId}',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              'Battery Life: ${selectedBike.batteryLevel ?? 'N/A'}%',
              style: TextStyle(
                fontSize: 16,
                color: isBatterySufficient ? Colors.green : Colors.red,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              'Model: ${selectedBike.model ?? 'Standard'}',
              style: const TextStyle(fontSize: 16),
            ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey,
                  ),
                  child: const Text('Back'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => BookingConfirmationScreen(
                          station: startStation,
                          selectedBikeId: selectedBike.bikeId,
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                  child: const Text('Book Now'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
