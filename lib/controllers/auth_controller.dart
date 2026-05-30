/// FitTrack : Authentication controller
///
/// Handles multi-step registration (3 screens), login with SQLite
/// validation, and session management. Passwords are hashed with
/// SHA-256 before storage.
library;
import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';

import '../models/user_model.dart';
import '../services/database_service.dart';
import '../services/preferences_service.dart';

class AuthController extends ChangeNotifier {
  final DatabaseService _dbService;
  final PreferencesService _prefsService;

  AuthController({
    required this._dbService,
    required PreferencesService prefsService,
  })  : _prefsService = prefsService;

  // ── State ─────────────────────────────────────────────────────────
  User? _currentUser;
  bool _isLoading = false;
  String? _error;
  int _currentStep = 0;

  // ── Registration form data (accumulated across 3 steps) ───────────
  String _firstName = '';
  String _lastName = '';
  String _email = '';
  String _password = '';
  String? _phoneNumber;
  DateTime? _dateOfBirth;
  String? _gender;
  double? _height;
  double? _weight;
  String? _goalType;
  double? _goalWeight;

  // ── Getters ───────────────────────────────────────────────────────
  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get currentStep => _currentStep;
  bool get isLoggedIn => _currentUser != null;

  // ════════════════════════════════════════════════════════════════════
  // SESSION MANAGEMENT
  // ════════════════════════════════════════════════════════════════════

  /// Check if a user session exists from a previous app launch.
  /// Call this on app startup to auto-login.
  Future<bool> checkSession() async {
    final int? userId = _prefsService.getCurrentUserId();
    if (userId == null) return false;

    try {
      _currentUser = await _dbService.getUserById(userId);
      if (_currentUser != null) {
        notifyListeners();
        return true;
      }
    } catch (e) {
      debugPrint('Session check failed: $e');
    }
    return false;
  }

  // ════════════════════════════════════════════════════════════════════
  // LOGIN
  // ════════════════════════════════════════════════════════════════════

  /// Authenticate a user with email and password.
  Future<bool> login(String email, String password) async {
    _setLoading(true);
    _clearError();

    try {
      final String hash = _hashPassword(password);
      final User? user = await _dbService.authenticateUser(email, hash);

      if (user == null) {
        _error = 'Invalid email or password';
        _setLoading(false);
        return false;
      }

      _currentUser = user;
      await _prefsService.setCurrentUserId(user.id!);
      _setLoading(false);
      return true;
    } catch (e) {
      _error = 'Login failed: $e';
      _setLoading(false);
      return false;
    }
  }

  /// Log out the current user and clear the session.
  Future<void> logout() async {
    _currentUser = null;
    await _prefsService.clearCurrentUser();
    _resetRegistrationData();
    notifyListeners();
  }

  // ════════════════════════════════════════════════════════════════════
  // MULTI-STEP REGISTRATION
  // ════════════════════════════════════════════════════════════════════

  /// Set the current registration step (0, 1, 2).
  void setStep(int step) {
    if (step >= 0 && step <= 2) {
      _currentStep = step;
      _clearError();
      notifyListeners();
    }
  }

  /// Step 1: Save identity data.
  /// Returns true if validation passes and email does not exist.
  Future<bool> saveStep1({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    _clearError();

    final String trimmedEmail = email.trim().toLowerCase();

    try {
      final bool exists = await _dbService.emailExists(trimmedEmail);
      if (exists) {
        _error = 'An account with this email already exists';
        _setLoading(false);
        return false;
      }

      _firstName = firstName.trim();
      _lastName = lastName.trim();
      _email = trimmedEmail;
      _password = password;
      
      _setLoading(false);
      return true;
    } catch (e) {
      _error = 'Validation failed: $e';
      _setLoading(false);
      return false;
    }
  }

  /// Step 2: Save profile data.
  /// Returns true if validation passes.
  bool saveStep2({
    DateTime? dateOfBirth,
    String? gender,
    double? height,
    double? weight,
    String? phoneNumber,
  }) {
    _dateOfBirth = dateOfBirth;
    _gender = gender;
    _height = height;
    _weight = weight;
    _phoneNumber = phoneNumber?.trim();
    return true;
  }

  /// Step 3: Save goal data.
  /// Returns true if validation passes.
  bool saveStep3({
    String? goalType,
    double? goalWeight,
  }) {
    _goalType = goalType;
    _goalWeight = goalWeight;
    return true;
  }

  /// Complete registration: hash password, insert user into DB,
  /// and start the session.
  Future<bool> register() async {
    _setLoading(true);
    _clearError();

    try {
      // Check if email already exists
      final bool exists = await _dbService.emailExists(_email);
      if (exists) {
        _error = 'An account with this email already exists';
        _setLoading(false);
        return false;
      }

      final DateTime now = DateTime.now();
      final User newUser = User(
        firstName: _firstName,
        lastName: _lastName,
        email: _email,
        passwordHash: _hashPassword(_password),
        phoneNumber: _phoneNumber,
        dateOfBirth: _dateOfBirth,
        gender: _gender,
        height: _height,
        weight: _weight,
        goalWeight: _goalWeight,
        goalType: _goalType,
        themePreference: 'system',
        createdAt: now,
        updatedAt: now,
      );

      final int userId = await _dbService.insertUser(newUser);
      _currentUser = newUser.copyWith(id: userId);
      await _prefsService.setCurrentUserId(userId);

      _resetRegistrationData();
      _setLoading(false);
      return true;
    } catch (e) {
      _error = 'Registration failed: $e';
      _setLoading(false);
      return false;
    }
  }

  /// Update the current user's profile details in SQLite and local state.
  Future<bool> updateUser(User user) async {
    try {
      await _dbService.updateUser(user);
      _currentUser = user;
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Failed to update user: $e');
      return false;
    }
  }

  // ════════════════════════════════════════════════════════════════════
  // HELPERS
  // ════════════════════════════════════════════════════════════════════

  /// Hash a password with SHA-256.
  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    return sha256.convert(bytes).toString();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
  }

  void _resetRegistrationData() {
    _currentStep = 0;
    _firstName = '';
    _lastName = '';
    _email = '';
    _password = '';
    _phoneNumber = null;
    _dateOfBirth = null;
    _gender = null;
    _height = null;
    _weight = null;
    _goalType = null;
    _goalWeight = null;
  }
}
