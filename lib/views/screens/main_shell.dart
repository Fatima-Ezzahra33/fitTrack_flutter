/// FitTrack — Main Application Shell
///
/// Implements the parent navigation frame. Houses the BottomNavigationBar and uses
/// an IndexedStack to render the 5 core tabs (Home, Activity, Search, Camera, Profile)
/// in order to preserve state across selections.
library;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../controllers/navigation_controller.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import 'tabs/activity_tab.dart';
import 'tabs/camera_tab.dart';
import 'tabs/home_tab.dart';
import 'tabs/profile_tab.dart';
import 'tabs/meals_tab.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  // Ordered screens matching navigation tabs
  final List<Widget> _tabs = const [
    HomeTab(),
    ActivityTab(),
    MealsTab(),
    CameraTab(),
    ProfileTab(),
  ];

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Consumer<NavigationController>(
      builder: (context, navController, child) {
        return Scaffold(
          body: IndexedStack(
            index: navController.currentIndex,
            children: _tabs,
          ),
          bottomNavigationBar: Container(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: BottomNavigationBar(
              currentIndex: navController.currentIndex,
              onTap: navController.setTab,
              type: BottomNavigationBarType.fixed,
              backgroundColor: isDark ? AppColors.navBarDark : AppColors.navBarLight,
              selectedItemColor: AppColors.primary,
              unselectedItemColor: AppColors.navIconInactive,
              selectedLabelStyle: GoogleFonts.inter(
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
              unselectedLabelStyle: GoogleFonts.inter(
                fontWeight: FontWeight.w500,
                fontSize: 11,
              ),
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.home_rounded),
                  activeIcon: Icon(Icons.home_rounded),
                  label: AppStrings.homeTab,
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.bar_chart_rounded),
                  activeIcon: Icon(Icons.bar_chart_rounded),
                  label: AppStrings.activityTab,
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.restaurant_menu_rounded),
                  activeIcon: Icon(Icons.restaurant_menu_rounded),
                  label: 'Repas',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.camera_alt_rounded),
                  activeIcon: Icon(Icons.camera_alt_rounded),
                  label: AppStrings.cameraTab,
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.person_rounded),
                  activeIcon: Icon(Icons.person_rounded),
                  label: AppStrings.profileTab,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
