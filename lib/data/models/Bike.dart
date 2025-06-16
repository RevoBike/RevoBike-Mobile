class BikeModel {
  final String bikeId;
  final int? batteryLevel; // Percentage 0-100
  final String? model;
  final double? maxRangeKm; // Max range a new, full-battery bike can travel

  BikeModel({
    required this.bikeId,
    this.batteryLevel,
    this.model,
    this.maxRangeKm,
  });

  factory BikeModel.fromJson(Map<String, dynamic> json) {
    return BikeModel(
      bikeId: json['bikeId'],
      batteryLevel: json['batteryLevel'] != null ? int.tryParse(json['batteryLevel'].toString()) : null,
      model: json['model'],
      maxRangeKm: json['maxRangeKm'] != null ? double.tryParse(json['maxRangeKm'].toString()) : null,
    );
  }
}
