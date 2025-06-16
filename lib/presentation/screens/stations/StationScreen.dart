import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:revobike/api/station_service.dart';
import 'package:revobike/data/models/Station.dart'; // Ensure this is the updated model
import 'package:revobike/presentation/screens/stations/StationDetails.dart'; // This will be the StationDetailsScreen, not StationDetails
import 'package:revobike/constants/app_colors.dart';

class StationScreen extends StatefulWidget {
  const StationScreen({super.key});

  @override
  State<StationScreen> createState() => _StationScreenState();
}

class _StationScreenState extends State<StationScreen> {
  final StationService _stationService = StationService();
  List<Station> _stations = [];
  bool _isLoading = true;
  String? _error;

  // New: Controllers for search bars
  final TextEditingController _startLocationController =
      TextEditingController();
  final TextEditingController _endLocationController = TextEditingController();

  // New: Variables to hold selected stations
  Station? _selectedStartStation;
  Station? _selectedEndStation;

  // New: Filtered list for suggestions (initially all stations)
  List<Station> _filteredStationsForStart = [];
  List<Station> _filteredStationsForEnd = [];

  // New: To control which suggestion list is active
  bool _isStartSearchFocused = false;
  bool _isEndSearchFocused = false;

  @override
  void initState() {
    super.initState();
    _fetchStations();
    // Initialize filtered lists with all stations
    _filteredStationsForStart = _stations;
    _filteredStationsForEnd = _stations;
  }

  @override
  void dispose() {
    _startLocationController.dispose();
    _endLocationController.dispose();
    super.dispose();
  }

  Future<void> _fetchStations() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final stations = await _stationService.getStations();

