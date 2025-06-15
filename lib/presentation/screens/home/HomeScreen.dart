import 'package:flutter/material.dart';
import 'package:revobike/presentation/widget/CustomAppBar.dart';
import 'package:revobike/presentation/widget/BottomNavBar.dart';
import 'package:revobike/presentation/screens/map/MapScreen.dart'; // Assuming this widget handles the Google Map
import 'package:revobike/api/auth_service.dart'; // Import your AuthService
import 'package:revobike/data/models/User.dart'; // Import your UserModel
import 'package:revobike/presentation/screens/auth/LoginScreen.dart'; // For logout navigation
import 'package:revobike/presentation/screens/account/AccountScreen.dart';
import 'package:revobike/presentation/screens/recent/RecentScreen.dart';
import 'package:revobike/presentation/screens/stations/StationScreen.dart'; // Import StationScreen

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AuthService _authService = AuthService(); // Instantiate AuthService
  UserModel? _currentUser; // To store fetched user data
  bool _isLoadingUser = true; // To manage loading state for user data
  String _errorMessage = ''; // To display any error fetching user data

  int _currentIndex = 0; // For the bottom navigation bar

  // Screens for the IndexedStack, which will be the primary content switched by BottomNavBar
  late final List<Widget> _bottomNavScreens;

  @override
  void initState() {
    super.initState();
    _fetchUserData(); // Fetch user data on init

    // Initialize _bottomNavScreens here to avoid re-creation on every build
    _bottomNavScreens = [
      MapScreen(), // Main map screen
      StationScreen(), // Station screen for listing/selecting stations
      RecentTripsScreen(), // Recent trips screen (assuming this is RecentTripsScreen)
      AccountScreen(), // Account screen
    ];
  }

  Future<void> _fetchUserData() async {
    setState(() {
      _isLoadingUser = true;
      _errorMessage = '';
    });
    try {
      // This now fetches the user from local storage, not an API call
      final user = await _authService.fetchUserProfile();
      if (user != null) {
        setState(() {
          _currentUser = user;
        });
      } else {
        // If authenticated but no local user profile (e.g., corrupted storage), force re-login
        print(
            'AuthCheckScreen: User authenticated but profile not found locally. Logging out.');
        await _authService.logout(); // Clear token too
        if (mounted) {
          // Check if the widget is still in the tree before navigating
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const LoginScreen()),
          );
        }
      }
    } catch (e) {
      print('Error fetching user profile from storage: $e');
      setState(() {
        _errorMessage =
            'Failed to load user profile: ${e.toString().contains('Exception:') ? e.toString().split('Exception: ')[1] : e.toString()}';
      });
      // Optionally, force logout if there's a serious storage error
      // if (mounted) {
      //   await _authService.logout();
      //   Navigator.of(context).pushReplacement(
      //     MaterialPageRoute(builder: (context) => LoginScreen()),
      //   );
      // }
    } finally {
      setState(() {
        _isLoadingUser = false;
      });
    }
  }

  // New method to handle the snackbar tap
  void _onEnterDestinationTap() {
    // Navigate to the StationScreen when the snackbar is tapped
    // We'll set the _currentIndex to the index of StationScreen in _bottomNavScreens
    // Or, if StationScreen is meant to be a new push, you'd do:
    // Navigator.of(context).push(MaterialPageRoute(builder: (context) => StationScreen()));
    // For this flow, let's assume it's part of the bottom nav screens.
    setState(() {
      final stationScreenIndex = _bottomNavScreens.indexWhere((widget) => widget.runtimeType == StationScreen);
      _currentIndex = stationScreenIndex != -1 ? stationScreenIndex : 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      extendBody: true, // Allows the body to extend under the AppBar/NavBar
      appBar: CustomAppBar(
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await _authService.logout();
              if (mounted) {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                );
              }
            },
          ),
        ],
      ),
      body: Stack(
        // Use Stack to layer the map content and the snackbar
        children: [
          Column(
            // Keep your existing Column for header and content
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Row containing user icon, name, and welcome message
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16.0, vertical: 12.0),
                child: Row(
                  children: [
                    // User Icon (using first letter of username for avatar if available)
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: Colors.blueGrey[100],
                      child: _currentUser?.name != null &&
                              _currentUser!.name.isNotEmpty
                          ? Text(
                              _currentUser!.name[0].toUpperCase(),
                              style: TextStyle(
                                  color: Colors.blueGrey[700],
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold),
                            )
                          : Icon(Icons.person,
                              color: Colors.blueGrey[700], size: 30),
                    ),
                    const SizedBox(width: 12),
                    // User Name and Welcome Message
                    if (_isLoadingUser)
                      const CircularProgressIndicator(strokeWidth: 2)
                    else if (_errorMessage.isNotEmpty)
                      Expanded(
                        child: Text(
                          _errorMessage,
                          style: TextStyle(color: Colors.red, fontSize: 14),
                          overflow: TextOverflow.ellipsis,
                        ),
                      )
                    else
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Hello, ${_currentUser?.name ?? 'Guest'},',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            const Text(
                              'Welcome to StepGreen!',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              // Content area that switches based on BottomNavBar selection
              Expanded(
                child: IndexedStack(
                  index: _currentIndex,
                  children: _bottomNavScreens,
                ),
              ),
            ],
          ),
          // >>> START OF NEW SNACKBAR IMPLEMENTATION <<<
          // Positioned at the bottom of the Stack, with padding from the actual bottom
          // to clear the BottomNavBar
          if (_currentIndex ==
              0) // Only show the snackbar on the MapScreen (index 0)
            Positioned(
              left: 30.0,
              right: 30.0,
              bottom: 35.0 +
                  kBottomNavigationBarHeight, // Add height of BottomNavBar
              child: GestureDetector(
                onTap: _onEnterDestinationTap,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 25.0, vertical: 20.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        spreadRadius: 2,
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.search, color: Colors.grey[600]),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Where to?',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 16.0,
                          ),
                        ),
                      ),
                      Icon(Icons.arrow_forward_ios,
                          color: Colors.grey[400], size: 16),
                    ],
                  ),
                ),
              ),
            ),
          // >>> END OF NEW SNACKBAR IMPLEMENTATION <<<
        ],
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}
