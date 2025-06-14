import 'package:flutter/material.dart';
import 'package:revobike/constants/app_colors.dart'; // Ensure this path is correct

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  // Removed 'title' as a required parameter if you want a fixed title "StepGreen"
  // If you want it dynamic, uncomment the line below and ensure it's passed from HomeScreen
  // final String title;
  final List<Widget>? actions; // Added actions parameter
  final Widget? leading; // Added leading parameter for consistency with AppBar
  final bool centerTitle; // Added centerTitle parameter for consistency

  const CustomAppBar({
    super.key,
    // required this.title, // Uncomment if you want to pass title dynamically
    this.actions, // Initialize actions
    this.leading,
    this.centerTitle = true, // Set default to true as per your original code
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      // Fixed title "StepGreen" as per your provided code
      title: const Text(
        "StepGreen",
        style: TextStyle(color: Colors.white),
      ),
      centerTitle: centerTitle, // Use the new parameter
      leading: leading, // Use the new parameter
      actions: actions, // Pass the actions to the underlying AppBar
      backgroundColor: AppColors.primaryGreen, // Use your defined color
      foregroundColor: Colors.white, // Use your defined color
      elevation: 0, // Example: Remove shadow (optional)
      // You can add more styling here based on your app's design
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
