import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart'
    as loc_lib; // Alias the location package
import 'package:geocoding/geocoding.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:revobike/data/models/Station.dart'; // Import the updated Station model
import 'package:revobike/presentation/screens/booking/BookingConfirmationScreen.dart';
import 'package:revobike/presentation/screens/stations/StationDetails.dart';
import 'package:revobike/api/station_service.dart'; // Import your StationService

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  LatLng _currentLocation =
      const LatLng(9.0069631, 38.7622717); // Default to Meskel Square
  GoogleMapController? _googleMapController;
  loc_lib.Location location = loc_lib.Location(); // Use the aliased Location
  String _currentLocationName = 'Fetching location...';

  List<Station> _stations = []; // To store fetched station data
  bool _isLoadingStations = true;
  String _stationFetchError = '';

  // Initialize StationService: REMOVED baseUrl parameter
  final StationService _stationService = StationService();

  @override
  void initState() {
    super.initState();
    _checkAndRequestLocationPermission();
    _fetchStations(); // Fetch stations when the screen initializes
  }

  // Method to fetch stations from the API
  Future<void> _fetchStations() async {
    setState(() {
      _isLoadingStations = true;
      _stationFetchError = '';
    });
    try {
      final fetchedStations = await _stationService.getStations();
      setState(() {
        _stations = fetchedStations;
      });
    } catch (e) {
      print('Error fetching stations: $e');
      setState(() {
        _stationFetchError =
            'Failed to load stations: ${e.toString().contains('Exception:') ? e.toString().split('Exception: ')[1] : e.toString()}';
      });
    } finally {
      setState(() {
        _isLoadingStations = false;
      });
    }
  }

  // Method to check location service and permission, then get location
  Future<void> _checkAndRequestLocationPermission() async {
    bool serviceEnabled;
    loc_lib.PermissionStatus permissionGranted; // Use aliased PermissionStatus

    serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        setState(() {
          _currentLocationName = 'Location service disabled.';
        });
        return;
      }
    }

    permissionGranted = await location.hasPermission();
    if (permissionGranted == loc_lib.PermissionStatus.denied) {
      // Use aliased PermissionStatus
      permissionGranted = await location.requestPermission();
      if (permissionGranted != loc_lib.PermissionStatus.granted) {
        // Use aliased PermissionStatus
        setState(() {
          _currentLocationName = 'Location permission denied.';
        });
        return;
      }
    }

    _listenForLocationChanges();
  }

  // Method to listen for continuous location updates
  void _listenForLocationChanges() {
    location.onLocationChanged
        .listen((loc_lib.LocationData currentLocationData) async {
      // Use aliased LocationData
      if (mounted &&
          currentLocationData.latitude != null &&
          currentLocationData.longitude != null) {
        setState(() {
          _currentLocation = LatLng(
            currentLocationData.latitude!,
            currentLocationData.longitude!,
          );
        });

        _googleMapController?.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: _currentLocation,
              zoom: 15.0,
            ),
          ),
        );

        // Get location name with fallback
        try {
          List<Placemark> placemarks = await placemarkFromCoordinates(
            currentLocationData.latitude!,
            currentLocationData.longitude!,
          );
          if (placemarks.isNotEmpty) {
            final Placemark place = placemarks.first;
            // Prioritize address field from station if available, otherwise use geocoding
            String resolvedName = place.name ??
                place.street ??
                place.subLocality ??
                place.locality ??
                'Unknown Location';
            if (place.locality != null &&
                resolvedName.split(',').first.trim() !=
                    place.locality!.trim()) {
              resolvedName += ', ${place.locality}';
            }
            setState(() {
              _currentLocationName = resolvedName;
            });
          } else {
            setState(() {
              // Fallback to AASTU specific name if geocoding yields no results
              _currentLocationName =
                  'Addis Ababa Science and Technology University';
            });
          }
        } catch (e) {
          print('Error getting placemark: $e');
          setState(() {
            // Fallback to AASTU specific name on geocoding error
            _currentLocationName =
                'Addis Ababa Science and Technology University';
          });
        }
      }
    });
  }

  // Combines current location marker and dynamic station markers
  Set<Marker> _createMarkers() {
    final Set<Marker> markers = {};

    // Marker for current location
    markers.add(
      Marker(
        markerId: const MarkerId('currentLocation'),
        position: _currentLocation,
        infoWindow: InfoWindow(
            title: _currentLocationName, snippet: 'Your current location'),
        icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueAzure), // Blue marker
      ),
    );

    // Markers for fetched bike stations
    for (var station in _stations) {
      // API coordinates are [longitude, latitude], Google Maps expects LatLng(latitude, longitude)
      LatLng stationLatLng = LatLng(
          station.location.coordinates[1], station.location.coordinates[0]);
      markers.add(
        Marker(
          markerId: MarkerId(station.id), // Use unique station ID as marker ID
          position: stationLatLng,
          infoWindow: InfoWindow(
            title: station.name,
            snippet: 'Available: ${station.availableBikes.length}',
          ),
          onTap: () => _showStationDetailsSheet(
              station), // Pass the actual station object
          icon: BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueGreen), // Green marker for stations
        ),
      );
    }

    return markers;
  }

  // Function to show a bottom sheet with station details
  void _showStationDetailsSheet(Station station) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        // Find the first available bike for booking if any
        final String? firstAvailableBikeId = station.availableBikes.isNotEmpty
            ? station.availableBikes.first.bikeId
            : null;

        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            top: 20,
            left: 16,
            right: 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      station.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 22,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Use station.address for more precise location text if available
              Text(
                station.address ??
                    station.name, // Prefer address, fallback to name
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Icon(FontAwesomeIcons.bicycle,
                      size: 20, color: Colors.green),
                  const SizedBox(width: 10),
                  Text(
                    "Available Bikes: ${station.availableBikes.length}", // Use available_bikes list length
                    style: const TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Icon(FontAwesomeIcons.doorOpen,
                      size: 20, color: Colors.blue),
                  const SizedBox(width: 8),
                  Text(
                    "Status: ${station.status}",
                    style: const TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) =>
                                StationDetailsScreen(station: station)));
                      },
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.lightBlue),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        "View Details",
                        style: TextStyle(color: Colors.lightBlue, fontSize: 16),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      // Enable/disable based on status AND available bikes
                      onPressed: station.status.toLowerCase() == "open" &&
                              firstAvailableBikeId != null
                          ? () {
                              Navigator.of(context).pop(); // Close bottom sheet
                              Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => BookingConfirmationScreen(
                                  station: station,
                                  selectedBikeId:
                                      firstAvailableBikeId, // Pass the first available bike ID
                                ),
                              ));
                            }
                          : () {
                              // Show snackbar if no bikes or not open
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    firstAvailableBikeId == null
                                        ? 'No bikes available at this station.'
                                        : 'This station is currently ${station.status ?? 'closed'}.',
                                  ),
                                ),
                              );
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            station.status.toLowerCase() == "open" &&
                                    firstAvailableBikeId != null
                                ? Colors.blueAccent
                                : Colors.grey, // Grey out if disabled
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        firstAvailableBikeId == null ? "No Bikes" : "Book Bike",
                        style:
                            const TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Display current location name
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.location_on, color: Colors.blueAccent, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _currentLocationName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        // Google Map fills the rest of the available space
        Expanded(
          child: _isLoadingStations
              ? const Center(child: CircularProgressIndicator())
              : _stationFetchError.isNotEmpty
                  ? Center(
                      child: Text(_stationFetchError,
                          style: TextStyle(color: Colors.red)))
                  : GoogleMap(
                      initialCameraPosition: CameraPosition(
                        target: _currentLocation,
                        zoom: 12.5,
                      ),
                      myLocationButtonEnabled: true,
                      zoomControlsEnabled: false,
                      onMapCreated: (controller) {
                        _googleMapController = controller;
                        _googleMapController?.animateCamera(
                          CameraUpdate.newCameraPosition(
                            CameraPosition(
                              target: _currentLocation,
                              zoom: 15.0,
                            ),
                          ),
                        );
                      },
                      markers: _createMarkers(), // Use the combined markers
                      myLocationEnabled: true,
                    ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _googleMapController?.dispose();
    super.dispose();
  }
}
