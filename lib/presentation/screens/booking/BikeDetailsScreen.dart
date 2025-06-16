import 'package:flutter/material.dart';
import 'package:revobike/data/models/Bike.dart' as bike_model;
import 'package:revobike/data/models/Station.dart' as station_model;

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
      body: Center(
        child: Text('Details for bike ${selectedBike.bikeId}'),
      ),
    );
  }
}
