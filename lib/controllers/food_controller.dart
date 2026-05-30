import 'package:flutter/material.dart';
import '../models/food_model.dart';
import '../services/api_service.dart';

class FoodController extends ChangeNotifier {
  final ApiService _apiService;

  List<Food> _foods = [];
  List<Food> get foods => _foods;

  List<Food> _searchResults = [];
  List<Food> get searchResults => _searchResults;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  FoodController({required ApiService apiService}) : _apiService = apiService {
    loadAllFoods();
  }

  Future<void> loadAllFoods() async {
    _isLoading = true;
    notifyListeners();
    try {
      _foods = await _apiService.getAllFoods();
      _searchResults = List.from(_foods);
    } catch (e) {
      debugPrint('Error loading foods catalog: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> searchCatalog(String query) async {
    if (query.trim().isEmpty) {
      _searchResults = List.from(_foods);
    } else {
      try {
        _searchResults = await _apiService.searchFoods(query);
      } catch (e) {
        debugPrint('Error searching foods catalog: $e');
      }
    }
    notifyListeners();
  }

  Future<void> addCustomFood({
    required String name,
    required double cal,
    required double prot,
    required double carbs,
    required double fats,
    required String category,
  }) async {
    try {
      final custom = Food(
        name: name,
        caloriesPer100g: cal,
        proteinsPer100g: prot,
        carbsPer100g: carbs,
        fatsPer100g: fats,
        category: category,
      );
      await _apiService.insertFood(custom);
      await loadAllFoods();
    } catch (e) {
      debugPrint('Error adding custom food: $e');
    }
  }
}
