import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:revobike/data/models/Bike.dart' as bike_model;
import 'package:revobike/data/models/Station.dart' as station_model;
import 'package:revobike/presentation/screens/booking/BookingConfirmationScreen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class BikeDetailsScreen extends StatefulWidget {
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
  State<BikeDetailsScreen> createState() => _BikeDetailsScreenState();
}

class _BikeDetailsScreenState extends State<BikeDetailsScreen> {
  final Completer<GoogleMapController> _controller = Completer();

  static const double _defaultZoom = 14.0;

  late LatLng _startLatLng;
  late LatLng _endLatLng;

  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};
  List<LatLng> polylineCoordinates = [];

  final String _googleApiKey =
      'YOUR_GOOGLE_MAPS_API_KEY'; // Replace or use existing key management

  @override
  void initState() {
    super.initState();
    _startLatLng = LatLng(
      widget.startStation.location.coordinates[1],
      widget.startStation.location.coordinates[0],
    );
    _endLatLng = LatLng(
      widget.endStation.location.coordinates[1],
      widget.endStation.location.coordinates[0],
    );
    _setMarkers();
    _getRoutePolyline();
  }

  void _setMarkers() {
    _markers.add(
      Marker(
        markerId: MarkerId('startStation'),
        position: _startLatLng,
        infoWindow: InfoWindow(title: widget.startStation.name),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
      ),
    );
    _markers.add(
      Marker(
        markerId: MarkerId('endStation'),
        position: _endLatLng,
        infoWindow: InfoWindow(title: widget.endStation.name),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      ),
    );
  }

  Future<void> _getRoutePolyline() async {
    final String url =
        'https://maps.googleapis.com/maps/api/directions/json?origin=${_startLatLng.latitude},${_startLatLng.longitude}&destination=${_endLatLng.latitude},${_endLatLng.longitude}&mode=bicycling&key=$_googleApiKey';

    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      if ((data['routes'] as List).isNotEmpty) {
        final String encodedPolyline =
            data['routes'][0]['overview_polyline']['points'];
        _decodePolyline(encodedPolyline);
      }
    } else {
      // Handle error or show message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Failed to load route: ${response.reasonPhrase}')),
      );
    }
  }

  void _decodePolyline(String encoded) {
    PolylinePoints polylinePoints = PolylinePoints();
    List<PointLatLng> result = polylinePoints.decodePolyline(encoded);
    polylineCoordinates.clear();
    if (result.isNotEmpty) {
      for (var point in result) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      }
      setState(() {
        _polylines.add(
          Polyline(
            polylineId: PolylineId('route'),
            color: Colors.blue,
            width: 5,
            points: polylineCoordinates,
          ),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    CameraPosition initialCameraPosition = CameraPosition(
      target: _startLatLng,
      zoom: _defaultZoom,
    );

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
              'Bike ID: ${widget.selectedBike.bikeId}',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              'Battery Life: ${widget.selectedBike.batteryLevel ?? 'N/A'}%',
              style: TextStyle(
                fontSize: 16,
                color: widget.isBatterySufficient ? Colors.green : Colors.red,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              'Model: ${widget.selectedBike.model ?? 'Standard'}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 10),
            Text(
              'Distance to destination: ${widget.distanceToDestinationKm.toStringAsFixed(2)} km',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: GoogleMap(
                initialCameraPosition: initialCameraPosition,
                markers: _markers,
                polylines: _polylines,
                onMapCreated: (GoogleMapController controller) {
                  _controller.complete(controller);
                },
                myLocationButtonEnabled: false,
                zoomControlsEnabled: true,
              ),
            ),
            const SizedBox(height: 10),
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
                          station: widget.startStation,
                          selectedBikeId: widget.selectedBike.bikeId,
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