      setState(() {
        _stations = stations;
        _isLoading = false;
        // Update filtered lists after fetching stations
        _filteredStationsForStart = List.from(_stations);
        _filteredStationsForEnd = List.from(_stations);
      });
    } catch (e) {
      setState(() {
        _error = e.toString().contains('Exception:')
            ? e.toString().split('Exception: ')[1]
            : e.toString();
        _isLoading = false;
      });
    }
  }

  // New: Method to filter stations based on search input
  void _filterStations(String query, bool isStartSearch) {
    List<Station> filteredList = _stations.where((station) {
      final nameLower = station.name.toLowerCase();
      final addressLower = (station.address ?? '').toLowerCase();
      final queryLower = query.toLowerCase();
      return nameLower.contains(queryLower) ||
          addressLower.contains(queryLower);
    }).toList();

    setState(() {
      if (isStartSearch) {
        _filteredStationsForStart = filteredList;
      } else {
        _filteredStationsForEnd = filteredList;
      }
    });
  }

  // New: Helper to check if both stations are selected
  bool get _areBothStationsSelected =>
      _selectedStartStation != null && _selectedEndStation != null;

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Error: $_error',
              style: const TextStyle(color: Colors.red),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _fetchStations,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_stations.isEmpty) {
      return const Center(
        child: Text(
          'No stations available at the moment.',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    // Main Scaffold for the StationScreen
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Start Location Search Bar
                TextFormField(
                  controller: _startLocationController,
                  decoration: InputDecoration(
                    hintText: _selectedStartStation?.name ??
                        'Start Location / Pick-up Station',
                    prefixIcon: const Icon(Icons.location_on),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.grey[200],
                    suffixIcon: _selectedStartStation != null
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              setState(() {
                                _startLocationController.clear();
                                _selectedStartStation = null;
                                _isStartSearchFocused =
                                    true; // Re-focus to show suggestions
                              });
                            },
                          )
                        : null,
                  ),
                  readOnly: _selectedStartStation !=
                      null, // Make read-only if a station is selected
                  onTap: () {
                    setState(() {
                      _isStartSearchFocused = true;
                      _isEndSearchFocused = false;
                      _filteredStationsForStart =
                          List.from(_stations); // Show all initially
                    });
                  },
                  onChanged: (query) {
                    _filterStations(query, true);
                  },
                ),
                const SizedBox(height: 16),
                // End Location Search Bar
                TextFormField(
                  controller: _endLocationController,
                  decoration: InputDecoration(
                    hintText: _selectedEndStation?.name ??
                        'End Location / Return Station',
                    prefixIcon: const Icon(Icons.location_on_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.grey[200],
                    suffixIcon: _selectedEndStation != null
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              setState(() {
                                _endLocationController.clear();
                                _selectedEndStation = null;
                                _isEndSearchFocused =
                                    true; // Re-focus to show suggestions
                              });
                            },
                          )
                        : null,
                  ),
                  readOnly: _selectedEndStation !=
                      null, // Make read-only if a station is selected
                  onTap: () {
                    setState(() {
                      _isEndSearchFocused = true;
                      _isStartSearchFocused = false;
                      _filteredStationsForEnd =
                          List.from(_stations); // Show all initially
                    });
                  },
                  onChanged: (query) {
                    _filterStations(query, false);
                  },
                ),
                const SizedBox(height: 16),
                // Displaying selected stations if any
                if (_selectedStartStation != null ||
                    _selectedEndStation != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (_selectedStartStation != null)
                          Text('From: ${_selectedStartStation!.name}',
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold)),
                        if (_selectedEndStation != null)
                          Text('To: ${_selectedEndStation!.name}',
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                // Confirm Stations Button
                if (_areBothStationsSelected)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        // Navigate to StationDetailsScreen, passing both selected stations
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => StationDetailsScreen(
                              startStation:
                                  _selectedStartStation!, // Pass the selected start station
                              // You'll need to modify StationDetailsScreen to accept endStation
                              // For now, let's just pass the start station as per its current design.
                              // In the next step, we'll update StationDetailsScreen to handle both.
                              endStation:
                                  _selectedEndStation!, // Pass the selected end station
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryGreen,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.symmetric(vertical: 15),
                      ),
                      child: const Text(
                        'Confirm Stations & View Bikes',
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
                    ),
                  ),
                const SizedBox(height: 16),
              ],
            ),
          ),
          // Expanded section for the filtered list of stations
          Expanded(
            child: Stack(
              // Use a Stack to layer the suggestions over the main list
              children: [
                // Original list of all stations (or a filtered list based on the active search)
                ListView.builder(
                  itemCount:
                      _stations.length, // Still show the full list initially
                  itemBuilder: (context, index) {
                    final station = _stations[index];
                    final String? firstAvailableBikeId =
                        station.availableBikes.isNotEmpty
                            ? station.availableBikes.first.bikeId
                            : null;

                    return Container(
                      margin:
                          const EdgeInsets.only(bottom: 16, left: 8, right: 8),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  station.name,
                                  style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Icon(
                                station.status.toLowerCase() == "open"
                                    ? FontAwesomeIcons.circleCheck
                                    : FontAwesomeIcons.circleXmark,
                                color: station.status.toLowerCase() == "open"
                                    ? Colors.green
                                    : Colors.red,
                                size: 18,
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(
                                FontAwesomeIcons.locationDot,
                                size: 16,
                                color: AppColors.primaryGreen,
                              ),
                              const SizedBox(width: 8),
                              Text(station.address ?? station.name,
                                  style: const TextStyle(
                                      fontSize: 14, color: Colors.grey)),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(FontAwesomeIcons.bicycle,
                                  size: 16, color: AppColors.primaryGreen),
                              const SizedBox(width: 8),
                              Text(
                                  "${station.availableBikes.length} Bikes Available",
                                  style: const TextStyle(
                                      fontSize: 14,
                                      color: AppColors.primaryGreen)),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(FontAwesomeIcons.route,
                                  size: 16, color: AppColors.primaryGreen),
                              const SizedBox(width: 8),
                              Text(
                                  "${station.location.coordinates[1].toStringAsFixed(2)}, ${station.location.coordinates[0].toStringAsFixed(2)}",
                                  style: const TextStyle(
                                      fontSize: 14,
                                      color: AppColors.primaryGreen)),
                              const Spacer(),
                              const Icon(FontAwesomeIcons.dollarSign,
                                  size: 16, color: AppColors.primaryGreen),
                              const SizedBox(width: 8),
                              Text(
                                  "Br.${station.rate?.toStringAsFixed(2) ?? 'N/A'}/km",
                                  style: const TextStyle(
                                      fontSize: 14,
                                      color: AppColors.primaryGreen)),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () {
                                    // This "View" button now would potentially set either start or end
                                    // depending on which search bar is active, or just show details.
                                    // For now, let's keep it as is, or you might choose to remove it
                                    // if the primary selection is via the search bar suggestions.
                                    Navigator.of(context)
                                        .push(MaterialPageRoute(
                                      builder: (context) =>
                                          StationDetailsScreen(
                                        startStation: station,
                                        endStation:
                                            station, // Pass same station as fallback
                                      ),
                                    ));
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        side: const BorderSide(
                                          color: AppColors.primaryGreen,
                                          width: 1.0,
                                        )),
                                  ),
                                  child: const Text("View",
                                      style: TextStyle(
                                          color: AppColors.primaryGreen,
                                          fontWeight: FontWeight.bold)),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: ElevatedButton(
                                  onPressed:
                                      station.status.toLowerCase() == "open" &&
                                              firstAvailableBikeId != null
                                          ? () {
                                              // This "Book" button logic might need to change
                                              // based on the new flow. For now, it remains
                                              // but will likely be replaced by a deeper flow.
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                const SnackBar(
                                                  content: Text(
                                                      'Please select both start and end stations from the search bars first.'),
                                                ),
                                              );
                                            }
                                          : () {
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
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
                                        station.status.toLowerCase() ==
                                                    "open" &&
                                                firstAvailableBikeId != null
                                            ? AppColors.primaryGreen
                                            : Colors.grey,
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                  ),
                                  child: Text(
                                    firstAvailableBikeId == null
                                        ? "No Bikes"
                                        : "Book",
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
                // Overlay for suggestions lists
                if (_isStartSearchFocused || _isEndSearchFocused)
                  Positioned.fill(
                    child: Container(
                      color: Colors.black
                          .withOpacity(0.5), // Semi-transparent overlay
                      child: Center(
                        child: Container(
                          margin: const EdgeInsets.all(20),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                _isStartSearchFocused
                                    ? 'Select Start Station'
                                    : 'Select End Station',
                                style: const TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 10),
                              Expanded(
                                child: ListView.builder(
                                  shrinkWrap: true,
                                  itemCount: _isStartSearchFocused
                                      ? _filteredStationsForStart.length
                                      : _filteredStationsForEnd.length,
                                  itemBuilder: (context, index) {
                                    final station = _isStartSearchFocused
                                        ? _filteredStationsForStart[index]
                                        : _filteredStationsForEnd[index];
                                    return ListTile(
                                      title: Text(station.name),
                                      subtitle: Text(station.address ?? ''),
                                      onTap: () {
                                        setState(() {
                                          if (_isStartSearchFocused) {
                                            _selectedStartStation = station;
                                            _startLocationController.text = station
                                                .name; // Display selected name
                                            _isStartSearchFocused = false;
                                          } else {
                                            _selectedEndStation = station;
                                            _endLocationController.text = station
                                                .name; // Display selected name
                                            _isEndSearchFocused = false;
                                          }
                                        });
                                      },
                                    );
                                  },
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  setState(() {
                                    _isStartSearchFocused = false;
                                    _isEndSearchFocused = false;
                                  });
                                },
                                child: const Text('Close'),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
