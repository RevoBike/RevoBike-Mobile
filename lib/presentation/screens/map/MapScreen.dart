import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:revobike/data/models/Station.dart';
import 'package:revobike/presentation/screens/booking/BookingConfirmationScreen.dart';
import 'package:revobike/presentation/screens/stations/StationDetails.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late LatLng _currentLocation = const LatLng(9.0069631, 38.7622717);
  static const LatLng _station1 = LatLng(9.0016631, 38.723503);
  static const LatLng _station2 = LatLng(8.9812889, 38.7596757);

  late GoogleMapController _googleMapController;
  Location location = Location();
  String? _selectedMarkerId; // Track selected marker

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _currentLocation,
              zoom: 12.5,
            ),
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            onMapCreated: (controller) => _googleMapController = controller,
            markers: createMarker(),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 100,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.white.withOpacity(1),
                    Colors.white.withOpacity(0.8),
                    Colors.white.withOpacity(0.0),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: 40,
            left: 10,
            right: 10,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const CircleAvatar(
                      maxRadius: 25,
                      backgroundColor: Colors.white,
                      backgroundImage: AssetImage("assets/images/img.png"),
                    )),
                const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Icon(
                        FontAwesomeIcons.locationArrow,
                        color: Colors.blueAccent,
                        size: 15,
                      ),
                      SizedBox(width: 5),
                      Text("Your Location",
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Colors.black45)),
                    ]),
                    Text(
                      "Akaki Kality",
                      style: TextStyle(
                          color: Colors.black54,
                          fontWeight: FontWeight.w800,
                          fontSize: 20),
                    )
                  ],
                ),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: IconButton(
                    onPressed: () {},
                    icon: const Icon(
                      Icons.dashboard,
                      color: Colors.black54,
                      size: 30,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (_selectedMarkerId != null)
            Positioned(
              left: 0,
              right: 0,
              bottom: 100,
              child: Container(
                height: 230,
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 20,
                      offset: const Offset(0, -5),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          getMarkerTitle(_selectedMarkerId!),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.blueAccent,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: IconButton(
                            icon: const Icon(
                              FontAwesomeIcons.share,
                              color: Colors.white,
                              size: 16,
                            ),
                            onPressed: () =>
                                setState(() => _selectedMarkerId = null),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      getMarkerDescription(_selectedMarkerId!),
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 6),
                    // Additional bike station info
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Icon(FontAwesomeIcons.bicycle,
                            size: 18, color: Colors.green),
                        const SizedBox(width: 10),
                        Text(
                          "Available Bikes: ${getAvailableBikes(_selectedMarkerId!)}",
                          style:
                              const TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Icon(FontAwesomeIcons.doorOpen,
                            size: 18, color: Colors.blue),
                        const SizedBox(width: 8),
                        Text(
                          "Status: ${getStationStatus(_selectedMarkerId!)}",
                          style:
                              const TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) => StationDetailsScreen(
                                      station: getStationFromMarkerId(
                                          _selectedMarkerId!))));
                            },
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Colors.lightBlue),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              "View",
                              style: TextStyle(
                                  color: Colors.lightBlue, fontSize: 18),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) =>
                                      BookingConfirmationScreen(
                                          station: getStationFromMarkerId(
                                              _selectedMarkerId!))));
                            },
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Colors.blueAccent),
                              backgroundColor: Colors.blueAccent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              "Book",
                              style:
                                  TextStyle(color: Colors.white, fontSize: 18),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Set<Marker> createMarker() {
    return {
      Marker(
        markerId: const MarkerId('Meskel Square Station'),
        position: const LatLng(9.0069631, 38.7622717),
        infoWindow: const InfoWindow(title: "Meskel Square Station"),
        onTap: () =>
            setState(() => _selectedMarkerId = 'Meskel Square Station'),
      ),
      Marker(
        markerId: const MarkerId('Tor Hayloch Station'),
        position: const LatLng(9.0016631, 38.723503),
        infoWindow: const InfoWindow(title: "Tor Hayloch Station"),
        onTap: () => setState(() => _selectedMarkerId = 'Tor Hayloch Station'),
      ),
      Marker(
        markerId: const MarkerId('Saris Abo Station'),
        position: const LatLng(8.9812889, 38.7596757),
        infoWindow: const InfoWindow(title: "Saris Abo Station"),
        onTap: () => setState(() => _selectedMarkerId = 'Saris Abo Station'),
      ),
    };
  }

  int getAvailableBikes(String markerId) {
    // This could be dynamic data from an API in a real app
    switch (markerId) {
      case 'Meskel Square Station':
        return 12;
      case 'Tor Hayloch Station':
        return 8;
      case 'Saris Abo Station':
        return 5;
      default:
        return 0;
    }
  }

  String getStationStatus(String markerId) {
    // This could be dynamic data from an API in a real app
    switch (markerId) {
      case 'Meskel Square Station':
        return "Open";
      case 'Tor Hayloch Station':
        return "Open";
      case 'Saris Abo Station':
        return "Open";
      default:
        return "Closed";
    }
  }

  String getMarkerTitle(String markerId) {
    switch (markerId) {
      case 'Meskel Square Station':
        return "Meskel Square Station";
      case 'Tor Hayloch Station':
        return "Tor Hayloch Station";
      case 'Saris Abo Station':
        return "Saris Abo Station";
      default:
        return "Unknown Location";
    }
  }

  String getMarkerDescription(String markerId) {
    switch (markerId) {
      case 'Meskel Square Station':
        return "A major transportation hub in the heart of the city with multiple transit options.";
      case 'Tor Hayloch Station':
        return "Serving the western district with convenient access to local markets.";
      case 'Saris Abo Station':
        return "Located in the southern area, known for its proximity to residential zones.";
      default:
        return "No description available.";
    }
  }

  Station getStationFromMarkerId(String markerId) {
    switch (markerId) {
      case 'Meskel Square Station':
        return const Station(
          id: '1',
          name: 'Meskel Square Station',
          location: 'Meskel Square, Addis Ababa',
          latitude: 9.0069631,
          longitude: 38.7622717,
          availableBikes: 12,
          rate: 2.5,
          status: 'open',
        );
      case 'Tor Hayloch Station':
        return const Station(
          id: '2',
          name: 'Tor Hayloch Station',
          location: 'Tor Hayloch, Addis Ababa',
          latitude: 9.0016631,
          longitude: 38.723503,
          availableBikes: 8,
          rate: 2.5,
          status: 'open',
        );
      case 'Saris Abo Station':
        return const Station(
          id: '3',
          name: 'Saris Abo Station',
          location: 'Saris Abo, Addis Ababa',
          latitude: 8.9812889,
          longitude: 38.7596757,
          availableBikes: 5,
          rate: 2.5,
          status: 'open',
        );
      default:
        return const Station(
          id: '0',
          name: 'Unknown Station',
          location: 'Unknown Location',
          latitude: 0,
          longitude: 0,
          availableBikes: 0,
          rate: 0,
          status: 'closed',
        );
    }
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    PermissionStatus permissionGranted;

    serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        return;
      }
    }

    permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    location.onLocationChanged.listen((LocationData currentLocation) {
      if (mounted) {
        setState(() {
          _currentLocation = LatLng(
            currentLocation.latitude!,
            currentLocation.longitude!,
          );
        });
      }
    });
  }

  @override
  void dispose() {
    _googleMapController.dispose();
    super.dispose();
  }
}
