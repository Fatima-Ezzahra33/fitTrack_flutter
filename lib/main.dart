/// FitTrack : Main entry point
///
/// Initializes preferences, API service, and setups Providers
/// for MVC Controllers. Sets light/dark themes dynamically using ThemeController.
library;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'controllers/auth_controller.dart';
import 'controllers/comparison_controller.dart';
import 'controllers/food_controller.dart';
import 'controllers/meal_log_controller.dart';
import 'controllers/activity_log_controller.dart';
import 'controllers/weight_history_controller.dart';
import 'controllers/navigation_controller.dart';
import 'controllers/onboarding_controller.dart';
import 'controllers/theme_controller.dart';
import 'core/theme/app_theme.dart';
import 'services/api_service.dart';
import 'services/preferences_service.dart';
import 'views/screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Initialize API Service
  final apiService = ApiService();
  await apiService.initDatabase(); // NOOP for HTTP but kept for compatibility

  // 2. Initialize SharedPreferences Service
  final prefsService = PreferencesService();
  await prefsService.init();

  // 3. Launch Application
  runApp(
    MultiProvider(
      providers: [
        Provider<ApiService>.value(value: apiService),
        Provider<PreferencesService>.value(value: prefsService),
        ChangeNotifierProvider(
          create: (_) => ThemeController(prefsService: prefsService),
        ),
        ChangeNotifierProvider(
          create: (_) => OnboardingController(prefsService: prefsService),
        ),
        ChangeNotifierProvider(
          create: (_) => AuthController(
            apiService: apiService,
            prefsService: prefsService,
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => FoodController(apiService: apiService),
        ),
        ChangeNotifierProvider(
          create: (_) => MealLogController(
            apiService: apiService,
            prefsService: prefsService,
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => ActivityLogController(
            apiService: apiService,
            prefsService: prefsService,
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => WeightHistoryController(apiService: apiService),
        ),
        ChangeNotifierProvider(
          create: (_) => ComparisonController(
            apiService: apiService,
            prefsService: prefsService,
          ),
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
