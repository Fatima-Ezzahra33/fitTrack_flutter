/// FitTrack — Database service (sqflite)
///
/// Singleton service encapsulating all SQLite operations.
/// Manages tables: users, exercises, weight_entries, foods, ready_meals, meal_logs, activity_logs.
library;
import 'dart:convert';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/exercise_model.dart';
import '../models/food_model.dart';
import '../models/ready_meal_model.dart';
import '../models/meal_log_model.dart';
import '../models/activity_log_model.dart';
import '../models/user_model.dart';
import '../models/weight_entry_model.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  Database? _database;

  static const String _dbName = 'fit_track_redesign_v2.db';
  static const int _dbVersion = 1;

  /// Get the database instance, initializing if needed.
  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  /// Initialize the database and create all tables.
  Future<Database> _initDatabase() async {
    final String dbPath = await getDatabasesPath();
    final String path = join(dbPath, _dbName);

    return openDatabase(
      path,
      version: _dbVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  /// Public initialization method — call from main.dart
  Future<void> initDatabase() async {
    _database = await _initDatabase();
  }

  // ════════════════════════════════════════════════════════════════════
  // TABLE CREATION
  // ════════════════════════════════════════════════════════════════════

  Future<void> _onCreate(Database db, int version) async {
    final Batch batch = db.batch();

    // ── Users table ─────────────────────────────────────────────────
    batch.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        first_name TEXT NOT NULL,
        last_name TEXT NOT NULL,
        email TEXT NOT NULL UNIQUE,
        password_hash TEXT NOT NULL,
        phone_number TEXT,
        date_of_birth TEXT,
        gender TEXT,
        height REAL,
        weight REAL,
        goal_weight REAL,
        goal_type TEXT,
        profile_image_url TEXT,
        theme_preference TEXT DEFAULT 'system',
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    // ── Exercises table ─────────────────────────────────────────────
    batch.execute('''
      CREATE TABLE exercises (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        category TEXT NOT NULL,
        description TEXT NOT NULL,
        image_url TEXT,
        duration_minutes INTEGER NOT NULL,
        calories_per_minute REAL NOT NULL,
        steps TEXT
      )
    ''');

    // ── Weight entries table ────────────────────────────────────────
    batch.execute('''
      CREATE TABLE weight_entries (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        weight REAL NOT NULL,
        date TEXT NOT NULL,
        note TEXT,
        FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE
      )
    ''');

    // ── Foods Table (Catalog) ───────────────────────────────────────
    batch.execute('''
      CREATE TABLE foods (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        calories_per_100g REAL NOT NULL,
        proteins_per_100g REAL NOT NULL,
        carbs_per_100g REAL NOT NULL,
        fats_per_100g REAL NOT NULL,
        category TEXT NOT NULL
      )
    ''');

    // ── Ready Meals Table (Recipes) ─────────────────────────────────
    batch.execute('''
      CREATE TABLE ready_meals (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        category TEXT NOT NULL,
        total_calories REAL NOT NULL,
        image_url TEXT,
        ingredients TEXT NOT NULL
      )
    ''');

    // ── Meal Logs Table (Intake history) ────────────────────────────
    batch.execute('''
      CREATE TABLE meal_logs (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        food_id INTEGER,
        ready_meal_id INTEGER,
        name TEXT NOT NULL,
        grams REAL NOT NULL,
        calories REAL NOT NULL,
        proteins REAL NOT NULL,
        carbs REAL NOT NULL,
        fats REAL NOT NULL,
        meal_type TEXT NOT NULL,
        date TEXT NOT NULL,
        FOREIGN KEY (food_id) REFERENCES foods (id) ON DELETE SET NULL,
        FOREIGN KEY (ready_meal_id) REFERENCES ready_meals (id) ON DELETE SET NULL
      )
    ''');

    // ── Activity Logs Table (Workouts history) ──────────────────────
    batch.execute('''
      CREATE TABLE activity_logs (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        exercise_id INTEGER NOT NULL,
        name TEXT NOT NULL,
        category TEXT NOT NULL,
        duration_minutes INTEGER NOT NULL,
        calories_burned REAL NOT NULL,
        date_time TEXT NOT NULL,
        FOREIGN KEY (exercise_id) REFERENCES exercises (id) ON DELETE CASCADE
      )
    ''');

    // ── Indexes for performance ─────────────────────────────────────
    batch.execute('CREATE INDEX idx_weight_entries_user ON weight_entries(user_id)');
    batch.execute('CREATE INDEX idx_meal_logs_date ON meal_logs(date)');
    batch.execute('CREATE INDEX idx_activity_logs_date ON activity_logs(date_time)');

    // Seeding default exercises
    _seedExercises(batch);

    // Seeding 50 base foods
    _seedFoods(batch);

    // Seeding 10 ready meals
    _seedReadyMeals(batch);

    await batch.commit(noResult: true);
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Migration logic
  }

  void _seedExercises(Batch batch) {
    final List<Map<String, dynamic>> defaultExercises = [
      {
        'name': 'Course à pied',
        'category': 'Cardio',
        'description': 'Course à allure modérée en extérieur ou sur tapis.',
        'duration_minutes': 30,
        'calories_per_minute': 10.0,
        'steps': jsonEncode(['S\'échauffer 5 minutes', 'Courir à rythme régulier', 'S\'étirer à la fin']),
      },
      {
        'name': 'Pompes',
        'category': 'Musculation',
        'description': 'Exercice de poids de corps ciblant la poitrine et les triceps.',
        'duration_minutes': 10,
        'calories_per_minute': 7.0,
        'steps': jsonEncode(['Se positionner en planche', 'Descendre le buste', 'Pousser vers le haut']),
      },
      {
        'name': 'Yoga',
        'category': 'Souplesse',
        'description': 'Enchaînement de postures pour la souplesse et la relaxation.',
        'duration_minutes': 20,
        'calories_per_minute': 4.5,
        'steps': jsonEncode(['Saluations au soleil', 'Postures d\'équilibre', 'Méditation finale']),
      },
      {
        'name': 'Squats',
        'category': 'Musculation',
        'description': 'Exercice polyarticulaire ciblant les quadriceps et les fessiers.',
        'duration_minutes': 15,
        'calories_per_minute': 8.0,
        'steps': jsonEncode(['Écarter les pieds', 'Descendre comme sur une chaise', 'Remonter en poussant sur les talons']),
      },
      {
        'name': 'Corde à sauter',
        'category': 'Cardio',
        'description': 'Exercice de haute intensité pour le cardio et l\'endurance.',
        'duration_minutes': 10,
        'calories_per_minute': 12.0,
        'steps': jsonEncode(['Sauter sur la pointe des pieds', 'Garder les coudes près du corps', 'Respirer régulièrement']),
      }
    ];

    for (final exercise in defaultExercises) {
      batch.insert('exercises', exercise);
    }
  }

  void _seedFoods(Batch batch) {
    final List<Map<String, dynamic>> defaultFoods = [
      {'name': 'Pomme', 'calories_per_100g': 52.0, 'proteins_per_100g': 0.3, 'carbs_per_100g': 13.8, 'fats_per_100g': 0.2, 'category': 'fruit'},
      {'name': 'Banane', 'calories_per_100g': 89.0, 'proteins_per_100g': 1.1, 'carbs_per_100g': 22.8, 'fats_per_100g': 0.3, 'category': 'fruit'},
      {'name': 'Orange', 'calories_per_100g': 47.0, 'proteins_per_100g': 0.9, 'carbs_per_100g': 11.8, 'fats_per_100g': 0.1, 'category': 'fruit'},
      {'name': 'Fraise', 'calories_per_100g': 32.0, 'proteins_per_100g': 0.7, 'carbs_per_100g': 7.7, 'fats_per_100g': 0.3, 'category': 'fruit'},
      {'name': 'Framboise', 'calories_per_100g': 52.0, 'proteins_per_100g': 1.2, 'carbs_per_100g': 11.9, 'fats_per_100g': 0.7, 'category': 'fruit'},
      {'name': 'Myrtille', 'calories_per_100g': 57.0, 'proteins_per_100g': 0.7, 'carbs_per_100g': 14.5, 'fats_per_100g': 0.3, 'category': 'fruit'},
      {'name': 'Raisin', 'calories_per_100g': 67.0, 'proteins_per_100g': 0.6, 'carbs_per_100g': 17.2, 'fats_per_100g': 0.4, 'category': 'fruit'},
      {'name': 'Pêche', 'calories_per_100g': 39.0, 'proteins_per_100g': 0.9, 'carbs_per_100g': 9.5, 'fats_per_100g': 0.3, 'category': 'fruit'},
      {'name': 'Poire', 'calories_per_100g': 57.0, 'proteins_per_100g': 0.4, 'carbs_per_100g': 15.2, 'fats_per_100g': 0.1, 'category': 'fruit'},
      {'name': 'Kiwi', 'calories_per_100g': 61.0, 'proteins_per_100g': 1.1, 'carbs_per_100g': 14.7, 'fats_per_100g': 0.5, 'category': 'fruit'},
      {'name': 'Avocat', 'calories_per_100g': 160.0, 'proteins_per_100g': 2.0, 'carbs_per_100g': 8.5, 'fats_per_100g': 14.7, 'category': 'fruit'},
      {'name': 'Tomate', 'calories_per_100g': 18.0, 'proteins_per_100g': 0.9, 'carbs_per_100g': 3.9, 'fats_per_100g': 0.2, 'category': 'vegetable'},
      {'name': 'Carotte', 'calories_per_100g': 41.0, 'proteins_per_100g': 0.9, 'carbs_per_100g': 9.6, 'fats_per_100g': 0.2, 'category': 'vegetable'},
      {'name': 'Brocoli', 'calories_per_100g': 34.0, 'proteins_per_100g': 2.8, 'carbs_per_100g': 6.6, 'fats_per_100g': 0.4, 'category': 'vegetable'},
      {'name': 'Épinards', 'calories_per_100g': 23.0, 'proteins_per_100g': 2.9, 'carbs_per_100g': 3.6, 'fats_per_100g': 0.4, 'category': 'vegetable'},
      {'name': 'Salade Verte', 'calories_per_100g': 15.0, 'proteins_per_100g': 1.4, 'carbs_per_100g': 2.9, 'fats_per_100g': 0.2, 'category': 'vegetable'},
      {'name': 'Concombre', 'calories_per_100g': 15.0, 'proteins_per_100g': 0.7, 'carbs_per_100g': 3.6, 'fats_per_100g': 0.1, 'category': 'vegetable'},
      {'name': 'Courgette', 'calories_per_100g': 17.0, 'proteins_per_100g': 1.2, 'carbs_per_100g': 3.1, 'fats_per_100g': 0.3, 'category': 'vegetable'},
      {'name': 'Poivron', 'calories_per_100g': 20.0, 'proteins_per_100g': 0.9, 'carbs_per_100g': 4.6, 'fats_per_100g': 0.2, 'category': 'vegetable'},
      {'name': 'Oignon', 'calories_per_100g': 40.0, 'proteins_per_100g': 1.1, 'carbs_per_100g': 9.3, 'fats_per_100g': 0.1, 'category': 'vegetable'},
      {'name': 'Ail', 'calories_per_100g': 149.0, 'proteins_per_100g': 6.4, 'carbs_per_100g': 33.1, 'fats_per_100g': 0.5, 'category': 'vegetable'},
      {'name': 'Blanc de Poulet', 'calories_per_100g': 165.0, 'proteins_per_100g': 31.0, 'carbs_per_100g': 0.0, 'fats_per_100g': 3.6, 'category': 'protein'},
      {'name': 'Saumon', 'calories_per_100g': 208.0, 'proteins_per_100g': 20.0, 'carbs_per_100g': 0.0, 'fats_per_100g': 13.0, 'category': 'protein'},
      {'name': 'Œuf', 'calories_per_100g': 155.0, 'proteins_per_100g': 13.0, 'carbs_per_100g': 1.1, 'fats_per_100g': 11.0, 'category': 'protein'},
      {'name': 'Steak Haché de Bœuf', 'calories_per_100g': 250.0, 'proteins_per_100g': 26.0, 'carbs_per_100g': 0.0, 'fats_per_100g': 15.0, 'category': 'protein'},
      {'name': 'Thon en conserve', 'calories_per_100g': 116.0, 'proteins_per_100g': 26.0, 'carbs_per_100g': 0.0, 'fats_per_100g': 1.0, 'category': 'protein'},
      {'name': 'Tofu', 'calories_per_100g': 76.0, 'proteins_per_100g': 8.0, 'carbs_per_100g': 1.9, 'fats_per_100g': 4.8, 'category': 'protein'},
      {'name': 'Lentilles', 'calories_per_100g': 116.0, 'proteins_per_100g': 9.0, 'carbs_per_100g': 20.0, 'fats_per_100g': 0.4, 'category': 'protein'},
      {'name': 'Pois Chiches', 'calories_per_100g': 164.0, 'proteins_per_100g': 8.9, 'carbs_per_100g': 27.4, 'fats_per_100g': 2.6, 'category': 'protein'},
      {'name': 'Dinde', 'calories_per_100g': 135.0, 'proteins_per_100g': 30.0, 'carbs_per_100g': 0.0, 'fats_per_100g': 1.5, 'category': 'protein'},
      {'name': 'Riz Blanc', 'calories_per_100g': 130.0, 'proteins_per_100g': 2.7, 'carbs_per_100g': 28.0, 'fats_per_100g': 0.3, 'category': 'grain'},
      {'name': 'Riz Complet', 'calories_per_100g': 111.0, 'proteins_per_100g': 2.6, 'carbs_per_100g': 23.0, 'fats_per_100g': 0.9, 'category': 'grain'},
      {'name': 'Flocons d\'Avoine', 'calories_per_100g': 389.0, 'proteins_per_100g': 16.9, 'carbs_per_100g': 66.3, 'fats_per_100g': 6.9, 'category': 'grain'},
      {'name': 'Pain Complet', 'calories_per_100g': 247.0, 'proteins_per_100g': 13.0, 'carbs_per_100g': 41.0, 'fats_per_100g': 3.4, 'category': 'grain'},
      {'name': 'Pâtes', 'calories_per_100g': 131.0, 'proteins_per_100g': 5.0, 'carbs_per_100g': 25.0, 'fats_per_100g': 1.1, 'category': 'grain'},
      {'name': 'Quinoa', 'calories_per_100g': 120.0, 'proteins_per_100g': 4.4, 'carbs_per_100g': 21.3, 'fats_per_100g': 1.9, 'category': 'grain'},
      {'name': 'Patate Douce', 'calories_per_100g': 86.0, 'proteins_per_100g': 1.6, 'carbs_per_100g': 20.1, 'fats_per_100g': 0.1, 'category': 'grain'},
      {'name': 'Pomme de Terre', 'calories_per_100g': 77.0, 'proteins_per_100g': 2.0, 'carbs_per_100g': 17.0, 'fats_per_100g': 0.1, 'category': 'grain'},
      {'name': 'Lait Demi-Écrémé', 'calories_per_100g': 50.0, 'proteins_per_100g': 3.3, 'carbs_per_100g': 4.8, 'fats_per_100g': 1.6, 'category': 'dairy'},
      {'name': 'Yaourt Grec', 'calories_per_100g': 59.0, 'proteins_per_100g': 10.0, 'carbs_per_100g': 3.6, 'fats_per_100g': 0.4, 'category': 'dairy'},
      {'name': 'Fromage Blanc', 'calories_per_100g': 98.0, 'proteins_per_100g': 8.0, 'carbs_per_100g': 3.5, 'fats_per_100g': 3.0, 'category': 'dairy'},
      {'name': 'Beurre', 'calories_per_100g': 717.0, 'proteins_per_100g': 0.9, 'carbs_per_100g': 0.1, 'fats_per_100g': 81.0, 'category': 'dairy'},
      {'name': 'Mozzarella', 'calories_per_100g': 280.0, 'proteins_per_100g': 28.0, 'carbs_per_100g': 3.1, 'fats_per_100g': 17.0, 'category': 'dairy'},
      {'name': 'Huile d\'Olive', 'calories_per_100g': 884.0, 'proteins_per_100g': 0.0, 'carbs_per_100g': 0.0, 'fats_per_100g': 100.0, 'category': 'other'},
      {'name': 'Amandes', 'calories_per_100g': 579.0, 'proteins_per_100g': 21.0, 'carbs_per_100g': 22.0, 'fats_per_100g': 49.0, 'category': 'other'},
      {'name': 'Noix', 'calories_per_100g': 654.0, 'proteins_per_100g': 15.0, 'carbs_per_100g': 13.7, 'fats_per_100g': 65.2, 'category': 'other'},
      {'name': 'Miel', 'calories_per_100g': 304.0, 'proteins_per_100g': 0.3, 'carbs_per_100g': 82.4, 'fats_per_100g': 0.0, 'category': 'other'},
      {'name': 'Chocolat Noir', 'calories_per_100g': 546.0, 'proteins_per_100g': 4.9, 'carbs_per_100g': 61.0, 'fats_per_100g': 31.0, 'category': 'other'},
      {'name': 'Beurre de Cacahuète', 'calories_per_100g': 588.0, 'proteins_per_100g': 25.0, 'carbs_per_100g': 20.0, 'fats_per_100g': 50.0, 'category': 'other'},
      {'name': 'Graines de Chia', 'calories_per_100g': 486.0, 'proteins_per_100g': 16.5, 'carbs_per_100g': 42.1, 'fats_per_100g': 30.7, 'category': 'other'}
    ];

    for (final food in defaultFoods) {
      batch.insert('foods', food);
    }
  }

  void _seedReadyMeals(Batch batch) {
    final List<Map<String, dynamic>> defaultReadyMeals = [
      {
        'name': 'Pancakes aux Myrtilles',
        'category': 'breakfast',
        'total_calories': 350.0,
        'image_url': 'pancakes',
        'ingredients': jsonEncode(['Myrtilles', 'Flocons d\'Avoine', 'Œuf', 'Lait Demi-Écrémé', 'Miel']),
      },
      {
        'name': 'Salade de Poulet Grillé',
        'category': 'lunch',
        'total_calories': 400.0,
        'image_url': 'chicken_salad',
        'ingredients': jsonEncode(['Blanc de Poulet', 'Salade Verte', 'Tomate', 'Concombre', 'Huile d\'Olive']),
      },
      {
        'name': 'Saumon Grillé & Patate Douce',
        'category': 'dinner',
        'total_calories': 550.0,
        'image_url': 'salmon_sweetpot',
        'ingredients': jsonEncode(['Saumon', 'Patate Douce', 'Brocoli', 'Huile d\'Olive']),
      },
      {
        'name': 'Oatmeal Banane Miel',
        'category': 'breakfast',
        'total_calories': 280.0,
        'image_url': 'oatmeal',
        'ingredients': jsonEncode(['Flocons d\'Avoine', 'Banane', 'Lait Demi-Écrémé', 'Miel', 'Amandes']),
      },
      {
        'name': 'Smoothie Protéiné Fraise',
        'category': 'snack',
        'total_calories': 220.0,
        'image_url': 'smoothie',
        'ingredients': jsonEncode(['Fraise', 'Yaourt Grec', 'Lait Demi-Écrémé', 'Miel', 'Graines de Chia']),
      },
      {
        'name': 'Omelette aux Épinards',
        'category': 'breakfast',
        'total_calories': 250.0,
        'image_url': 'omelette',
        'ingredients': jsonEncode(['Œuf', 'Épinards', 'Tomate', 'Fromage Blanc', 'Beurre']),
      },
      {
        'name': 'Bowl Avocat & Quinoa',
        'category': 'lunch',
        'total_calories': 450.0,
        'image_url': 'quinoa_bowl',
        'ingredients': jsonEncode(['Avocat', 'Quinoa', 'Tomate', 'Concombre', 'Huile d\'Olive']),
      },
      {
        'name': 'Pâtes Bolognaise',
        'category': 'dinner',
        'total_calories': 600.0,
        'image_url': 'pasta_bolognese',
        'ingredients': jsonEncode(['Pâtes', 'Steak Haché de Bœuf', 'Tomate', 'Oignon', 'Huile d\'Olive']),
      },
      {
        'name': 'Yaourt aux Fruits & Noix',
        'category': 'snack',
        'total_calories': 180.0,
        'image_url': 'yogurt_nuts',
        'ingredients': jsonEncode(['Yaourt Grec', 'Framboise', 'Myrtille', 'Noix', 'Miel']),
      },
      {
        'name': 'Tofu Sauté aux Brocolis',
        'category': 'lunch',
        'total_calories': 320.0,
        'image_url': 'tofu_broccoli',
        'ingredients': jsonEncode(['Tofu', 'Brocoli', 'Courgette', 'Poivron', 'Huile d\'Olive']),
      }
    ];

    for (final meal in defaultReadyMeals) {
      batch.insert('ready_meals', meal);
    }
  }

  // ════════════════════════════════════════════════════════════════════
  // USERS CRUD
  // ════════════════════════════════════════════════════════════════════

  Future<int> insertUser(User user) async {
    final db = await database;
    return db.insert('users', user.toJson(), conflictAlgorithm: ConflictAlgorithm.abort);
  }

  Future<User?> getUserByEmail(String email) async {
    final db = await database;
    final List<Map<String, dynamic>> results = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
      limit: 1,
    );
    if (results.isEmpty) return null;
    return User.fromJson(results.first);
  }

  Future<User?> getUserById(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> results = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (results.isEmpty) return null;
    return User.fromJson(results.first);
  }

  Future<User?> authenticateUser(String email, String passwordHash) async {
    final db = await database;
    final List<Map<String, dynamic>> results = await db.query(
      'users',
      where: 'email = ? AND password_hash = ?',
      whereArgs: [email, passwordHash],
      limit: 1,
    );
    if (results.isEmpty) return null;
    return User.fromJson(results.first);
  }

  Future<int> updateUser(User user) async {
    final db = await database;
    return db.update(
      'users',
      user.toJson(),
      where: 'id = ?',
      whereArgs: [user.id],
    );
  }

  Future<bool> emailExists(String email) async {
    final db = await database;
    final result = await db.query(
      'users',
      columns: ['id'],
      where: 'email = ?',
      whereArgs: [email],
      limit: 1,
    );
    return result.isNotEmpty;
  }

  // ════════════════════════════════════════════════════════════════════
  // EXERCISES CRUD & LOGS
  // ════════════════════════════════════════════════════════════════════

  Future<List<Exercise>> getAllExercises() async {
    final db = await database;
    final List<Map<String, dynamic>> results = await db.query('exercises');
    return results.map((row) => Exercise.fromJson(row)).toList();
  }

  Future<List<Exercise>> searchExercises(String query) async {
    final db = await database;
    final List<Map<String, dynamic>> results = await db.query(
      'exercises',
      where: 'name LIKE ? OR category LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
    );
    return results.map((row) => Exercise.fromJson(row)).toList();
  }

  Future<List<ActivityLog>> getActivityLogs() async {
    final db = await database;
    final List<Map<String, dynamic>> results = await db.query('activity_logs', orderBy: 'date_time DESC');
    return results.map((row) => ActivityLog.fromJson(row)).toList();
  }

  Future<List<ActivityLog>> getActivityLogsForDate(String date) async {
    final db = await database;
    final List<Map<String, dynamic>> results = await db.query(
      'activity_logs',
      where: 'date_time LIKE ?',
      whereArgs: ['$date%'],
      orderBy: 'date_time DESC',
    );
    return results.map((row) => ActivityLog.fromJson(row)).toList();
  }

  Future<int> insertActivityLog(ActivityLog log) async {
    final db = await database;
    return db.insert('activity_logs', log.toJson());
  }

  Future<int> deleteActivityLog(int id) async {
    final db = await database;
    return db.delete('activity_logs', where: 'id = ?', whereArgs: [id]);
  }

  Future<double> getDailyCaloriesBurned(String date) async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT SUM(calories_burned) as total FROM activity_logs WHERE date_time LIKE ?',
      ['$date%'],
    );
    if (result.isEmpty || result.first['total'] == null) return 0.0;
    return (result.first['total'] as num).toDouble();
  }

  // ════════════════════════════════════════════════════════════════════
  // WEIGHT ENTRIES CRUD
  // ════════════════════════════════════════════════════════════════════

  Future<int> insertWeightEntry(WeightEntry entry) async {
    final db = await database;
    return db.insert('weight_entries', entry.toJson());
  }

  Future<int> deleteWeightEntry(int id) async {
    final db = await database;
    return db.delete('weight_entries', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<WeightEntry>> getWeightEntriesByUser(int userId) async {
    final db = await database;
    final List<Map<String, dynamic>> results = await db.query(
      'weight_entries',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'date DESC',
    );
    return results.map((row) => WeightEntry.fromJson(row)).toList();
  }

  Future<WeightEntry?> getLatestWeight(int userId) async {
    final db = await database;
    final List<Map<String, dynamic>> results = await db.query(
      'weight_entries',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'date DESC',
      limit: 1,
    );
    if (results.isEmpty) return null;
    return WeightEntry.fromJson(results.first);
  }

  Future<WeightEntry?> getPreviousWeight(int userId) async {
    final db = await database;
    final List<Map<String, dynamic>> results = await db.query(
      'weight_entries',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'date DESC',
      limit: 2,
    );
    if (results.length < 2) return null;
    return WeightEntry.fromJson(results[1]);
  }

  // ════════════════════════════════════════════════════════════════════
  // FOODS & READY MEALS & MEAL LOGS
  // ════════════════════════════════════════════════════════════════════

  Future<List<Food>> getAllFoods() async {
    final db = await database;
    final List<Map<String, dynamic>> results = await db.query('foods', orderBy: 'name ASC');
    return results.map((row) => Food.fromJson(row)).toList();
  }

  Future<List<Food>> searchFoods(String query) async {
    final db = await database;
    final List<Map<String, dynamic>> results = await db.query(
      'foods',
      where: 'name LIKE ? OR category LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
      orderBy: 'name ASC',
    );
    return results.map((row) => Food.fromJson(row)).toList();
  }

  Future<int> insertFood(Food food) async {
    final db = await database;
    return db.insert('foods', food.toJson());
  }

  Future<List<ReadyMeal>> getAllReadyMeals() async {
    final db = await database;
    final List<Map<String, dynamic>> results = await db.query('ready_meals', orderBy: 'name ASC');
    return results.map((row) => ReadyMeal.fromJson(row)).toList();
  }

  Future<List<MealLog>> getMealLogsForDate(String date) async {
    final db = await database;
    final List<Map<String, dynamic>> results = await db.query(
      'meal_logs',
      where: 'date = ?',
      whereArgs: [date],
    );
    return results.map((row) => MealLog.fromJson(row)).toList();
  }

  Future<int> insertMealLog(MealLog log) async {
    final db = await database;
    return db.insert('meal_logs', log.toJson());
  }

  Future<int> deleteMealLog(int id) async {
    final db = await database;
    return db.delete('meal_logs', where: 'id = ?', whereArgs: [id]);
  }

  /// Get daily sum calories consumed
  Future<double> getDailyCaloriesConsumed(String date) async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT SUM(calories) as total FROM meal_logs WHERE date = ?',
      [date],
    );
    if (result.isEmpty || result.first['total'] == null) return 0.0;
    return (result.first['total'] as num).toDouble();
  }

  /// Get weekly calories consumed history for line chart (past 7 days including selectDate)
  Future<Map<String, double>> getWeeklyCaloriesData(String selectDateStr) async {
    final db = await database;
    final DateTime targetDate = DateTime.parse(selectDateStr);
    final Map<String, double> result = {};

    for (int i = 6; i >= 0; i--) {
      final DateTime day = targetDate.subtract(Duration(days: i));
      final String dateStr = day.toIso8601String().split('T').first;

      final res = await db.rawQuery(
        'SELECT SUM(calories) as total FROM meal_logs WHERE date = ?',
        [dateStr],
      );
      final double cal = (res.isNotEmpty && res.first['total'] != null)
          ? (res.first['total'] as num).toDouble()
          : 0.0;
      result[dateStr] = cal;
    }
    return result;
  }

  // ════════════════════════════════════════════════════════════════════
  // UTILITY
  // ════════════════════════════════════════════════════════════════════

  Future<void> close() async {
    final db = await database;
    await db.close();
    _database = null;
  }
}
