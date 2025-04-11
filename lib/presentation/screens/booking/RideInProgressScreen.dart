import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'dart:math';

class RideInProgressScreen extends StatefulWidget {
  const RideInProgressScreen({super.key});

  @override
  _RideInProgressScreenState createState() => _RideInProgressScreenState();
}

class _RideInProgressScreenState extends State<RideInProgressScreen> {
  GoogleMapController? _controller;
  final Location _location = Location();
  LatLng? _currentPosition;
  final List<LatLng> _routeCoordinates = [];
  double _distanceTraveled = 0.0;
  bool _isNearStation = false;
  final double _stationRadius = 100.0;
  late bool _isLoading = false;

  final List<LatLng> _stations = [
    const LatLng(9.0069631, 38.7622717),
    const LatLng(9.0016631, 38.723503),
    const LatLng(8.9812889, 38.7596757),
  ];

  @override
  void initState() {
    super.initState();
    _startTracking();
  }

  void _startTracking() {
    _location.onLocationChanged.listen((LocationData currentLocation) {
      if (currentLocation.latitude == null || currentLocation.longitude == null) return;
      LatLng newPosition = LatLng(currentLocation.latitude!, currentLocation.longitude!);

      if (_currentPosition != null) {
        double distance = _calculateDistance(_currentPosition!, newPosition);
        setState(() {
          _distanceTraveled += distance;
          _routeCoordinates.add(newPosition);
          _isNearStation = _checkProximityToStations(newPosition);
        });
      }

      setState(() {
        _currentPosition = newPosition;
      });

      _controller?.animateCamera(CameraUpdate.newLatLng(newPosition));
    });
  }

  bool _checkProximityToStations(LatLng position) {
    for (var station in _stations) {
      if (_calculateDistance(position, station) <= _stationRadius) {
        return true;
      }
    }
    return false;
  }

  double _calculateDistance(LatLng start, LatLng end) {
    const double earthRadius = 6371000;
    double dLat = _degreesToRadians(end.latitude - start.latitude);
    double dLng = _degreesToRadians(end.longitude - start.longitude);
    double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_degreesToRadians(start.latitude)) * cos(_degreesToRadians(end.latitude)) *
            sin(dLng / 2) * sin(dLng / 2);
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadius * c;
  }

  double _degreesToRadians(double degrees) {
    return degrees * pi / 180;
  }

  void _endRide() {
    LatLng lastLocation = _routeCoordinates.isNotEmpty ? _routeCoordinates.last : const LatLng(0, 0);
    bool nearStation = _stations.any((station) => _calculateDistance(lastLocation, station) < 0.2);

    if (nearStation) {
      setState(() => _isLoading = true);
      Future.delayed(const Duration(seconds: 1), () {
        setState(() => _isLoading = false);
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const PaymentScreen()),
        );
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("You can only end your ride near a station.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(target: _stations[0], zoom: 20),
            markers: _stations.map((station) => Marker(markerId: MarkerId(station.toString()), position: station)).toSet(),
            polylines: {
              Polyline(
                polylineId: const PolylineId("route"),
                points: _routeCoordinates,
                color: Colors.blue,
                width: 5,
              ),
            },
            onMapCreated: (GoogleMapController controller) {
              _controller = controller;
            },
          ),
          Positioned(
            top: 40,
            left: 20,
            child: Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.grey,
                        blurRadius: 4
                      )
                    ]
                  ),
                  child: IconButton(
                    onPressed: (){
                      Navigator.of(context).pop();
                    },
                    icon: const Icon(
                        FontAwesomeIcons.arrowLeft
                    ),
                  ),
                ),
                const SizedBox(width: 20,),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(10)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Distance: ${_distanceTraveled.toStringAsFixed(2)} m", style: const TextStyle(color: Colors.white)),
                      Text(_isNearStation ? "You can end the ride" : "Ride must end near a station", style: const TextStyle(color: Colors.yellow)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 30,
            left: 20,
            right: 20,
            child: ElevatedButton(
              onPressed: _endRide,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 15),
                backgroundColor: _isNearStation ? Colors.blueAccent : Colors.red,
              ),
              child: const Text("End Ride", style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16
              ),),
            ),
          ),
          if (_isLoading)
            Center(
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 10)],
                ),
                child: const Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 10),
                    Text("Calculating total price for the distance travelled..."),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class PaymentScreen extends StatelessWidget {
  const PaymentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Choose Payment Method")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ListTile(
              leading: const Icon(Icons.credit_card),
              title: const Text("Credit Card"),
              onTap: () {},
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.phone_android),
              title: const Text("Mobile Payment"),
              onTap: () {},
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.money),
              title: const Text("Cash"),
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }
}
