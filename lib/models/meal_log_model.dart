/// FitTrack : MealLog data model
///
/// Represents a logged meal entry consumed by the user on a specific date.
class MealLog {
  final int? id;
  final int userId;
  final int? foodId;
  final int? readyMealId;
  final String name;
  final double grams;
  final double calories;
  final double proteins;
  final double carbs;
  final double fats;
  final String mealType; // Breakfast, Lunch, Dinner, Snack
  final String date; // yyyy-MM-dd

  const MealLog({
    this.id,
    required this.userId,
    this.foodId,
    this.readyMealId,
    required this.name,
    required this.grams,
    required this.calories,
    required this.proteins,
    required this.carbs,
    required this.fats,
    required this.mealType,
    required this.date,
  });

  factory MealLog.fromJson(Map<String, dynamic> json) {
    return MealLog(
      id: json['id'] as int?,
      userId: json['user_id'] as int,
      foodId: json['food_id'] as int?,
      readyMealId: json['ready_meal_id'] as int?,
      name: json['name'] as String,
      grams: (json['grams'] as num).toDouble(),
      calories: (json['calories'] as num).toDouble(),
      proteins: (json['proteins'] as num).toDouble(),
      carbs: (json['carbs'] as num).toDouble(),
      fats: (json['fats'] as num).toDouble(),
      mealType: json['meal_type'] as String,
      date: json['date'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'user_id': userId,
      'food_id': foodId,
      'ready_meal_id': readyMealId,
      'name': name,
      'grams': grams,
      'calories': calories,
      'proteins': proteins,
      'carbs': carbs,
      'fats': fats,
      'meal_type': mealType,
      'date': date,
    };
  }
}
