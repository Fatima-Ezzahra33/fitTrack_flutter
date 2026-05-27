/// FitTrack — Preferences service (SharedPreferences)
///
/// Wraps SharedPreferences for app-level settings:
/// first-launch flag, theme mode, and logged-in user session.
library;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PreferencesService {
  SharedPreferences? _prefs;

  static const String _keyFirstLaunch = 'first_launch';
  static const String _keyThemeMode = 'theme_mode';
  static const String _keyCurrentUserId = 'current_user_id';

  /// Initialize SharedPreferences — call from main.dart
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  SharedPreferences get _safePrefs {
    if (_prefs == null) {
      throw StateError(
        'PreferencesService not initialized. Call init() first.',
      );
    }
    return _prefs!;
  }

  // ── First launch ──────────────────────────────────────────────────

  /// Returns true on the very first app launch (before onboarding).
  bool isFirstLaunch() {
    return _safePrefs.getBool(_keyFirstLaunch) ?? true;
  }

  /// Mark onboarding as completed.
  Future<void> setFirstLaunchComplete() async {
    await _safePrefs.setBool(_keyFirstLaunch, false);
  }

  // ── Theme mode ────────────────────────────────────────────────────

  /// Get the persisted theme mode. Defaults to ThemeMode.system.
  ThemeMode getThemeMode() {
    final String? value = _safePrefs.getString(_keyThemeMode);
    switch (value) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  /// Persist the theme mode selection.
  Future<void> setThemeMode(ThemeMode mode) async {
    String value;
    switch (mode) {
      case ThemeMode.light:
        value = 'light';
      case ThemeMode.dark:
        value = 'dark';
      case ThemeMode.system:
        value = 'system';
    }
    await _safePrefs.setString(_keyThemeMode, value);
  }

  // ── User session ──────────────────────────────────────────────────

  /// Get the ID of the currently logged-in user. Returns null if no session.
  int? getCurrentUserId() {
    final int? id = _safePrefs.getInt(_keyCurrentUserId);
    return id;
  }

  /// Persist the logged-in user ID.
  Future<void> setCurrentUserId(int userId) async {
    await _safePrefs.setInt(_keyCurrentUserId, userId);
  }

  /// Clear the user session (logout).
  Future<void> clearCurrentUser() async {
    await _safePrefs.remove(_keyCurrentUserId);
  }

  /// Check if a user is currently logged in.
  bool isLoggedIn() {
    return getCurrentUserId() != null;
  }
}
