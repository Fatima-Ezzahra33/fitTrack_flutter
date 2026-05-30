/// FitTrack : Progress Comparison model
///
/// Represents a single saved before/after comparison entry.
/// Stores file paths to persisted images in the app documents directory,
/// along with metadata like creation timestamp and optional note.
library;

class ProgressComparison {
  final int? id;
  final int userId;
  final String beforeImagePath;
  final String afterImagePath;
  final String? note;
  final String createdAt; // ISO-8601 date-time string

  const ProgressComparison({
    this.id,
    required this.userId,
    required this.beforeImagePath,
    required this.afterImagePath,
    this.note,
    required this.createdAt,
  });

  /// Create from a SQLite row map.
  factory ProgressComparison.fromJson(Map<String, dynamic> json) {
    return ProgressComparison(
      id: json['id'] as int?,
      userId: json['user_id'] as int,
      beforeImagePath: json['before_image_path'] as String,
      afterImagePath: json['after_image_path'] as String,
      note: json['note'] as String?,
      createdAt: json['created_at'] as String,
    );
  }

  /// Convert to a map suitable for SQLite insertion.
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'user_id': userId,
      'before_image_path': beforeImagePath,
      'after_image_path': afterImagePath,
      'note': note,
      'created_at': createdAt,
    };
  }

  /// Create a copy with selective field overrides.
  ProgressComparison copyWith({
    int? id,
    int? userId,
    String? beforeImagePath,
    String? afterImagePath,
    String? note,
    String? createdAt,
  }) {
    return ProgressComparison(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      beforeImagePath: beforeImagePath ?? this.beforeImagePath,
      afterImagePath: afterImagePath ?? this.afterImagePath,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
