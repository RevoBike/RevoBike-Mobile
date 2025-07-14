import 'package:equatable/equatable.dart';
import 'package:revobike/data/models/Bike.dart'
    as bike_model; // Using alias as per your code

// Represents the nested 'location' object from your backend API response
class LocationData extends Equatable {
  final String type;
  final List<double> coordinates; // Backend sends [longitude, latitude]

  const LocationData({
    required this.type,
    required this.coordinates,
  });

  factory LocationData.fromJson(Map<String, dynamic> json) {
    return LocationData(
      type: json['type'] as String,
      // Ensure coordinates are cast to List<double>
      coordinates: (json['coordinates'] as List<dynamic>)
          .map((e) => e as double)
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'coordinates': coordinates,
    };
  }

  @override
  List<Object?> get props => [type, coordinates];
}

class Station extends Equatable {
  final String id; // Maps to backend's '_id' for the station
  final String name;
  final LocationData location; // Nested LocationData object
  final int totalSlots;
  final List<bike_model.BikeModel> availableBikes; // Using bike_model.BikeModel
  final String? address; // NEW: Added address field
  final String status; // Not nullable in constructor, with default
  final double? rate; // Added rate, made nullable

  const Station({
    required this.id,
    required this.name,
    required this.location,
    required this.totalSlots,
    required this.availableBikes,
    this.address, // Added to constructor
    this.status = 'Unknown', // Default status if not provided by API
    this.rate,
  });

  factory Station.fromJson(Map<String, dynamic> json) {
    // Parse the list of bike objects into a List<bike_model.BikeModel>
    final List<bike_model.BikeModel> bikes = (json['available_bikes']
                as List<dynamic>?)
            ?.map(
                (e) => bike_model.BikeModel.fromJson(e as Map<String, dynamic>))
            .toList() ??
        []; // Handle case where 'available_bikes' might be null or empty

    return Station(
      id: json['_id'] as String, // Correctly parse '_id' from backend
      name: json['name'] as String,
      location: LocationData.fromJson(
          json['location'] as Map<String, dynamic>), // Parse nested 'location'
      totalSlots: json['totalSlots'] as int,
      availableBikes: bikes
          .where((bike) => bike.status == 'available')
          .toList(), // Filter for 'available' bikes
      address: json['address'] as String?, // Safely parse address
      status: json['status'] as String? ??
          'Open', // Default to 'Open' if not provided
      rate: (json['rate'] as num?)
          ?.toDouble(), // Safely parse double, can be null
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      '_id': id,
      'name': name,
      'location': location.toJson(), // Convert nested LocationData to JSON
      'totalSlots': totalSlots,
      'available_bikes': availableBikes
          .map((e) => e.toJson())
          .toList(), // Convert BikeModel list to JSON
      'status': status,
    };
    if (address != null) {
      data['address'] = address; // Include address if not null
    }
    if (rate != null) data['rate'] = rate; // Include rate if not null
    return data;
  }

  @override
  List<Object?> get props => [
        id,
        name,
        location,
        totalSlots,
        availableBikes,
        address, // Include address in props
        status,
        rate,
      ];
}
