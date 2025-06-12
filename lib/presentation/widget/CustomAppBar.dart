import 'package:flutter/material.dart';
import 'package:revobike/constants/app_colors.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;

  const CustomAppBar({
    super.key,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: const Text(
        "StepGreen",
        style: TextStyle(color: Colors.white),
      ),
      centerTitle: true,
      backgroundColor: AppColors.primaryGreen,
      foregroundColor: Colors.white,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
