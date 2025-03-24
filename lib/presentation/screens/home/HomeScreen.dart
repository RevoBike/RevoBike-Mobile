import 'package:crystal_navigation_bar/crystal_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:location/location.dart';
import 'package:revobike/presentation/screens/account/AccountScreen.dart';
import 'package:revobike/presentation/screens/auth/SignUpScreen.dart';
import 'package:revobike/presentation/screens/map/MapScreen.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:revobike/presentation/screens/recent/RecentScreen.dart';
import 'package:revobike/presentation/screens/stations/StationScreen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  var _currentIndex = 0;

  Location location = Location();

  static List<Widget> screens = [
    const MapScreen(),
    StationScreen(),
    const RecentTripsScreen(),
    const AccountScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      extendBody: true,
      body: SingleChildScrollView(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'Welcome to RevoBike!',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'Current Status: Unverified. Please visit a station to get verified.',
                style: TextStyle(fontSize: 18),
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'Instructions: Visit a nearby station to complete your verification.',
                style: TextStyle(fontSize: 16),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              decoration: InputDecoration(
                labelText: 'Nearby Station',
                hintText: 'Enter nearby station',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              decoration: InputDecoration(
                labelText: 'Destination',
                hintText: 'Enter your destination',
                border: OutlineInputBorder(),
              ),
            ),
            Container(
              height: 300, // Set height for the map
              child: GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: LatLng(37.7749, -122.4194), // Example coordinates
                  zoom: 12,
                ),
                markers: Set<Marker>.of(<Marker>[
                  Marker(
                    markerId: MarkerId('station1'),
                    position: LatLng(37.7749, -122.4194), // Example station
                    infoWindow: InfoWindow(title: 'Nearby Station 1'),
                  ),
                  // Add more markers as needed
                ]),
              ),
            ),
            // Add more widgets as needed
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const SignUpScreen()),
          );
        },
        child: const Icon(Icons.person_add),
      ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () => _googleMapController.animateCamera(
      //     CameraUpdate.newCameraPosition(
      //       CameraPosition(
      //         target: _currentLocation,
      //         zoom: 11.5,
      //       ),
      //     ),
      //   ),
      //   backgroundColor: Colors.white,
      //   foregroundColor: Colors.black,
      //   child: const Icon(Icons.center_focus_strong),
      // ),
      bottomNavigationBar: CrystalNavigationBar(
        marginR: const EdgeInsets.symmetric(vertical: 20, horizontal: 30),
        currentIndex: _currentIndex,
        indicatorColor: Colors.transparent,
        backgroundColor: Colors.white,
        outlineBorderColor: Colors.transparent,
        splashColor: Colors.transparent,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
        borderRadius: 20,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: [
          CrystalNavigationBarItem(
            icon: FontAwesomeIcons.house,
            selectedColor: Colors.blueAccent,
            unselectedColor: Colors.grey[400],
            unselectedIcon: FontAwesomeIcons.house,
          ),
          CrystalNavigationBarItem(
            icon: FontAwesomeIcons.chargingStation,
            selectedColor: Colors.blueAccent,
            unselectedColor: Colors.grey[400],
            unselectedIcon: FontAwesomeIcons.chargingStation,
          ),
          CrystalNavigationBarItem(
            icon: FontAwesomeIcons.clockRotateLeft,
            selectedColor: Colors.blueAccent,
            unselectedColor: Colors.grey[400],
            unselectedIcon: FontAwesomeIcons.clockRotateLeft,
          ),
          CrystalNavigationBarItem(
            icon: FontAwesomeIcons.userGear,
            selectedColor: Colors.blueAccent,
            unselectedColor: Colors.grey[400],
            unselectedIcon: FontAwesomeIcons.userGear,
          ),
        ],
      )
    );
  }
}
