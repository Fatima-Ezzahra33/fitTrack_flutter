/// FitTrack : Navigation controller
///
/// Manages the active tab index for the BottomNavigationBar
/// in the main shell. Uses ChangeNotifier for Provider integration.
library;
import 'package:flutter/foundation.dart';

class NavigationController extends ChangeNotifier {
  int _currentIndex = 0;

  /// The currently selected tab index (0–4).
  int get currentIndex => _currentIndex;

  /// Switch to a specific tab.
  void setTab(int index) {
    if (index < 0 || index > 4) return;
    if (_currentIndex == index) return;
    _currentIndex = index;
    notifyListeners();
  }

  /// Reset to the home tab.
  void resetToHome() {
    setTab(0);
  }
}
