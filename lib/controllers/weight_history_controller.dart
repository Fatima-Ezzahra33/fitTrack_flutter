import 'package:flutter/material.dart';
import '../models/weight_entry_model.dart';
import '../services/api_service.dart';

class WeightHistoryController extends ChangeNotifier {
  final ApiService _apiService;

  List<WeightEntry> _weightEntries = [];
  List<WeightEntry> get weightEntries => _weightEntries;

  WeightEntry? _latestWeight;
  WeightEntry? get latestWeight => _latestWeight;

  WeightEntry? _previousWeight;
  WeightEntry? get previousWeight => _previousWeight;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String _selectedRange = '30d'; // 30d, 3m, 6m
  String get selectedRange => _selectedRange;

  WeightHistoryController({required ApiService apiService}) : _apiService = apiService;

  Future<void> loadWeightHistory(int userId) async {
    _isLoading = true;
    notifyListeners();
    try {
      _weightEntries = await _apiService.getWeightEntriesByUser(userId);
      _latestWeight = await _apiService.getLatestWeight(userId);
      _previousWeight = await _apiService.getPreviousWeight(userId);
    } catch (e) {
      debugPrint('Error loading weight history: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void changeRange(String range) {
    _selectedRange = range;
    notifyListeners();
  }

  /// Helper to get trend icon
  String getTrendArrow() {
    if (_latestWeight == null || _previousWeight == null) return '➡️';
    final diff = _latestWeight!.weight - _previousWeight!.weight;
    if (diff > 0.05) return '↗️';
    if (diff < -0.05) return '↘️';
    return '➡️';
  }

  Future<void> recordWeight({
    required int userId,
    required double weight,
    required String date,
    String? note,
  }) async {
    try {
      final entry = WeightEntry(
        userId: userId,
        weight: weight,
        date: DateTime.parse(date),
        note: note,
      );
      await _apiService.insertWeightEntry(entry);
      await loadWeightHistory(userId);
    } catch (e) {
      debugPrint('Error recording weight: $e');
    }
  }

  Future<void> removeWeightEntry(int entryId, int userId) async {
    try {
      await _apiService.deleteWeightEntry(entryId);
      await loadWeightHistory(userId);
    } catch (e) {
      debugPrint('Error deleting weight entry: $e');
    }
  }
}
