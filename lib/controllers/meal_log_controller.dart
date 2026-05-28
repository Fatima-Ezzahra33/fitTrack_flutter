import 'package:flutter/material.dart';
import '../models/meal_log_model.dart';
import '../models/ready_meal_model.dart';
import '../models/food_model.dart';
import '../services/database_service.dart';
import '../services/preferences_service.dart';

class MealLogController extends ChangeNotifier {
  final DatabaseService _dbService;
  final PreferencesService _prefsService;

  List<MealLog> _logs = [];
  List<MealLog> get logs => _logs;

  List<ReadyMeal> _readyMeals = [];
  List<ReadyMeal> get readyMeals => _readyMeals;

  double _dailyCaloriesGoal = 2000.0;
  double get dailyCaloriesGoal => _dailyCaloriesGoal;

  double _todayCalories = 0.0;
  double get todayCalories => _todayCalories;

  double _todayProteins = 0.0;
  double get todayProteins => _todayProteins;

  double _todayCarbs = 0.0;
  double get todayCarbs => _todayCarbs;

  double _todayFats = 0.0;
  double get todayFats => _todayFats;

  String _selectedDate = DateTime.now().toIso8601String().split('T').first;
  String get selectedDate => _selectedDate;

  Map<String, double> _weeklyCaloriesData = {};
  Map<String, double> get weeklyCaloriesData => _weeklyCaloriesData;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  MealLogController({
    required DatabaseService dbService,
    required PreferencesService prefsService,
  })  : _dbService = dbService,
        _prefsService = prefsService {
    init();
  }

  Future<void> init() async {
    _isLoading = true;
    notifyListeners();
    await loadReadyMeals();
    await loadLogsForDate(_selectedDate);
    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadReadyMeals() async {
    try {
      _readyMeals = await _dbService.getAllReadyMeals();
    } catch (e) {
      debugPrint('Error loading ready meals: $e');
    }
  }

  Future<void> loadLogsForDate(String date) async {
    _selectedDate = date;
    final int? userId = _prefsService.getCurrentUserId();
    if (userId == null) return;
    try {
      _logs = await _dbService.getMealLogsForDate(userId, date);
      _calculateTodayNutrientTotals();
      _weeklyCaloriesData = await _dbService.getWeeklyCaloriesData(userId, date);
    } catch (e) {
      debugPrint('Error loading meal logs: $e');
    }
    notifyListeners();
  }

  void changeDate(String date) {
    loadLogsForDate(date);
  }

  void _calculateTodayNutrientTotals() {
    _todayCalories = 0;
    _todayProteins = 0;
    _todayCarbs = 0;
    _todayFats = 0;
    for (final log in _logs) {
      _todayCalories += log.calories;
      _todayProteins += log.proteins;
      _todayCarbs += log.carbs;
      _todayFats += log.fats;
    }
  }

  Future<void> logFoodPortion({
    required Food food,
    required double grams,
    required String mealType,
  }) async {
    final int? userId = _prefsService.getCurrentUserId();
    if (userId == null) return;
    try {
      final double cal = (food.caloriesPer100g * grams) / 100;
      final double prot = (food.proteinsPer100g * grams) / 100;
      final double carb = (food.carbsPer100g * grams) / 100;
      final double fat = (food.fatsPer100g * grams) / 100;

      final log = MealLog(
        userId: userId,
        foodId: food.id,
        name: food.name,
        grams: grams,
        calories: double.parse(cal.toStringAsFixed(1)),
        proteins: double.parse(prot.toStringAsFixed(1)),
        carbs: double.parse(carb.toStringAsFixed(1)),
        fats: double.parse(fat.toStringAsFixed(1)),
        mealType: mealType,
        date: _selectedDate,
      );

      await _dbService.insertMealLog(log);
      await loadLogsForDate(_selectedDate);
    } catch (e) {
      debugPrint('Error logging food: $e');
    }
  }

  Future<void> logReadyMeal({
    required ReadyMeal meal,
    required String mealType,
  }) async {
    final int? userId = _prefsService.getCurrentUserId();
    if (userId == null) return;
    try {
      // Create a meal log entry representing the recipe
      final log = MealLog(
        userId: userId,
        readyMealId: meal.id,
        name: meal.name,
        grams: 300, // default portion for ready recipe meals
        calories: meal.totalCalories,
        proteins: 18.0, // estimated macro totals for recipes
        carbs: 45.0,
        fats: 12.0,
        mealType: mealType,
        date: _selectedDate,
      );

      await _dbService.insertMealLog(log);
      await loadLogsForDate(_selectedDate);
    } catch (e) {
      debugPrint('Error logging recipe: $e');
    }
  }

  Future<void> removeLog(int logId) async {
    final int? userId = _prefsService.getCurrentUserId();
    if (userId == null) return;
    try {
      await _dbService.deleteMealLog(logId, userId);
      await loadLogsForDate(_selectedDate);
    } catch (e) {
      debugPrint('Error removing meal log: $e');
    }
  }
}
