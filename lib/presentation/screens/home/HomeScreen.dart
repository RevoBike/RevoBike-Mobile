import 'package:flutter/material.dart';
import 'package:revobike/presentation/widget/CustomAppBar.dart';
import 'package:revobike/presentation/widget/BottomNavBar.dart';
import 'package:location/location.dart';
import 'package:revobike/presentation/screens/account/AccountScreen.dart';
import 'package:revobike/presentation/screens/auth/SignUpScreen.dart';
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
  final List<String> _bikeStations = [
    'Tuludimtu Gate 3',
    'Kilinto Gate 2',
    'Central Main Campus',
    'Classes Block 59',
  ];

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
        appBar: const CustomAppBar(
          title: 'RevoBike',
        ),
        body: IndexedStack(
          index: _currentIndex,
          children: screens,
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
        bottomNavigationBar: CustomBottomNavBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
        ));
  }
}
