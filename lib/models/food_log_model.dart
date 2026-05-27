/// FitTrack — FoodLog data model
///
/// Represents what the user actually ate today.
/// Nutritional values are auto-calculated from catalog and grams eaten.
class FoodLog {
  final int? id;
  final int mealId;
  final String mealType; // Breakfast, Snack, Lunch, Dinner, Supper
  final String date; // yyyy-MM-dd
  final double gramsEaten;
  final double totalCalories;
  final double totalProteins;
  final double totalCarbs;
  final double totalFats;

  // Optional fields for easy joining
  final String? mealName;
  final String? imageUrl;

  const FoodLog({
    this.id,
    required this.mealId,
    required this.mealType,
    required this.date,
    required this.gramsEaten,
    required this.totalCalories,
    required this.totalProteins,
    required this.totalCarbs,
    required this.totalFats,
    this.mealName,
    this.imageUrl,
  });

  /// Factory helper that automatically calculates totals based on a Meal and grams
  factory FoodLog.create({
    int? id,
    required int mealId,
    required String mealName,
    required double caloriesPer100g,
    required double proteinsPer100g,
    required double carbsPer100g,
    required double fatsPer100g,
    required String mealType,
    required String date,
    required double gramsEaten,
    String? imageUrl,
  }) {
    return FoodLog(
      id: id,
      mealId: mealId,
      mealType: mealType,
      date: date,
      gramsEaten: gramsEaten,
      totalCalories: double.parse(((caloriesPer100g * gramsEaten) / 100).toStringAsFixed(1)),
      totalProteins: double.parse(((proteinsPer100g * gramsEaten) / 100).toStringAsFixed(1)),
      totalCarbs: double.parse(((carbsPer100g * gramsEaten) / 100).toStringAsFixed(1)),
      totalFats: double.parse(((fatsPer100g * gramsEaten) / 100).toStringAsFixed(1)),
      mealName: mealName,
      imageUrl: imageUrl,
    );
  }

  factory FoodLog.fromJson(Map<String, dynamic> json) {
    return FoodLog(
      id: json['id'] as int?,
      mealId: json['meal_id'] as int,
      mealType: json['meal_type'] as String,
      date: json['date'] as String,
      gramsEaten: (json['grams_eaten'] as num).toDouble(),
      totalCalories: (json['total_calories'] as num).toDouble(),
      totalProteins: (json['total_proteins'] as num).toDouble(),
      totalCarbs: (json['total_carbs'] as num).toDouble(),
      totalFats: (json['total_fats'] as num).toDouble(),
      mealName: json['meal_name'] as String?,
      imageUrl: json['image_url'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'meal_id': mealId,
      'meal_type': mealType,
      'date': date,
      'grams_eaten': gramsEaten,
      'total_calories': totalCalories,
      'total_proteins': totalProteins,
      'total_carbs': totalCarbs,
      'total_fats': totalFats,
    };
  }

  @override
  String toString() =>
      'FoodLog(id: $id, mealId: $mealId, type: $mealType, date: $date, calories: $totalCalories)';
}
