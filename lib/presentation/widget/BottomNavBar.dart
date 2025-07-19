import 'package:crystal_navigation_bar/crystal_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:revobike/constants/app_colors.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return CrystalNavigationBar(
      marginR: const EdgeInsets.symmetric(vertical: 20, horizontal: 30),
      currentIndex: currentIndex,
      indicatorColor: Colors.transparent,
      backgroundColor: Colors.white,
      outlineBorderColor: Colors.transparent,
      splashColor: Colors.transparent,
      boxShadow: [
        BoxShadow(
          color: Colors.black,
          blurRadius: 10,
          offset: const Offset(0, 2),
        ),
      ],
      borderRadius: 20,
      onTap: onTap,
      items: [
        CrystalNavigationBarItem(
          icon: FontAwesomeIcons.house,
          selectedColor: AppColors.secondaryGreen,
          unselectedColor: Colors.grey,
          unselectedIcon: FontAwesomeIcons.house,
        ),
        CrystalNavigationBarItem(
          icon: FontAwesomeIcons.chargingStation,
          selectedColor: AppColors.secondaryGreen,
          unselectedColor: Colors.grey,
          unselectedIcon: FontAwesomeIcons.chargingStation,
        ),
        CrystalNavigationBarItem(
          icon: FontAwesomeIcons.clockRotateLeft,
          selectedColor: AppColors.secondaryGreen,
          unselectedColor: Colors.grey,
          unselectedIcon: FontAwesomeIcons.clockRotateLeft,
        ),
        CrystalNavigationBarItem(
          icon: FontAwesomeIcons.userGear,
          selectedColor: AppColors.secondaryGreen,
          unselectedColor: Colors.grey,
          unselectedIcon: FontAwesomeIcons.userGear,
        ),
      ],
    );
  }
}
