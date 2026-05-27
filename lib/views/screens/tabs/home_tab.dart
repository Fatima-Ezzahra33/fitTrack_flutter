/// FitTrack — Home Tab (Redesigned)
///
/// Implements a premium dashboard interface in French. Displays greeting, current date,
/// calculated BMI status card, Weight Overview Card (last recorded weight, trend arrow,
/// mini weekly fl_chart, navigate to WeightHistoryScreen), Today's Summary (meals calories,
/// activity calories burned, count of workouts), and recommended workouts.
library;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../controllers/auth_controller.dart';
import '../../../controllers/weight_history_controller.dart';
import '../../../controllers/meal_log_controller.dart';
import '../../../controllers/activity_log_controller.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../widgets/weight_mini_chart.dart';
import '../weight_history_screen.dart';

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  void _loadData() {
    final user = context.read<AuthController>().currentUser;
    if (user != null && user.id != null) {
      context.read<WeightHistoryController>().loadWeightHistory(user.id!);
      context.read<ActivityLogController>().loadLogs();
    }
  }

  String _getFrenchDate() {
    final now = DateTime.now();
    final Map<int, String> months = {
      1: 'Janvier', 2: 'Février', 3: 'Mars', 4: 'Avril', 5: 'Mai', 6: 'Juin',
      7: 'Juillet', 8: 'Août', 9: 'Septembre', 10: 'Octobre', 11: 'Novembre', 12: 'Décembre'
    };
    final Map<int, String> days = {
      1: 'Lundi', 2: 'Mardi', 3: 'Mercredi', 4: 'Jeudi', 5: 'Vendredi', 6: 'Samedi', 7: 'Dimanche'
    };
    return '${days[now.weekday]} ${now.day} ${months[now.month]} ${now.year}';
  }

  String _getBmiCategory(double bmi) {
    if (bmi < 18.5) return 'Insuffisance pondérale (Maigreur)';
    if (bmi < 25.0) return 'Poids normal (Santé)';
    if (bmi < 30.0) return 'Surpoids';
    return 'Obésité';
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final user = context.watch<AuthController>().currentUser;
    final weightCtrl = context.watch<WeightHistoryController>();
    final mealCtrl = context.watch<MealLogController>();
    final activityCtrl = context.watch<ActivityLogController>();

    if (user == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: AppColors.primary)),
      );
    }

    final double bmiValue = user.bmi ?? 0.0;
    final String bmiCategory = _getBmiCategory(bmiValue);
    final String formattedDate = _getFrenchDate();

    // Workouts completed today count
    final String todayPrefix = DateTime.now().toIso8601String().split('T').first;
    final int todayWorkoutsCount = activityCtrl.activityLogs
        .where((log) => log.dateTime.startsWith(todayPrefix))
        .length;

    // Weight Overview details
    final double latestWeight = weightCtrl.latestWeight?.weight ?? user.weight ?? 75.0;
    final String trendArrow = weightCtrl.getTrendArrow();

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      body: RefreshIndicator(
        onRefresh: () async {
          _loadData();
          await mealCtrl.loadLogsForDate(mealCtrl.selectedDate);
        },
        color: AppColors.primary,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: AppSizes.xl, vertical: AppSizes.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppSizes.lg),

              // Personalized greeting
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Bonjour,',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: isDark ? AppColors.textDarkSecondary : AppColors.textSecondary,
                        ),
                      ),
                      Text(
                        '${user.firstName} 👋',
                        style: GoogleFonts.poppins(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: isDark ? AppColors.textDarkPrimary : AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: AppColors.primaryGradient,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.25),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        user.firstName[0].toUpperCase(),
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSizes.md),
              Text(
                formattedDate,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: AppSizes.xl),

              // BMI Card (Existing Design maintained)
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(AppSizes.xl),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Statut IMC',
                            style: GoogleFonts.poppins(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            bmiCategory,
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: Colors.white.withValues(alpha: 0.9),
                            ),
                          ),
                          const SizedBox(height: AppSizes.sm),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.18),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              'Référence : 18.5 - 25.0',
                              style: GoogleFonts.inter(
                                fontSize: 10,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 68,
                      height: 68,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                      ),
                      child: Center(
                        child: Text(
                          bmiValue.toStringAsFixed(1),
                          style: GoogleFonts.poppins(
                            fontSize: 19,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryDark,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSizes.xl),

              // Weight Overview Card (NEW)
              Text(
                'Suivi du Poids',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppColors.textDarkPrimary : AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: AppSizes.md),
              Container(
                decoration: BoxDecoration(
                  color: isDark ? AppColors.surfaceDark : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
                ),
                padding: const EdgeInsets.all(AppSizes.lg),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Dernier poids mesuré',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                color: isDark ? AppColors.textDarkSecondary : AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Row(
                              children: [
                                Text(
                                  '${latestWeight.toStringAsFixed(1)} kg',
                                  style: GoogleFonts.poppins(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: isDark ? AppColors.textDarkPrimary : AppColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  trendArrow,
                                  style: const TextStyle(fontSize: 18),
                                ),
                              ],
                            ),
                          ],
                        ),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => const WeightHistoryScreen()),
                            ).then((_) => _loadData());
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary.withValues(alpha: 0.12),
                            foregroundColor: AppColors.primary,
                            elevation: 0,
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          ),
                          child: Text(
                            'Historique',
                            style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSizes.md),
                    // Weight Mini Chart
                    WeightMiniChart(entries: weightCtrl.weightEntries),
                  ],
                ),
              ),
              const SizedBox(height: AppSizes.xl),

              // Today's Summary Section (NEW)
              Text(
                "Aujourd'hui",
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppColors.textDarkPrimary : AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: AppSizes.md),
              Row(
                children: [
                  _buildSummaryCard(
                    'Consommé',
                    '${mealCtrl.todayCalories.round()} kcal',
                    Icons.restaurant_menu_rounded,
                    AppColors.primary,
                    isDark,
                  ),
                  const SizedBox(width: 10),
                  _buildSummaryCard(
                    'Brûlé',
                    '${activityCtrl.todayCaloriesBurned.round()} kcal',
                    Icons.local_fire_department_rounded,
                    Colors.orange,
                    isDark,
                  ),
                  const SizedBox(width: 10),
                  _buildSummaryCard(
                    'Séances',
                    '$todayWorkoutsCount',
                    Icons.check_circle_rounded,
                    AppColors.success,
                    isDark,
                  ),
                ],
              ),
              const SizedBox(height: AppSizes.xl),

              // Recommended Workouts
              Text(
                'Entraînements Recommandés',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppColors.textDarkPrimary : AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: AppSizes.md),
              _buildRecommendedExercises(activityCtrl, isDark),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCard(String title, String val, IconData icon, Color color, bool isDark) {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
        ),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color.withValues(alpha: 0.12),
              ),
              child: Icon(icon, color: color, size: 18),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: GoogleFonts.inter(
                fontSize: 11,
                color: isDark ? AppColors.textDarkSecondary : AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              val,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: isDark ? AppColors.textDarkPrimary : AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendedExercises(ActivityLogController activityCtrl, bool isDark) {
    final exercises = activityCtrl.exercises.take(3).toList();
    if (exercises.isEmpty) {
      return Center(
        child: Text(
          'Aucun entraînement disponible.',
          style: GoogleFonts.inter(color: AppColors.textSecondary),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: exercises.length,
      separatorBuilder: (_, __) => const SizedBox(height: AppSizes.md),
      itemBuilder: (context, index) {
        final exercise = exercises[index];

        return Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.surfaceDark : Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
          ),
          padding: const EdgeInsets.all(AppSizes.md),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary.withValues(alpha: 0.1),
                ),
                child: Icon(
                  exercise.category == 'Cardio'
                      ? Icons.directions_run_rounded
                      : Icons.fitness_center_rounded,
                  color: AppColors.primary,
                  size: 22,
                ),
              ),
              const SizedBox(width: AppSizes.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      exercise.name,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: isDark ? AppColors.textDarkPrimary : AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${exercise.category} • ${exercise.caloriesPerMinute.round()} kcal/min',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: isDark ? AppColors.textDarkSecondary : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${exercise.durationMinutes} min',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
