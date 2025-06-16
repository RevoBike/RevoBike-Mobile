import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:revobike/constants/app_colors.dart'; // Import your AppColors

class BookScreen extends StatefulWidget {
  const BookScreen({super.key});

  @override
  State<BookScreen> createState() => _BookScreenState();
}

class _BookScreenState extends State<BookScreen> {
  LatLng? _start;
  LatLng? _destination;
  bool _isCalculating = false;
  double? _price;
  late GoogleMapController _googleMapController;
  Location location = Location();

  void _onMapTap(LatLng position) {
    setState(() {
      if (_start == null) {
        _start = position;
      } else if (_destination == null) {
        _destination = position;
        _calculatePrice();
      } else {
        _start = position;
        _destination = null;
        _price = null;
      }
    });
  }

  Future<void> _calculatePrice() async {
    if (_start != null && _destination != null) {
      setState(() => _isCalculating = true);
      double distanceInMeters = Geolocator.distanceBetween(
        _start!.latitude,
        _start!.longitude,
        _destination!.latitude,
        _destination!.longitude,
      );
      double distanceInKm = distanceInMeters / 1000;
      await Future.delayed(const Duration(seconds: 2));
      setState(() {
        _price = distanceInKm * 200;
        _isCalculating = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          "Book a Bike",
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: const CameraPosition(
              target: LatLng(9.0069631, 38.7622717),
              zoom: 12.5,
            ),
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            onMapCreated: (controller) => _googleMapController = controller,
            onTap: _onMapTap,
            markers: {
              if (_start != null)
                Marker(
                  markerId: const MarkerId("start"),
                  position: _start!,
                  icon: BitmapDescriptor.defaultMarkerWithHue(
                      BitmapDescriptor.hueGreen),
                ),
              if (_destination != null)
                Marker(
                  markerId: const MarkerId("destination"),
                  position: _destination!,
                  icon: BitmapDescriptor.defaultMarkerWithHue(
                      BitmapDescriptor.hueBlue),
                ),
            },
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Icon(FontAwesomeIcons.locationDot,
                          color: Colors.green),
                      Text(_start != null ? "Start Selected" : "Select Start",
                          style: const TextStyle(fontSize: 16)),
                      const Icon(FontAwesomeIcons.chevronRight)
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Icon(FontAwesomeIcons.locationDot,
                          color: AppColors.secondaryGreen),
                      Text(
                          _destination != null
                              ? "Destination Selected"
                              : "Select Destination",
                          style: const TextStyle(fontSize: 16)),
                      const Icon(FontAwesomeIcons.chevronRight)
                    ],
                  ),
                  const SizedBox(height: 10),
                  if (_isCalculating)
                    const CircularProgressIndicator()
                  else if (_price != null)
                    Text("Price: Br.${_price!.toStringAsFixed(1)}",
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 15),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 40, vertical: 12),
                        ),
                        onPressed: _destination != null && _price != null
                            ? () {}
                            : null,
                        child: const Row(
                          children: [
                            Icon(FontAwesomeIcons.check, color: Colors.white),
                            SizedBox(width: 10),
                            Text("Order",
                                style: TextStyle(
                                    fontSize: 18, color: Colors.white)),
                          ],
                        ),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 40, vertical: 12),
                        ),
                        onPressed: () {
                          setState(() {
                            _start = null;
                            _destination = null;
                            _price = null;
                          });
                        },
                        child: const Row(
                          children: [
                            Icon(FontAwesomeIcons.xmark, color: Colors.white),
                            SizedBox(width: 10),
                            Text("Cancel",
                                style: TextStyle(
                                    fontSize: 18, color: Colors.white)),
                          ],
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
