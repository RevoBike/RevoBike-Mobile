import 'package:flutter/material.dart';
import 'package:revobike/presentation/widget/CustomAppBar.dart';
import 'package:revobike/presentation/widget/BottomNavBar.dart';
import 'package:revobike/presentation/screens/map/MapScreen.dart'; // Ensure this is imported
import 'package:revobike/api/auth_service.dart';
import 'package:revobike/data/models/User.dart';
import 'package:revobike/presentation/screens/auth/LoginScreen.dart';
import 'package:revobike/presentation/screens/account/AccountScreen.dart';
import 'package:revobike/presentation/screens/recent/RecentScreen.dart';
import 'package:revobike/presentation/screens/stations/StationScreen.dart';
import 'package:revobike/constants/app_colors.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AuthService _authService = AuthService();
  UserModel? _currentUser;
  bool _isLoadingUser = true;
  String _errorMessage = '';

  int _currentIndex =
      0; // 0 for HomePageScreen (your main dashboard, now with Map)

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    setState(() {
      _isLoadingUser = true;
      _errorMessage = '';
    });
    try {
      final user = await _authService.fetchUserProfile();
      if (user != null) {
        setState(() {
          _currentUser = user;
        });
      } else {
        print('User authenticated but profile not found locally. Logging out.');
        await _authService.logout();
        if (mounted) {
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
    } finally {
      setState(() {
        _isLoadingUser = false;
      });
    }
  }

  // Local function to handle the snackbar tap (navigates to StationScreen tab)
  void _onEnterDestinationTap(List<Widget> bottomNavScreens) {
    // Find the index of StationScreen dynamically
    final stationScreenIndex = bottomNavScreens
        .indexWhere((widget) => widget.runtimeType == StationScreen);

    if (stationScreenIndex != -1) {
      setState(() {
        _currentIndex = stationScreenIndex;
      });
    } else {
      // Fallback: This should ideally not happen if StationScreen is in bottomNavScreens
      setState(() {
        // If StationScreen is expected at index 1 after HomePageScreen, set it directly
        _currentIndex = 1; // Assuming StationScreen is now at index 1
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Define the list of screens for the Bottom Navigation Bar
    // HomePageScreen is your primary 'home' tab at index 0 and now includes the map.
    final List<Widget> bottomNavScreens = [
      HomePageScreen(
        currentUser: _currentUser,
        isLoadingUser: _isLoadingUser,
        errorMessage: _errorMessage,
      ),
      // MapScreen is now part of HomePageScreen, so it's removed from this list.
      const StationScreen(), // Now at Index 1 (was 2)
      const RecentTripsScreen(), // Now at Index 2 (was 3)
      const AccountScreen(), // Now at Index 3 (was 4)
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      extendBody: true,
      appBar: CustomAppBar(
        // Conditionally provide the onLeadingPressed callback for the back button.
        // It will be shown on any tab *other than* HomePageScreen (index 0).
        onLeadingPressed: _currentIndex != 0
            ? () {
                setState(() {
                  _currentIndex = 0; // Navigate back to the HomePageScreen tab
                });
              }
            : null, // No leading button on the HomePageScreen tab
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
      body: Expanded(
        child: Stack(
          children: [
            IndexedStack(
              index: _currentIndex,
              children: bottomNavScreens,
            ),
            // The "Where to?" snackbar is displayed only on the HomePageScreen (index 0).
            if (_currentIndex == 0)
              Positioned(
                left: 30.0,
                right: 30.0,
                bottom: 35.0 + kBottomNavigationBarHeight,
                child: GestureDetector(
                  onTap: () =>
                      _onEnterDestinationTap(bottomNavScreens), // Pass the list
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
          ],
        ),
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

class HomePageScreen extends StatelessWidget {
  final UserModel? currentUser;
  final bool isLoadingUser;
  final String errorMessage;

  const HomePageScreen({
    super.key,
    required this.currentUser,
    required this.isLoadingUser,
    required this.errorMessage,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: Colors.grey[50],
                child: currentUser?.name != null && currentUser!.name.isNotEmpty
                    ? Text(
                        currentUser!.name[0].toUpperCase(),
                        style: TextStyle(
                            color: AppColors.primaryGreen,
                            fontSize: 20,
                            fontWeight: FontWeight.bold),
                      )
                    : Icon(Icons.person,
                        color: AppColors.primaryGreen, size: 30),
              ),
              const SizedBox(width: 12),
              if (isLoadingUser)
                const CircularProgressIndicator(strokeWidth: 2)
              else if (errorMessage.isNotEmpty)
                Expanded(
                  child: Text(
                    errorMessage,
                    style: const TextStyle(color: Colors.red, fontSize: 14),
                    overflow: TextOverflow.ellipsis,
                  ),
                )
              else
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Hello, ${currentUser?.name ?? 'Guest'},',
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
        // The MapScreen is now directly embedded into HomePageScreen
        Expanded(
          child: MapScreen(),
        ),
      ],
    );
  }
}
