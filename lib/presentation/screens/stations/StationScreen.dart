import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:revobike/api/station_service.dart';
import 'package:revobike/data/models/Station.dart'; // Ensure this is the updated model
import 'package:revobike/presentation/screens/stations/StationDetails.dart'; // Corrected import
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

  final TextEditingController _startLocationController =
      TextEditingController();
  final TextEditingController _endLocationController = TextEditingController();

  Station? _selectedStartStation;
  Station? _selectedEndStation;

  List<Station> _filteredStationsForStart = [];
  List<Station> _filteredStationsForEnd = [];

  bool _isStartSearchFocused = false;
  bool _isEndSearchFocused = false;

  @override
  void initState() {
    super.initState();
    _fetchStations();
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

    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
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
                                _isStartSearchFocused = true;
                              });
                            },
                          )
                        : null,
                  ),
                  readOnly: _selectedStartStation != null,
                  onTap: () {
                    setState(() {
                      _isStartSearchFocused = true;
                      _isEndSearchFocused = false;
                      _filteredStationsForStart = List.from(_stations);
                    });
                  },
                  onChanged: (query) {
                    _filterStations(query, true);
                  },
                ),
                const SizedBox(height: 16),
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
                                _isEndSearchFocused = true;
                              });
                            },
                          )
                        : null,
                  ),
                  readOnly: _selectedEndStation != null,
                  onTap: () {
                    setState(() {
                      _isEndSearchFocused = true;
                      _isStartSearchFocused = false;
                      _filteredStationsForEnd = List.from(_stations);
                    });
                  },
                  onChanged: (query) {
                    _filterStations(query, false);
                  },
                ),
                const SizedBox(height: 16),
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
                if (_areBothStationsSelected)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => StationDetailsScreen(
                              startStation: _selectedStartStation!,
                              endStation: _selectedEndStation!,
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
          Expanded(
            child: Stack(
              children: [
                // Display list of all stations or filtered suggestions
                ListView.builder(
                  itemCount: (_isStartSearchFocused || _isEndSearchFocused)
                      ? (_isStartSearchFocused
                          ? _filteredStationsForStart.length
                          : _filteredStationsForEnd.length)
                      : _stations
                          .length, // Show all stations if no search is active
                  itemBuilder: (context, index) {
                    final station =
                        (_isStartSearchFocused || _isEndSearchFocused)
                            ? (_isStartSearchFocused
                                ? _filteredStationsForStart[index]
                                : _filteredStationsForEnd[index])
                            : _stations[index]; // Use the appropriate list

                    return GestureDetector(
                      // Make the entire card tappable for selecting
                      onTap: () {
                        setState(() {
                          if (_isStartSearchFocused) {
                            _selectedStartStation = station;
                            _startLocationController.text = station.name;
                            _isStartSearchFocused = false;
                          } else if (_isEndSearchFocused) {
                            _selectedEndStation = station;
                            _endLocationController.text = station.name;
                            _isEndSearchFocused = false;
                          } else {
                            // If neither search is focused, allow tapping to view details for that station
                            Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => StationDetailsScreen(
                                startStation: station,
                                endStation:
                                    station, // For viewing purposes, assume start and end are same for now
                              ),
                            ));
                          }
                        });
                      },
                      child: Container(
                        margin: const EdgeInsets.only(
                            bottom: 16, left: 8, right: 8),
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
                                  station.status?.toLowerCase() == "open"
                                      ? Icons.check_circle_outline
                                      : Icons.cancel_outlined,
                                  color: station.status?.toLowerCase() == "open"
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
                            // Removed the "View Details" ElevatedButton from each card
                            // The entire card is now tappable to select a station or view its details
                          ],
                        ),
                      ),
                    );
                  },
                ),
                // Removed the redundant overlay for suggestions, now integrated directly in ListView.builder logic
              ],
            ),
          ),
        ],
      ),
    );
  }
}
