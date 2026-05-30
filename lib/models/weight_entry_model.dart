/// FitTrack : Weight entry data model
///
/// Tracks a user's weight measurements over time. Each entry
/// records the weight, date, and an optional note.
class WeightEntry {
  final int? id;
  final int userId;
  final double weight;
  final DateTime date;
  final String? note;

  const WeightEntry({
    this.id,
    required this.userId,
    required this.weight,
    required this.date,
    this.note,
  });

  factory WeightEntry.fromJson(Map<String, dynamic> json) {
    return WeightEntry(
      id: json['id'] != null ? int.tryParse(json['id'].toString()) : null,
      userId: json['user_id'] as int,
      weight: (json['weight'] as num).toDouble(),
      date: DateTime.parse(json['date'] as String),
      note: json['note'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'user_id': userId,
      'weight': weight,
      'date': date.toIso8601String(),
      'note': note,
    };
  }

  WeightEntry copyWith({
    int? id,
    int? userId,
    double? weight,
    DateTime? date,
    String? note,
  }) {
    return WeightEntry(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      weight: weight ?? this.weight,
      date: date ?? this.date,
      note: note ?? this.note,
    );
  }

  @override
  String toString() =>
      'WeightEntry(id: $id, userId: $userId, weight: $weight, date: $date)';
}
