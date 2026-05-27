/// FitTrack — Main entry point
///
/// Initializes preferences, SQLite database, and setups Providers
/// for MVC Controllers. Sets light/dark themes dynamically using ThemeController.
library;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'controllers/auth_controller.dart';
import 'controllers/food_controller.dart';
import 'controllers/meal_log_controller.dart';
import 'controllers/activity_log_controller.dart';
import 'controllers/weight_history_controller.dart';
import 'controllers/navigation_controller.dart';
import 'controllers/onboarding_controller.dart';
import 'controllers/theme_controller.dart';
import 'core/theme/app_theme.dart';
import 'services/database_service.dart';
import 'services/preferences_service.dart';
import 'views/screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Initialize SQLite Database
  final dbService = DatabaseService();
  await dbService.initDatabase();

  // 2. Initialize SharedPreferences Service
  final prefsService = PreferencesService();
  await prefsService.init();

  // 3. Launch Application
  runApp(
    MultiProvider(
      providers: [
        Provider<DatabaseService>.value(value: dbService),
        Provider<PreferencesService>.value(value: prefsService),
        ChangeNotifierProvider(
          create: (_) => ThemeController(prefsService: prefsService),
        ),
        ChangeNotifierProvider(
          create: (_) => OnboardingController(prefsService: prefsService),
        ),
        ChangeNotifierProvider(
          create: (_) => AuthController(
            dbService: dbService,
            prefsService: prefsService,
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => FoodController(dbService: dbService),
        ),
        ChangeNotifierProvider(
          create: (_) => MealLogController(dbService: dbService),
        ),
        ChangeNotifierProvider(
          create: (_) => ActivityLogController(dbService: dbService),
        ),
        ChangeNotifierProvider(
          create: (_) => WeightHistoryController(dbService: dbService),
        ),
        ChangeNotifierProvider(
          create: (_) => NavigationController(),
        ),
      ],
      child: const FitTrackApp(),
    ),
  );
}

class FitTrackApp extends StatelessWidget {
  const FitTrackApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeController>(
      builder: (context, themeController, child) {
        return MaterialApp(
          title: 'FitTrack',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeController.themeMode,
          home: const SplashScreen(),
        );
      },
    );
  }
}
