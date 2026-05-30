/// FitTrack : ActivityLog data model
///
/// Represents an workout/sport log entry recorded by the user.
class ActivityLog {
  final int? id;
  final int userId;
  final int exerciseId;
  final String name;
  final String category;
  final int durationMinutes;
  final double caloriesBurned;
  final String dateTime; // yyyy-MM-dd HH:mm

  const ActivityLog({
    this.id,
    required this.userId,
    required this.exerciseId,
    required this.name,
    required this.category,
    required this.durationMinutes,
    required this.caloriesBurned,
    required this.dateTime,
  });

  factory ActivityLog.fromJson(Map<String, dynamic> json) {
    return ActivityLog(
      id: json['id'] as int?,
      userId: json['user_id'] as int,
      exerciseId: json['exercise_id'] as int,
      name: json['name'] as String,
      category: json['category'] as String,
      durationMinutes: json['duration_minutes'] as int,
      caloriesBurned: (json['calories_burned'] as num).toDouble(),
      dateTime: json['date_time'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'user_id': userId,
      'exercise_id': exerciseId,
      'name': name,
      'category': category,
      'duration_minutes': durationMinutes,
      'calories_burned': caloriesBurned,
      'date_time': dateTime,
    };
  }
}
