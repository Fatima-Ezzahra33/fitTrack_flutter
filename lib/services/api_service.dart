library;
import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:flutter/foundation.dart' show kIsWeb;

import '../models/comparison_model.dart';
import '../models/exercise_model.dart';
import '../models/food_model.dart';
import '../models/ready_meal_model.dart';
import '../models/meal_log_model.dart';
import '../models/activity_log_model.dart';
import '../models/user_model.dart';
import '../models/weight_entry_model.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  static String get baseUrl {
    if (kIsWeb) {
      return 'http://localhost:3000';
    } else {
      // 192.168.1.140 is your PC's local Wi-Fi IP address.
      // This allows both Physical Phones and Emulators to connect to json-server!
      return 'http://192.168.1.140:3000';
    }
  }

  Future<void> initDatabase() async {
    // NOOP for HTTP API
  }

  Future<void> close() async {
    // NOOP for HTTP API
  }

  // Helper method for GET requests
  Future<dynamic> _get(String endpoint) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/$endpoint')).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      print('HTTP GET ${response.statusCode}: $endpoint');
    } catch (e) {
      print('HTTP GET Error ($endpoint): $e');
    }
    return null;
  }

  // Helper method for POST requests
  Future<dynamic> _post(String endpoint, Map<String, dynamic> body) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/$endpoint'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      ).timeout(const Duration(seconds: 10));
      if (response.statusCode == 201 || response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      print('HTTP POST ${response.statusCode}: $endpoint');
    } catch (e) {
      print('HTTP POST Error ($endpoint): $e');
    }
    return null;
  }

  // Helper method for PUT requests
  Future<dynamic> _put(String endpoint, Map<String, dynamic> body) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/$endpoint'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      ).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      print('HTTP PUT ${response.statusCode}: $endpoint');
    } catch (e) {
      print('HTTP PUT Error ($endpoint): $e');
    }
    return null;
  }

  // Helper method for DELETE requests
  Future<bool> _delete(String endpoint) async {
    try {
      final response = await http.delete(Uri.parse('$baseUrl/$endpoint')).timeout(const Duration(seconds: 10));
      return response.statusCode == 200;
    } catch (e) {
      print('HTTP DELETE Error ($endpoint): $e');
    }
    return false;
  }

  // ════════════════════════════════════════════════════════════════════
  // USERS CRUD
  // ════════════════════════════════════════════════════════════════════

  Future<int> insertUser(User user) async {
    final body = user.toJson();
    final newId = DateTime.now().millisecondsSinceEpoch;
    body['id'] = newId;
    final res = await _post('users', body);
    if (res != null && res['id'] != null) {
      return int.tryParse(res['id'].toString()) ?? newId;
    }
    return newId;
  }

  Future<User?> getUserByEmail(String email) async {
    final res = await _get('users?email=$email');
    if (res != null && (res as List).isNotEmpty) {
      return User.fromJson(res.first);
    }
    return null;
  }

  Future<User?> getUserById(int id) async {
    final res = await _get('users/$id');
    if (res != null) {
      return User.fromJson(res);
    }
    return null;
  }

  Future<User?> authenticateUser(String email, String passwordHash) async {
    final res = await _get('users?email=$email&password_hash=$passwordHash');
    if (res != null && (res as List).isNotEmpty) {
      return User.fromJson(res.first);
    }
    return null;
  }

  Future<int> updateUser(User user) async {
    final res = await _put('users/${user.id}', user.toJson());
    return res != null ? 1 : 0;
  }

  Future<bool> emailExists(String email) async {
    final res = await getUserByEmail(email);
    return res != null;
  }

  // ════════════════════════════════════════════════════════════════════
  // EXERCISES CRUD & LOGS
  // ════════════════════════════════════════════════════════════════════

  Future<List<Exercise>> getAllExercises() async {
    final res = await _get('exercises');
    if (res != null) {
      return (res as List).map((e) => Exercise.fromJson(e)).toList();
    }
    return [];
  }

  Future<List<Exercise>> searchExercises(String query) async {
    final res = await _get('exercises?q=$query');
    if (res != null) {
      return (res as List).map((e) => Exercise.fromJson(e)).toList();
    }
    return [];
  }

  Future<List<ActivityLog>> getActivityLogs(int userId) async {
    final res = await _get('activity_logs?user_id=$userId');
    if (res != null) {
      final list = (res as List).map((e) => ActivityLog.fromJson(e)).toList();
      list.sort((a, b) => b.dateTime.compareTo(a.dateTime));
      return list;
    }
    return [];
  }

  Future<List<ActivityLog>> getActivityLogsForDate(int userId, String date) async {
    final logs = await getActivityLogs(userId);
    return logs.where((log) => log.dateTime.startsWith(date)).toList();
  }

  Future<int> insertActivityLog(ActivityLog log) async {
    final body = log.toJson();
    final newId = DateTime.now().millisecondsSinceEpoch;
    body['id'] = newId;
    final res = await _post('activity_logs', body);
    if (res != null && res['id'] != null) {
      return int.tryParse(res['id'].toString()) ?? newId;
    }
    return newId;
  }

  Future<int> deleteActivityLog(int id, int userId) async {
    final success = await _delete('activity_logs/$id');
    return success ? 1 : 0;
  }

  Future<double> getDailyCaloriesBurned(int userId, String date) async {
    final logs = await getActivityLogsForDate(userId, date);
    return logs.fold<double>(0.0, (sum, item) => sum + item.caloriesBurned);
  }

  // ════════════════════════════════════════════════════════════════════
  // WEIGHT ENTRIES CRUD
  // ════════════════════════════════════════════════════════════════════

  Future<int> insertWeightEntry(WeightEntry entry) async {
    final body = entry.toJson();
    final newId = DateTime.now().millisecondsSinceEpoch;
    body['id'] = newId;
    final res = await _post('weight_entries', body);
    if (res != null && res['id'] != null) {
      return int.tryParse(res['id'].toString()) ?? newId;
    }
    return newId;
  }

  Future<int> deleteWeightEntry(int id) async {
    final success = await _delete('weight_entries/$id');
    return success ? 1 : 0;
  }

  Future<List<WeightEntry>> getWeightEntriesByUser(int userId) async {
    final res = await _get('weight_entries?user_id=$userId');
    if (res != null) {
      final list = (res as List).map((e) => WeightEntry.fromJson(e)).toList();
      list.sort((a, b) => b.date.compareTo(a.date));
      return list;
    }
    return [];
  }

  Future<WeightEntry?> getLatestWeight(int userId) async {
    final list = await getWeightEntriesByUser(userId);
    if (list.isNotEmpty) return list.first;
    return null;
  }

  Future<WeightEntry?> getPreviousWeight(int userId) async {
    final list = await getWeightEntriesByUser(userId);
    if (list.length > 1) return list[1];
    return null;
  }

  // ════════════════════════════════════════════════════════════════════
  // FOODS & READY MEALS & MEAL LOGS
  // ════════════════════════════════════════════════════════════════════

  Future<List<Food>> getAllFoods() async {
    final res = await _get('foods');
    if (res != null) {
      final list = (res as List).map((e) => Food.fromJson(e)).toList();
      list.sort((a, b) => a.name.compareTo(b.name));
      return list;
    }
    return [];
  }

  Future<List<Food>> searchFoods(String query) async {
    final res = await _get('foods?q=$query');
    if (res != null) {
      final list = (res as List).map((e) => Food.fromJson(e)).toList();
      list.sort((a, b) => a.name.compareTo(b.name));
      return list;
    }
    return [];
  }

  Future<int> insertFood(Food food) async {
    final body = food.toJson();
    final newId = DateTime.now().millisecondsSinceEpoch;
    body['id'] = newId;
    final res = await _post('foods', body);
    if (res != null && res['id'] != null) {
      return int.tryParse(res['id'].toString()) ?? newId;
    }
    return newId;
  }

  Future<List<ReadyMeal>> getAllReadyMeals() async {
    final res = await _get('ready_meals');
    if (res != null) {
      final list = (res as List).map((e) => ReadyMeal.fromJson(e)).toList();
      list.sort((a, b) => a.name.compareTo(b.name));
      return list;
    }
    return [];
  }

  Future<List<MealLog>> getMealLogsForDate(int userId, String date) async {
    final res = await _get('meal_logs?user_id=$userId&date=$date');
    if (res != null) {
      return (res as List).map((e) => MealLog.fromJson(e)).toList();
    }
    return [];
  }

  Future<int> insertMealLog(MealLog log) async {
    final body = log.toJson();
    final newId = DateTime.now().millisecondsSinceEpoch;
    body['id'] = newId;
    final res = await _post('meal_logs', body);
    if (res != null && res['id'] != null) {
      return int.tryParse(res['id'].toString()) ?? newId;
    }
    return newId;
  }

  Future<int> deleteMealLog(int id, int userId) async {
    final success = await _delete('meal_logs/$id');
    return success ? 1 : 0;
  }

  Future<double> getDailyCaloriesConsumed(int userId, String date) async {
    final logs = await getMealLogsForDate(userId, date);
    return logs.fold<double>(0.0, (sum, item) => sum + item.calories);
  }

  Future<Map<String, double>> getWeeklyCaloriesData(int userId, String selectDateStr) async {
    final DateTime targetDate = DateTime.parse(selectDateStr);
    final Map<String, double> result = {};

    for (int i = 6; i >= 0; i--) {
      final DateTime day = targetDate.subtract(Duration(days: i));
      final String dateStr = day.toIso8601String().split('T').first;
      final logs = await getMealLogsForDate(userId, dateStr);
      final double cal = logs.fold<double>(0.0, (sum, item) => sum + item.calories);
      result[dateStr] = cal;
    }
    return result;
  }

  // ════════════════════════════════════════════════════════════════════
  // PROGRESS COMPARISONS CRUD
  // ════════════════════════════════════════════════════════════════════

  Future<int> insertComparison(ProgressComparison comparison) async {
    final body = comparison.toJson();
    final newId = DateTime.now().millisecondsSinceEpoch;
    body['id'] = newId;
    final res = await _post('progress_comparisons', body);
    if (res != null && res['id'] != null) {
      return int.tryParse(res['id'].toString()) ?? newId;
    }
    return newId;
  }

  Future<List<ProgressComparison>> getComparisonsByUser(int userId) async {
    final res = await _get('progress_comparisons?user_id=$userId');
    if (res != null) {
      final list = (res as List).map((e) => ProgressComparison.fromJson(e)).toList();
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return list;
    }
    return [];
  }

  Future<int> deleteComparison(int id, int userId) async {
    final success = await _delete('progress_comparisons/$id');
    return success ? 1 : 0;
  }
}
