import 'package:flutter/material.dart';
import '../models/exercise_model.dart';
import '../models/activity_log_model.dart';
import '../services/api_service.dart';
import '../services/preferences_service.dart';

class ActivityLogController extends ChangeNotifier {
  final ApiService _apiService;
  final PreferencesService _prefsService;

  List<Exercise> _exercises = [];
  List<Exercise> get exercises => _exercises;

  List<Exercise> _searchResults = [];
  List<Exercise> get searchResults => _searchResults;

  List<ActivityLog> _activityLogs = [];
  List<ActivityLog> get activityLogs => _activityLogs;

  double _todayCaloriesBurned = 0.0;
  double get todayCaloriesBurned => _todayCaloriesBurned;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  ActivityLogController({
    required ApiService apiService,
    required PreferencesService prefsService,
  })  : _apiService = apiService,
        _prefsService = prefsService {
    init();
  }

  Future<void> init() async {
    _isLoading = true;
    notifyListeners();
    await loadExercises();
    await loadLogs();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadExercises() async {
    try {
      _exercises = await _apiService.getAllExercises();
      _searchResults = List.from(_exercises);
    } catch (e) {
      debugPrint('Error loading exercises: $e');
    }
  }

  Future<void> searchExercises(String query) async {
    if (query.trim().isEmpty) {
      _searchResults = List.from(_exercises);
    } else {
      try {
        _searchResults = await _apiService.searchExercises(query);
      } catch (e) {
        debugPrint('Error searching exercises: $e');
      }
    }
    notifyListeners();
  }

  Future<void> loadLogs() async {
    final int? userId = _prefsService.getCurrentUserId();
    if (userId == null) return;
    try {
      _activityLogs = await _apiService.getActivityLogs(userId);
      final todayStr = DateTime.now().toIso8601String().split('T').first;
      _todayCaloriesBurned = await _apiService.getDailyCaloriesBurned(userId, todayStr);
    } catch (e) {
      debugPrint('Error loading activity logs: $e');
    }
    notifyListeners();
  }

  Future<void> logWorkout({
    required Exercise exercise,
    required int durationMinutes,
  }) async {
    final int? userId = _prefsService.getCurrentUserId();
    if (userId == null) return;
    try {
      final double burned = durationMinutes * exercise.caloriesPerMinute;
      final now = DateTime.now();
      // Format: yyyy-MM-dd HH:mm
      final String formattedDateTime = 
          '${now.toIso8601String().split('T').first} ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

      final log = ActivityLog(
        userId: userId,
        exerciseId: exercise.id!,
        name: exercise.name,
        category: exercise.category,
        durationMinutes: durationMinutes,
        caloriesBurned: burned,
        dateTime: formattedDateTime,
      );

      await _apiService.insertActivityLog(log);
      await loadLogs();
    } catch (e) {
      debugPrint('Error logging workout: $e');
    }
  }

  Future<void> removeLog(int logId) async {
    final int? userId = _prefsService.getCurrentUserId();
    if (userId == null) return;
    try {
      await _apiService.deleteActivityLog(logId, userId);
      await loadLogs();
    } catch (e) {
      debugPrint('Error deleting workout log: $e');
    }
  }
}
