import 'package:equatable/equatable.dart';

class Station extends Equatable {
  final String id;
  final String name;
  final String location;
  final int availableBikes;
  final double latitude;
  final double longitude;
  final String status;
  final double rate;

  const Station({
    required this.id,
    required this.name,
    required this.location,
    required this.availableBikes,
    required this.latitude,
    required this.longitude,
    required this.status,
    required this.rate,
  });

  factory Station.fromJson(Map<String, dynamic> json) {
    // Extract coordinates from the location object
    final location = json['location'] as Map<String, dynamic>;
    final coordinates = location['coordinates'] as List<dynamic>;

    // Count available bikes
    final availableBikes = (json['available_bikes'] as List<dynamic>)
        .where((bike) => bike['status'] == 'available')
        .length;

    return Station(
      id: json['_id'] as String,
      name: json['name'] as String,
      location: json['name'] as String, // Using name as location for now
      availableBikes: availableBikes,
      latitude: coordinates[1]
          as double, // Note: coordinates are [longitude, latitude]
      longitude: coordinates[0] as double,
      status: 'open', // Default status
      rate: 2.5, // Default rate
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'location': location,
      'availableBikes': availableBikes,
      'latitude': latitude,
      'longitude': longitude,
      'status': status,
      'rate': rate,
    };
  }

  @override
  List<Object?> get props => [
        id,
        name,
        location,
        availableBikes,
        latitude,
        longitude,
        status,
        rate,
      ];
}
