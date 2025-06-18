import 'Location.dart';

class Ride {
  final String id;
  final String user;
  final String bike;
  final Location? startLocation;
  final String status;
  // Add other fields from your API response if needed, e.g., fare, duration, endLocation

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
