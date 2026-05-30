import 'dart:convert';

/// FitTrack : ReadyMeal data model
///
/// Represents a recipe / prepared meal containing multiple ingredients.
class ReadyMeal {
  final int? id;
  final String name;
  final String category; // breakfast, lunch, dinner, snack
  final double totalCalories;
  final String? imageUrl;
  final List<String> ingredients;

  const ReadyMeal({
    this.id,
    required this.name,
    required this.category,
    required this.totalCalories,
    this.imageUrl,
    required this.ingredients,
  });

  factory ReadyMeal.fromJson(Map<String, dynamic> json) {
    List<String> ingredientsList = [];
    if (json['ingredients'] != null) {
      try {
        final decoded = jsonDecode(json['ingredients'] as String);
        if (decoded is List) {
          ingredientsList = decoded.map((e) => e.toString()).toList();
        }
      } catch (e) {
        ingredientsList = [];
      }
    }
    return ReadyMeal(
      id: json['id'] as int?,
      name: json['name'] as String,
      category: json['category'] as String,
      totalCalories: (json['total_calories'] as num).toDouble(),
      imageUrl: json['image_url'] as String?,
      ingredients: ingredientsList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'category': category,
      'total_calories': totalCalories,
      'image_url': imageUrl,
      'ingredients': jsonEncode(ingredients),
    };
  }
}
