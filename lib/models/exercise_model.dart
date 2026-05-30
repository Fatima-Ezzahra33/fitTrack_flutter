/// FitTrack : Exercise data model
///
/// Represents a single exercise with metadata such as category,
/// duration, calories per minute, and step-by-step instructions.
/// Steps are stored as a JSON-encoded string in SQLite.
library;
import 'dart:convert';

class Exercise {
  final int? id;
  final String name;
  final String category;
  final String description;
  final String? imageUrl;
  final int durationMinutes;
  final double caloriesPerMinute;
  final List<String> steps;

  const Exercise({
    this.id,
    required this.name,
    required this.category,
    required this.description,
    this.imageUrl,
    required this.durationMinutes,
    required this.caloriesPerMinute,
    required this.steps,
  });

  factory Exercise.fromJson(Map<String, dynamic> json) {
    List<String> parsedSteps = [];
    if (json['steps'] != null) {
      final stepsData = json['steps'];
      if (stepsData is String) {
        final decoded = jsonDecode(stepsData);
        parsedSteps = List<String>.from(decoded as List);
      } else if (stepsData is List) {
        parsedSteps = List<String>.from(stepsData);
      }
    }

    return Exercise(
      id: json['id'] as int?,
      name: json['name'] as String,
      category: json['category'] as String,
      description: json['description'] as String,
      imageUrl: json['image_url'] as String?,
      durationMinutes: json['duration_minutes'] as int,
      caloriesPerMinute: (json['calories_per_minute'] as num).toDouble(),
      steps: parsedSteps,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'category': category,
      'description': description,
      'image_url': imageUrl,
      'duration_minutes': durationMinutes,
      'calories_per_minute': caloriesPerMinute,
      'steps': jsonEncode(steps),
    };
  }

  Exercise copyWith({
    int? id,
    String? name,
    String? category,
    String? description,
    String? imageUrl,
    int? durationMinutes,
    double? caloriesPerMinute,
    List<String>? steps,
  }) {
    return Exercise(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      caloriesPerMinute: caloriesPerMinute ?? this.caloriesPerMinute,
      steps: steps ?? this.steps,
    );
  }

  @override
  String toString() =>
      'Exercise(id: $id, name: $name, category: $category)';
}
