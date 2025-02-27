import 'package:crystal_navigation_bar/crystal_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:location/location.dart';
import 'package:revobike/presentation/screens/account/AccountScreen.dart';
import 'package:revobike/presentation/screens/map/MapScreen.dart';
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
    const RecentScreen(),
    const AccountScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      extendBody: true,
      body: screens[_currentIndex],
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
            icon: FontAwesomeIcons.locationDot,
            selectedColor: Colors.blueAccent,
            unselectedColor: Colors.grey[400],
            unselectedIcon: FontAwesomeIcons.locationDot,
          ),
          CrystalNavigationBarItem(
            icon: FontAwesomeIcons.solidUser,
            selectedColor: Colors.blueAccent,
            unselectedColor: Colors.grey[400],
            unselectedIcon: FontAwesomeIcons.user,
          ),
        ],
      )
    );
  }
}