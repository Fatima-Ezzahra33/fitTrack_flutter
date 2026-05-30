/// FitTrack : Theme controller
///
/// Manages the app's ThemeMode (light/dark/system) and persists
/// the user's preference via PreferencesService.
library;
import 'package:flutter/material.dart';

import '../services/preferences_service.dart';

class ThemeController extends ChangeNotifier {
  final PreferencesService _prefsService;
  late ThemeMode _themeMode;

  ThemeController({required this._prefsService}) {
    _themeMode = _prefsService.getThemeMode();
  }

  /// Current theme mode.
  ThemeMode get themeMode => _themeMode;

  /// Whether dark mode is currently active.
  bool get isDarkMode => _themeMode == ThemeMode.dark;

  /// Set a specific theme mode and persist it.
  Future<void> setThemeMode(ThemeMode mode) async {
    if (_themeMode == mode) return;
    _themeMode = mode;
    await _prefsService.setThemeMode(mode);
    notifyListeners();
  }

  /// Toggle between light and dark mode.
  Future<void> toggleTheme() async {
    final ThemeMode newMode =
        _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    await setThemeMode(newMode);
  }
}
