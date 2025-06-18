import 'package:flutter/material.dart';
import 'package:revobike/constants/app_colors.dart'; // Assuming you have AppColors defined
// import 'package:revobike/presentation/screens/auth/LoginScreen.dart'; // No longer navigate directly here
import 'package:revobike/presentation/screens/auth/AuthChoiceScreen.dart'; // Import the LocationPermissionScreen

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, String>> onboardingPages = [
    {
      'image': 'assets/images/stationcharge.jpg', // Placeholder image asset
      'title': 'Find Your Perfect Ride',
      'description':
          'Locate nearby e-bike stations and browse available bikes with ease. Your next adventure is just a tap away.',
    },
    {
      'image': 'assets/images/stationcafe.jpg', // Placeholder image asset
      'title': 'Effortless Unlocking',
      'description': 'Hang out at the nearby station, romanticize life.',
    },
    {
      'image': 'assets/images/stationplants.jpg', // Placeholder image asset
      'title': 'Sustainable Journeys',
      'description':
          'Join the green movement. Choose electric bikes for eco-friendly commutes and healthy explorations.',
    },
  ];

  @override
  void initState() {
    super.initState();
    _pageController.addListener(() {
      setState(() {
        _currentPage = _pageController.page!.round();
      });
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // --- MODIFIED NAVIGATION FUNCTION ---
  void _navigateToLocationPermission() {
    Navigator.of(context).pushReplacement(
      // Push the LocationPermissionScreen as a full-screen route
      MaterialPageRoute(builder: (context) => const AuthChoiceScreen()),
    );
  }
  // --- END MODIFICATION ---

  void _onSkipPressed() {
    _navigateToLocationPermission(); // Now navigates to LocationPermissionScreen
  }

  void _onNextPressed() {
    if (_currentPage < onboardingPages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeIn,
      );
    } else {
      // Last page, navigate to LocationPermissionScreen
      _navigateToLocationPermission(); // Now navigates to LocationPermissionScreen
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
              child: Align(
                alignment: Alignment.topRight,
                child: TextButton(
                  onPressed: _onSkipPressed,
                  child: Text(
                    'Skip',
                    style: TextStyle(
                      color: AppColors
                          .primaryGreen, // Use your app's primary color
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: onboardingPages.length,
                itemBuilder: (context, index) {
                  final page = onboardingPages[index];
                  return _OnboardingPage(
                    imagePath: page['image']!,
                    title: page['title']!,
                    description: page['description']!,
                  );
                },
              ),
            ),
            // Page Indicator Dots
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                onboardingPages.length,
                (index) => AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  height: 8,
                  width: _currentPage == index ? 24 : 8,
                  margin:
                      const EdgeInsets.symmetric(horizontal: 4, vertical: 16),
                  decoration: BoxDecoration(
                    color: _currentPage == index
                        ? AppColors.primaryGreen // Active dot color
                        : Colors.grey[300], // Inactive dot color
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _onNextPressed,
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        AppColors.primaryGreen, // Use your app's primary color
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    _currentPage == onboardingPages.length - 1
                        ? 'Get Started'
                        : 'Next',
                    style: const TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Reusable widget for each onboarding page
class _OnboardingPage extends StatelessWidget {
  final String imagePath;
  final String title;
  final String description;

  const _OnboardingPage({
    required this.imagePath,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            flex: 3, // Illustration takes more space
            child: Image.asset(
              imagePath,
              fit: BoxFit.contain, // Adjust as needed
            ),
          ),
          const SizedBox(height: 30),
          Expanded(
            flex: 2, // Text content takes less space
            child: Column(
              children: [
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkGrey, // Use your app's text color
                  ),
                ),
                const SizedBox(height: 15),
                Text(
                  description,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[700],
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
