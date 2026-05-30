/// FitTrack : Meal (Food Catalog) data model
///
/// Represents a pre-populated or custom food item in the catalog.
/// Displays nutritional values per 100g.
class Meal {
  final int? id;
  final String name;
  final double caloriesPer100g;
  final double proteinsPer100g;
  final double carbsPer100g;
  final double fatsPer100g;
  final String? imageUrl;

  const Meal({
    this.id,
    required this.name,
    required this.caloriesPer100g,
    required this.proteinsPer100g,
    required this.carbsPer100g,
    required this.fatsPer100g,
    this.imageUrl,
  });

  factory Meal.fromJson(Map<String, dynamic> json) {
    return Meal(
      id: json['id'] as int?,
      name: json['name'] as String,
      caloriesPer100g: (json['calories_per_100g'] as num).toDouble(),
      proteinsPer100g: (json['proteins_per_100g'] as num).toDouble(),
      carbsPer100g: (json['carbs_per_100g'] as num).toDouble(),
      fatsPer100g: (json['fats_per_100g'] as num).toDouble(),
      imageUrl: json['image_url'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'calories_per_100g': caloriesPer100g,
      'proteins_per_100g': proteinsPer100g,
      'carbs_per_100g': carbsPer100g,
      'fats_per_100g': fatsPer100g,
      'image_url': imageUrl,
    };
  }

  Meal copyWith({
    int? id,
    String? name,
    double? caloriesPer100g,
    double? proteinsPer100g,
    double? carbsPer100g,
    double? fatsPer100g,
    String? imageUrl,
  }) {
    return Meal(
      id: id ?? this.id,
      name: name ?? this.name,
      caloriesPer100g: caloriesPer100g ?? this.caloriesPer100g,
      proteinsPer100g: proteinsPer100g ?? this.proteinsPer100g,
      carbsPer100g: carbsPer100g ?? this.carbsPer100g,
      fatsPer100g: fatsPer100g ?? this.fatsPer100g,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }

  @override
  String toString() =>
      'Meal(id: $id, name: $name, caloriesPer100g: $caloriesPer100g)';
}
