import 'package:equatable/equatable.dart';

class BikeModel extends Equatable {
  final String bikeId;
  final int? batteryLevel; // Percentage 0-100
  final String? model;
  final double? maxRangeKm; // Max range a new, full-battery bike can travel
  final String status;

  BikeModel({
    required this.bikeId,
    this.batteryLevel,
    this.model,
    this.maxRangeKm,
    this.status = 'available',
  });

  factory BikeModel.fromJson(Map<String, dynamic> json) {
    return BikeModel(
      bikeId: json['bikeId'],
      batteryLevel: json['batteryLevel'] != null ? int.tryParse(json['batteryLevel'].toString()) : null,
      model: json['model'],
      maxRangeKm: json['maxRangeKm'] != null ? double.tryParse(json['maxRangeKm'].toString()) : null,
      status: json['status'] ?? 'available',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'bikeId': bikeId,
      'batteryLevel': batteryLevel,
      'model': model,
      'maxRangeKm': maxRangeKm,
      'status': status,
    };
  }

  @override
  List<Object?> get props => [bikeId, batteryLevel, model, maxRangeKm, status];
}
