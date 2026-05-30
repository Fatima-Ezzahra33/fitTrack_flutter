/// FitTrack : User data model
///
/// Represents a registered user with profile details, fitness goals,
/// and preferences. This is a pure Dart class with NO Flutter/UI or
/// database dependencies. Supports full JSON serialization for SQLite.
library;
import 'package:intl/intl.dart';

class User {
  final int? id;
  final String firstName;
  final String lastName;
  final String email;
  final String passwordHash;
  final String? phoneNumber;
  final DateTime? dateOfBirth;
  final String? gender;
  final double? height;
  final double? weight;
  final double? goalWeight;
  final String? goalType;
  final String? profileImageUrl;
  final String themePreference;
  final DateTime createdAt;
  final DateTime updatedAt;

  const User({
    this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.passwordHash,
    this.phoneNumber,
    this.dateOfBirth,
    this.gender,
    this.height,
    this.weight,
    this.goalWeight,
    this.goalType,
    this.profileImageUrl,
    this.themePreference = 'system',
    required this.createdAt,
    required this.updatedAt,
  });

  /// Full display name
  String get fullName => '$firstName $lastName';

  /// Age calculated from date of birth
  int? get age {
    if (dateOfBirth == null) return null;
    final now = DateTime.now();
    int years = now.year - dateOfBirth!.year;
    if (now.month < dateOfBirth!.month ||
        (now.month == dateOfBirth!.month && now.day < dateOfBirth!.day)) {
      years--;
    }
    return years;
  }

  /// BMI calculation (weight in kg, height in cm)
  double? get bmi {
    if (weight == null || height == null || height == 0) return null;
    final heightMeters = height! / 100;
    return weight! / (heightMeters * heightMeters);
  }

  /// Create a User from a SQLite row map
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] != null ? int.tryParse(json['id'].toString()) : null,
      firstName: json['first_name'] as String,
      lastName: json['last_name'] as String,
      email: json['email'] as String,
      passwordHash: json['password_hash'] as String,
      phoneNumber: json['phone_number'] as String?,
      dateOfBirth: json['date_of_birth'] != null
          ? DateTime.parse(json['date_of_birth'] as String)
          : null,
      gender: json['gender'] as String?,
      height: json['height'] != null
          ? (json['height'] as num).toDouble()
          : null,
      weight: json['weight'] != null
          ? (json['weight'] as num).toDouble()
          : null,
      goalWeight: json['goal_weight'] != null
          ? (json['goal_weight'] as num).toDouble()
          : null,
      goalType: json['goal_type'] as String?,
      profileImageUrl: json['profile_image_url'] as String?,
      themePreference: (json['theme_preference'] as String?) ?? 'system',
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  /// Convert to a map suitable for SQLite insertion
  Map<String, dynamic> toJson() {
    final DateFormat iso = DateFormat("yyyy-MM-dd'T'HH:mm:ss");
    return {
      if (id != null) 'id': id,
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
      'password_hash': passwordHash,
      'phone_number': phoneNumber,
      'date_of_birth': dateOfBirth?.toIso8601String(),
      'gender': gender,
      'height': height,
      'weight': weight,
      'goal_weight': goalWeight,
      'goal_type': goalType,
      'profile_image_url': profileImageUrl,
      'theme_preference': themePreference,
      'created_at': iso.format(createdAt),
      'updated_at': iso.format(updatedAt),
    };
  }

  /// Immutable copy with optional field overrides
  User copyWith({
    int? id,
    String? firstName,
    String? lastName,
    String? email,
    String? passwordHash,
    String? phoneNumber,
    DateTime? dateOfBirth,
    String? gender,
    double? height,
    double? weight,
    double? goalWeight,
    String? goalType,
    String? profileImageUrl,
    String? themePreference,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return User(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      passwordHash: passwordHash ?? this.passwordHash,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
      height: height ?? this.height,
      weight: weight ?? this.weight,
      goalWeight: goalWeight ?? this.goalWeight,
      goalType: goalType ?? this.goalType,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      themePreference: themePreference ?? this.themePreference,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() => 'User(id: $id, name: $fullName, email: $email)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is User && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
