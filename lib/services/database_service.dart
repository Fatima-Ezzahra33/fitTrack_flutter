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
  static const int _dbVersion = 2;

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
        user_id INTEGER NOT NULL,
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
        FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE,
        FOREIGN KEY (food_id) REFERENCES foods (id) ON DELETE SET NULL,
        FOREIGN KEY (ready_meal_id) REFERENCES ready_meals (id) ON DELETE SET NULL
      )
    ''');

    // ── Activity Logs Table (Workouts history) ──────────────────────
    batch.execute('''
      CREATE TABLE activity_logs (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        exercise_id INTEGER NOT NULL,
        name TEXT NOT NULL,
        category TEXT NOT NULL,
        duration_minutes INTEGER NOT NULL,
        calories_burned REAL NOT NULL,
        date_time TEXT NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE,
        FOREIGN KEY (exercise_id) REFERENCES exercises (id) ON DELETE CASCADE
      )
    ''');

    // ── Indexes for performance ─────────────────────────────────────
    batch.execute('CREATE INDEX idx_weight_entries_user ON weight_entries(user_id)');
    batch.execute('CREATE INDEX idx_meal_logs_user ON meal_logs(user_id)');
    batch.execute('CREATE INDEX idx_meal_logs_date ON meal_logs(date)');
    batch.execute('CREATE INDEX idx_activity_logs_user ON activity_logs(user_id)');
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
    if (oldVersion < 2) {
      // Add user_id to existing tables
      await db.execute('ALTER TABLE meal_logs ADD COLUMN user_id INTEGER NOT NULL DEFAULT 0');
      await db.execute('ALTER TABLE activity_logs ADD COLUMN user_id INTEGER NOT NULL DEFAULT 0');
      
      // Update the user_id to match the first user in the DB (fallback for dev environments)
      await db.execute('UPDATE meal_logs SET user_id = (SELECT id FROM users LIMIT 1) WHERE user_id = 0');
      await db.execute('UPDATE activity_logs SET user_id = (SELECT id FROM users LIMIT 1) WHERE user_id = 0');
    }
  }

  void _seedExercises(Batch batch) {
    final List<Map<String, dynamic>> defaultExercises = [
      {
        'name': 'Running',
        'category': 'Cardio',
        'description': 'Moderate pace running outdoors or on a treadmill.',
        'duration_minutes': 30,
        'calories_per_minute': 10.0,
        'steps': jsonEncode(['Warm up for 5 minutes', 'Run at a steady pace', 'Stretch at the end']),
      },
      {
        'name': 'Push-ups',
        'category': 'Strength',
        'description': 'Bodyweight exercise targeting the chest and triceps.',
        'duration_minutes': 10,
        'calories_per_minute': 7.0,
        'steps': jsonEncode(['Get into a plank position', 'Lower your chest', 'Push up']),
      },
      {
        'name': 'Yoga',
        'category': 'Flexibility',
        'description': 'Sequence of postures for flexibility and relaxation.',
        'duration_minutes': 20,
        'calories_per_minute': 4.5,
        'steps': jsonEncode(['Sun salutations', 'Balancing postures', 'Final meditation']),
      },
      {
        'name': 'Squats',
        'category': 'Strength',
        'description': 'Compound exercise targeting the quadriceps and glutes.',
        'duration_minutes': 15,
        'calories_per_minute': 8.0,
        'steps': jsonEncode(['Spread your feet', 'Lower as if sitting on a chair', 'Push back up through your heels']),
      },
      {
        'name': 'Jump Rope',
        'category': 'Cardio',
        'description': 'High-intensity exercise for cardio and endurance.',
        'duration_minutes': 10,
        'calories_per_minute': 12.0,
        'steps': jsonEncode(['Jump on your toes', 'Keep elbows close to the body', 'Breathe regularly']),
      }
    ];

    for (final exercise in defaultExercises) {
      batch.insert('exercises', exercise);
    }
  }

  void _seedFoods(Batch batch) {
    final List<Map<String, dynamic>> defaultFoods = [
      {'name': 'Apple', 'calories_per_100g': 52.0, 'proteins_per_100g': 0.3, 'carbs_per_100g': 13.8, 'fats_per_100g': 0.2, 'category': 'fruit'},
      {'name': 'Banana', 'calories_per_100g': 89.0, 'proteins_per_100g': 1.1, 'carbs_per_100g': 22.8, 'fats_per_100g': 0.3, 'category': 'fruit'},
      {'name': 'Orange', 'calories_per_100g': 47.0, 'proteins_per_100g': 0.9, 'carbs_per_100g': 11.8, 'fats_per_100g': 0.1, 'category': 'fruit'},
      {'name': 'Strawberry', 'calories_per_100g': 32.0, 'proteins_per_100g': 0.7, 'carbs_per_100g': 7.7, 'fats_per_100g': 0.3, 'category': 'fruit'},
      {'name': 'Raspberry', 'calories_per_100g': 52.0, 'proteins_per_100g': 1.2, 'carbs_per_100g': 11.9, 'fats_per_100g': 0.7, 'category': 'fruit'},
      {'name': 'Blueberry', 'calories_per_100g': 57.0, 'proteins_per_100g': 0.7, 'carbs_per_100g': 14.5, 'fats_per_100g': 0.3, 'category': 'fruit'},
      {'name': 'Grape', 'calories_per_100g': 67.0, 'proteins_per_100g': 0.6, 'carbs_per_100g': 17.2, 'fats_per_100g': 0.4, 'category': 'fruit'},
      {'name': 'Peach', 'calories_per_100g': 39.0, 'proteins_per_100g': 0.9, 'carbs_per_100g': 9.5, 'fats_per_100g': 0.3, 'category': 'fruit'},
      {'name': 'Pear', 'calories_per_100g': 57.0, 'proteins_per_100g': 0.4, 'carbs_per_100g': 15.2, 'fats_per_100g': 0.1, 'category': 'fruit'},
      {'name': 'Kiwi', 'calories_per_100g': 61.0, 'proteins_per_100g': 1.1, 'carbs_per_100g': 14.7, 'fats_per_100g': 0.5, 'category': 'fruit'},
      {'name': 'Avocado', 'calories_per_100g': 160.0, 'proteins_per_100g': 2.0, 'carbs_per_100g': 8.5, 'fats_per_100g': 14.7, 'category': 'fruit'},
      {'name': 'Tomato', 'calories_per_100g': 18.0, 'proteins_per_100g': 0.9, 'carbs_per_100g': 3.9, 'fats_per_100g': 0.2, 'category': 'vegetable'},
      {'name': 'Carrot', 'calories_per_100g': 41.0, 'proteins_per_100g': 0.9, 'carbs_per_100g': 9.6, 'fats_per_100g': 0.2, 'category': 'vegetable'},
      {'name': 'Broccoli', 'calories_per_100g': 34.0, 'proteins_per_100g': 2.8, 'carbs_per_100g': 6.6, 'fats_per_100g': 0.4, 'category': 'vegetable'},
      {'name': 'Spinach', 'calories_per_100g': 23.0, 'proteins_per_100g': 2.9, 'carbs_per_100g': 3.6, 'fats_per_100g': 0.4, 'category': 'vegetable'},
      {'name': 'Green Salad', 'calories_per_100g': 15.0, 'proteins_per_100g': 1.4, 'carbs_per_100g': 2.9, 'fats_per_100g': 0.2, 'category': 'vegetable'},
      {'name': 'Cucumber', 'calories_per_100g': 15.0, 'proteins_per_100g': 0.7, 'carbs_per_100g': 3.6, 'fats_per_100g': 0.1, 'category': 'vegetable'},
      {'name': 'Zucchini', 'calories_per_100g': 17.0, 'proteins_per_100g': 1.2, 'carbs_per_100g': 3.1, 'fats_per_100g': 0.3, 'category': 'vegetable'},
      {'name': 'Bell Pepper', 'calories_per_100g': 20.0, 'proteins_per_100g': 0.9, 'carbs_per_100g': 4.6, 'fats_per_100g': 0.2, 'category': 'vegetable'},
      {'name': 'Onion', 'calories_per_100g': 40.0, 'proteins_per_100g': 1.1, 'carbs_per_100g': 9.3, 'fats_per_100g': 0.1, 'category': 'vegetable'},
      {'name': 'Garlic', 'calories_per_100g': 149.0, 'proteins_per_100g': 6.4, 'carbs_per_100g': 33.1, 'fats_per_100g': 0.5, 'category': 'vegetable'},
      {'name': 'Chicken Breast', 'calories_per_100g': 165.0, 'proteins_per_100g': 31.0, 'carbs_per_100g': 0.0, 'fats_per_100g': 3.6, 'category': 'protein'},
      {'name': 'Salmon', 'calories_per_100g': 208.0, 'proteins_per_100g': 20.0, 'carbs_per_100g': 0.0, 'fats_per_100g': 13.0, 'category': 'protein'},
      {'name': 'Egg', 'calories_per_100g': 155.0, 'proteins_per_100g': 13.0, 'carbs_per_100g': 1.1, 'fats_per_100g': 11.0, 'category': 'protein'},
      {'name': 'Ground Beef', 'calories_per_100g': 250.0, 'proteins_per_100g': 26.0, 'carbs_per_100g': 0.0, 'fats_per_100g': 15.0, 'category': 'protein'},
      {'name': 'Canned Tuna', 'calories_per_100g': 116.0, 'proteins_per_100g': 26.0, 'carbs_per_100g': 0.0, 'fats_per_100g': 1.0, 'category': 'protein'},
      {'name': 'Tofu', 'calories_per_100g': 76.0, 'proteins_per_100g': 8.0, 'carbs_per_100g': 1.9, 'fats_per_100g': 4.8, 'category': 'protein'},
      {'name': 'Lentils', 'calories_per_100g': 116.0, 'proteins_per_100g': 9.0, 'carbs_per_100g': 20.0, 'fats_per_100g': 0.4, 'category': 'protein'},
      {'name': 'Chickpeas', 'calories_per_100g': 164.0, 'proteins_per_100g': 8.9, 'carbs_per_100g': 27.4, 'fats_per_100g': 2.6, 'category': 'protein'},
      {'name': 'Turkey', 'calories_per_100g': 135.0, 'proteins_per_100g': 30.0, 'carbs_per_100g': 0.0, 'fats_per_100g': 1.5, 'category': 'protein'},
      {'name': 'White Rice', 'calories_per_100g': 130.0, 'proteins_per_100g': 2.7, 'carbs_per_100g': 28.0, 'fats_per_100g': 0.3, 'category': 'grain'},
      {'name': 'Brown Rice', 'calories_per_100g': 111.0, 'proteins_per_100g': 2.6, 'carbs_per_100g': 23.0, 'fats_per_100g': 0.9, 'category': 'grain'},
      {'name': 'Oats', 'calories_per_100g': 389.0, 'proteins_per_100g': 16.9, 'carbs_per_100g': 66.3, 'fats_per_100g': 6.9, 'category': 'grain'},
      {'name': 'Whole Wheat Bread', 'calories_per_100g': 247.0, 'proteins_per_100g': 13.0, 'carbs_per_100g': 41.0, 'fats_per_100g': 3.4, 'category': 'grain'},
      {'name': 'Pasta', 'calories_per_100g': 131.0, 'proteins_per_100g': 5.0, 'carbs_per_100g': 25.0, 'fats_per_100g': 1.1, 'category': 'grain'},
      {'name': 'Quinoa', 'calories_per_100g': 120.0, 'proteins_per_100g': 4.4, 'carbs_per_100g': 21.3, 'fats_per_100g': 1.9, 'category': 'grain'},
      {'name': 'Sweet Potato', 'calories_per_100g': 86.0, 'proteins_per_100g': 1.6, 'carbs_per_100g': 20.1, 'fats_per_100g': 0.1, 'category': 'grain'},
      {'name': 'Olive Oil', 'calories_per_100g': 884.0, 'proteins_per_100g': 0.0, 'carbs_per_100g': 0.0, 'fats_per_100g': 100.0, 'category': 'other'},
      {'name': 'Almonds', 'calories_per_100g': 579.0, 'proteins_per_100g': 21.0, 'carbs_per_100g': 22.0, 'fats_per_100g': 49.0, 'category': 'other'},
      {'name': 'Walnuts', 'calories_per_100g': 654.0, 'proteins_per_100g': 15.0, 'carbs_per_100g': 13.7, 'fats_per_100g': 65.2, 'category': 'other'},
      {'name': 'Honey', 'calories_per_100g': 304.0, 'proteins_per_100g': 0.3, 'carbs_per_100g': 82.4, 'fats_per_100g': 0.0, 'category': 'other'},
      {'name': 'Dark Chocolate', 'calories_per_100g': 546.0, 'proteins_per_100g': 4.9, 'carbs_per_100g': 61.0, 'fats_per_100g': 31.0, 'category': 'other'},
      {'name': 'Peanut Butter', 'calories_per_100g': 588.0, 'proteins_per_100g': 25.0, 'carbs_per_100g': 20.0, 'fats_per_100g': 50.0, 'category': 'other'},
      {'name': 'Chia Seeds', 'calories_per_100g': 486.0, 'proteins_per_100g': 16.5, 'carbs_per_100g': 42.1, 'fats_per_100g': 30.7, 'category': 'other'}
    ];

    for (final food in defaultFoods) {
      batch.insert('foods', food);
    }
  }

  void _seedReadyMeals(Batch batch) {
        final List<Map<String, dynamic>> defaultReadyMeals = [
      {
        'name': 'Blueberry Pancakes',
        'category': 'breakfast',
        'total_calories': 350.0,
        'image_url': 'pancakes',
        'ingredients': jsonEncode(['Blueberries', 'Oats', 'Egg', 'Semi-skimmed Milk', 'Honey']),
      },
      {
        'name': 'Grilled Chicken Salad',
        'category': 'lunch',
        'total_calories': 400.0,
        'image_url': 'chicken_salad',
        'ingredients': jsonEncode(['Chicken Breast', 'Green Salad', 'Tomato', 'Cucumber', 'Olive Oil']),
      },
      {
        'name': 'Grilled Salmon & Sweet Potato',
        'category': 'dinner',
        'total_calories': 550.0,
        'image_url': 'salmon_sweetpot',
        'ingredients': jsonEncode(['Salmon', 'Sweet Potato', 'Broccoli', 'Olive Oil']),
      },
      {
        'name': 'Banana Honey Oatmeal',
        'category': 'breakfast',
        'total_calories': 280.0,
        'image_url': 'oatmeal',
        'ingredients': jsonEncode(['Oats', 'Banana', 'Semi-skimmed Milk', 'Honey', 'Almonds']),
      },
      {
        'name': 'Strawberry Protein Smoothie',
        'category': 'snack',
        'total_calories': 220.0,
        'image_url': 'smoothie',
        'ingredients': jsonEncode(['Strawberry', 'Greek Yogurt', 'Semi-skimmed Milk', 'Honey', 'Chia Seeds']),
      },
      {
        'name': 'Spinach Omelet',
        'category': 'breakfast',
        'total_calories': 250.0,
        'image_url': 'omelette',
        'ingredients': jsonEncode(['Egg', 'Spinach', 'Tomato', 'Cottage Cheese', 'Butter']),
      },
      {
        'name': 'Avocado & Quinoa Bowl',
        'category': 'lunch',
        'total_calories': 450.0,
        'image_url': 'quinoa_bowl',
        'ingredients': jsonEncode(['Avocado', 'Quinoa', 'Tomato', 'Cucumber', 'Olive Oil']),
      },
      {
        'name': 'Pasta Bolognese',
        'category': 'dinner',
        'total_calories': 600.0,
        'image_url': 'pasta_bolognese',
        'ingredients': jsonEncode(['Pasta', 'Ground Beef', 'Tomato', 'Onion', 'Olive Oil']),
      },
      {
        'name': 'Yogurt with Fruits & Nuts',
        'category': 'snack',
        'total_calories': 180.0,
        'image_url': 'yogurt_nuts',
        'ingredients': jsonEncode(['Greek Yogurt', 'Raspberry', 'Blueberry', 'Walnuts', 'Honey']),
      },
      {
        'name': 'Tofu Stir-fry with Broccoli',
        'category': 'lunch',
        'total_calories': 320.0,
        'image_url': 'tofu_broccoli',
        'ingredients': jsonEncode(['Tofu', 'Broccoli', 'Zucchini', 'Bell Pepper', 'Olive Oil']),
      },
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

  Future<List<ActivityLog>> getActivityLogs(int userId) async {
    final db = await database;
    final List<Map<String, dynamic>> results = await db.query(
      'activity_logs',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'date_time DESC',
    );
    return results.map((row) => ActivityLog.fromJson(row)).toList();
  }

  Future<List<ActivityLog>> getActivityLogsForDate(int userId, String date) async {
    final db = await database;
    final List<Map<String, dynamic>> results = await db.query(
      'activity_logs',
      where: 'user_id = ? AND date_time LIKE ?',
      whereArgs: [userId, '$date%'],
      orderBy: 'date_time DESC',
    );
    return results.map((row) => ActivityLog.fromJson(row)).toList();
  }

  Future<int> insertActivityLog(ActivityLog log) async {
    final db = await database;
    return db.insert('activity_logs', log.toJson());
  }

  Future<int> deleteActivityLog(int id, int userId) async {
    final db = await database;
    return db.delete('activity_logs', where: 'id = ? AND user_id = ?', whereArgs: [id, userId]);
  }

  Future<double> getDailyCaloriesBurned(int userId, String date) async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT SUM(calories_burned) as total FROM activity_logs WHERE user_id = ? AND date_time LIKE ?',
      [userId, '$date%'],
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

  Future<List<MealLog>> getMealLogsForDate(int userId, String date) async {
    final db = await database;
    final List<Map<String, dynamic>> results = await db.query(
      'meal_logs',
      where: 'user_id = ? AND date = ?',
      whereArgs: [userId, date],
    );
    return results.map((row) => MealLog.fromJson(row)).toList();
  }

  Future<int> insertMealLog(MealLog log) async {
    final db = await database;
    return db.insert('meal_logs', log.toJson());
  }

  Future<int> deleteMealLog(int id, int userId) async {
    final db = await database;
    return db.delete('meal_logs', where: 'id = ? AND user_id = ?', whereArgs: [id, userId]);
  }

  /// Get daily sum calories consumed
  Future<double> getDailyCaloriesConsumed(int userId, String date) async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT SUM(calories) as total FROM meal_logs WHERE user_id = ? AND date = ?',
      [userId, date],
    );
    if (result.isEmpty || result.first['total'] == null) return 0.0;
    return (result.first['total'] as num).toDouble();
  }

  /// Get weekly calories consumed history for line chart (past 7 days including selectDate)
  Future<Map<String, double>> getWeeklyCaloriesData(int userId, String selectDateStr) async {
    final db = await database;
    final DateTime targetDate = DateTime.parse(selectDateStr);
    final Map<String, double> result = {};

    for (int i = 6; i >= 0; i--) {
      final DateTime day = targetDate.subtract(Duration(days: i));
      final String dateStr = day.toIso8601String().split('T').first;

      final res = await db.rawQuery(
        'SELECT SUM(calories) as total FROM meal_logs WHERE user_id = ? AND date = ?',
        [userId, dateStr],
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
