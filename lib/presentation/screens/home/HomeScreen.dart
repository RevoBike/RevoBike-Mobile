import 'package:flutter/material.dart';
import 'package:revobike/presentation/widget/CustomAppBar.dart';
import 'package:revobike/presentation/widget/BottomNavBar.dart';
import 'package:location/location.dart'; // Ensure this is imported if used within MapScreen for location
import 'package:revobike/presentation/screens/map/MapScreen.dart'; // Assuming this widget handles the Google Map
import 'package:revobike/api/auth_service.dart'; // Import your AuthService
import 'package:revobike/data/models/User.dart'; // Import your UserModel
import 'package:revobike/presentation/screens/auth/LoginScreen.dart'; // For logout navigation
import 'package:revobike/presentation/screens/account/AccountScreen.dart';
import 'package:revobike/presentation/screens/recent/RecentScreen.dart';
import 'package:revobike/presentation/screens/stations/StationScreen.dart';

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
      StationScreen(),
      RecentTripsScreen(),
      AccountScreen(),
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
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      }
    } catch (e) {
      print('Error fetching user profile from storage: $e');
      setState(() {
        _errorMessage =
            'Failed to load user profile: ${e.toString().contains('Exception:') ? e.toString().split('Exception: ')[1] : e.toString()}';
      });
      // Optionally, force logout if there's a serious storage error
      // await _authService.logout();
      // Navigator.of(context).pushReplacement(
      //   MaterialPageRoute(builder: (context) => LoginScreen()),
      // );
    } finally {
      setState(() {
        _isLoadingUser = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      extendBody: true,
      appBar: CustomAppBar(
        // Removed 'title' parameter as CustomAppBar no longer accepts it
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await _authService.logout();
              // Navigate back to login screen after logout
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => const LoginScreen()),
              );
            },
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row containing user icon, name, and welcome message
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
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
                          // Use _currentUser?.name ?? _currentUser?.email ?? 'Guest' for robust display
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
