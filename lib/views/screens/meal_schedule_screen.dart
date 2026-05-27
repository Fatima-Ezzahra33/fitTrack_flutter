/// FitTrack — Meal Schedule Screen (New)
///
/// Features a weekly calendar strip, a chronological daily log view,
/// and a premium fl_chart LineChart showing the weekly calorie history from SQLite.
library;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../controllers/meal_log_controller.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../models/meal_log_model.dart';

class MealScheduleScreen extends StatefulWidget {
  const MealScheduleScreen({super.key});

  @override
  State<MealScheduleScreen> createState() => _MealScheduleScreenState();
}

class _MealScheduleScreenState extends State<MealScheduleScreen> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final mealCtrl = context.watch<MealLogController>();

    // Group logs for the current selected date
    final Map<String, List<MealLog>> grouped = {
      'Breakfast': [],
      'Lunch': [],
      'Dinner': [],
      'Snack': [],
    };
    for (final log in mealCtrl.logs) {
      if (grouped.containsKey(log.mealType)) {
        grouped[log.mealType]!.add(log);
      }
    }

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: isDark ? Colors.white : AppColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Planning des Repas',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: AppSizes.xl, vertical: AppSizes.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Calendar strip selector
            _buildCalendarStrip(isDark, mealCtrl),
            const SizedBox(height: AppSizes.xl),

            // Weekly Chart Section
            Text(
              'Calories de la Semaine',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isDark ? AppColors.textDarkPrimary : AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppSizes.md),
            _buildWeeklyChart(isDark, mealCtrl),
            const SizedBox(height: AppSizes.xl),

            // Grouped daily logs
            Text(
              'Repas du Jour Sélectionné',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isDark ? AppColors.textDarkPrimary : AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppSizes.md),
            ...grouped.entries.map((e) => _buildMealGroup(e.key, e.value, isDark, mealCtrl)),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildCalendarStrip(bool isDark, MealLogController mealCtrl) {
    final today = DateTime.now();
    return SizedBox(
      height: 75,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 7,
        itemBuilder: (context, index) {
          // Centered on today (3 days past, today, 3 days future)
          final day = today.add(Duration(days: index - 3));
          final String dayStr = DateFormat('yyyy-MM-dd').format(day);
          final isSelected = dayStr == mealCtrl.selectedDate;

          final Map<String, String> frenchDays = {
            'Mon': 'Lun',
            'Tue': 'Mar',
            'Wed': 'Mer',
            'Thu': 'Jeu',
            'Fri': 'Ven',
            'Sat': 'Sam',
            'Sun': 'Dim',
          };
          final String enDay = DateFormat('E').format(day);
          final String frDay = frenchDays[enDay] ?? enDay;

          return GestureDetector(
            onTap: () {
              mealCtrl.changeDate(dayStr);
            },
            child: Container(
              width: 52,
              margin: const EdgeInsets.only(right: 10),
              decoration: BoxDecoration(
                gradient: isSelected ? AppColors.primaryGradient : null,
                color: isSelected ? null : (isDark ? AppColors.surfaceDark : Colors.white),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected ? Colors.transparent : (isDark ? AppColors.borderDark : AppColors.borderLight),
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.3),
                          blurRadius: 6,
                          offset: const Offset(0, 3),
                        ),
                      ]
                    : null,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    frDay,
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected ? Colors.white70 : AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    DateFormat('d').format(day),
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.white : (isDark ? AppColors.textDarkPrimary : AppColors.textPrimary),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildWeeklyChart(bool isDark, MealLogController mealCtrl) {
    final entries = mealCtrl.weeklyCaloriesData.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    if (entries.isEmpty) {
      return Container(
        height: 160,
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
        ),
        child: Center(
          child: Text(
            'Pas de données cette semaine',
            style: GoogleFonts.inter(color: AppColors.textSecondary),
          ),
        ),
      );
    }

    final List<FlSpot> spots = [];
    double maxY = 2500.0;
    double minY = 0.0;

    for (int i = 0; i < entries.length; i++) {
      final double cal = entries[i].value;
      spots.add(FlSpot(i.toDouble(), cal));
      if (cal > maxY) {
        maxY = (cal / 500).ceil() * 500.0;
      }
    }

    final double maxVal = spots.isNotEmpty ? spots.map((s) => s.y).reduce((a, b) => a > b ? a : b) : 0;
    maxY = maxVal > 2000 ? maxVal + 400 : 2500;

    return Container(
      height: 190,
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
      ),
      padding: const EdgeInsets.only(top: 24, bottom: 12, right: 20, left: 10),
      child: LineChart(
        LineChartData(
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: 500,
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color: isDark ? AppColors.borderDark.withValues(alpha: 0.5) : AppColors.borderLight.withValues(alpha: 0.6),
                strokeWidth: 1,
              );
            },
          ),
          titlesData: FlTitlesData(
            show: true,
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 1000,
                getTitlesWidget: (value, meta) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: Text(
                      '${value.toInt()} kcal',
                      style: GoogleFonts.inter(fontSize: 9, color: AppColors.textSecondary, fontWeight: FontWeight.bold),
                    ),
                  );
                },
                reservedSize: 55,
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final idx = value.toInt();
                  if (idx >= 0 && idx < entries.length) {
                    final dateStr = entries[idx].key;
                    final date = DateTime.tryParse(dateStr);
                    if (date != null) {
                      final Map<String, String> frenchDaysShort = {
                        'Mon': 'Lun',
                        'Tue': 'Mar',
                        'Wed': 'Mer',
                        'Thu': 'Jeu',
                        'Fri': 'Ven',
                        'Sat': 'Sam',
                        'Sun': 'Dim',
                      };
                      final enDay = DateFormat('E').format(date);
                      return Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          frenchDaysShort[enDay] ?? enDay,
                          style: GoogleFonts.inter(fontSize: 10, color: AppColors.textSecondary, fontWeight: FontWeight.bold),
                        ),
                      );
                    }
                  }
                  return const Text('');
                },
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          minX: 0,
          maxX: entries.length == 1 ? 1.0 : (entries.length - 1).toDouble(),
          minY: minY,
          maxY: maxY,
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: entries.length > 1,
              color: AppColors.primary,
              barWidth: 3.5,
              isStrokeCapRound: true,
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, percent, barData, index) {
                  return FlDotCirclePainter(
                    radius: 4,
                    color: Colors.white,
                    strokeWidth: 3,
                    strokeColor: AppColors.primary,
                  );
                },
              ),
              belowBarData: BarAreaData(
                show: entries.length > 1,
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary.withValues(alpha: 0.25),
                    AppColors.primary.withValues(alpha: 0.0),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMealGroup(String type, List<MealLog> logs, bool isDark, MealLogController mealCtrl) {
    final Map<String, String> labelMap = {
      'Breakfast': 'Petit-Déjeuner',
      'Lunch': 'Déjeuner',
      'Dinner': 'Dîner',
      'Snack': 'Collation',
    };
    final Map<String, IconData> iconMap = {
      'Breakfast': Icons.free_breakfast_rounded,
      'Lunch': Icons.lunch_dining_rounded,
      'Dinner': Icons.dinner_dining_rounded,
      'Snack': Icons.cookie_rounded,
    };
    final double total = logs.fold(0.0, (s, l) => s + l.calories);

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSizes.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(iconMap[type] ?? Icons.restaurant, color: AppColors.primary, size: 18),
              const SizedBox(width: 8),
              Text(
                labelMap[type] ?? type,
                style: GoogleFonts.poppins(
                  fontSize: 14, fontWeight: FontWeight.bold,
                  color: isDark ? AppColors.textDarkPrimary : AppColors.textPrimary,
                ),
              ),
              const Spacer(),
              Text(
                '${total.round()} kcal',
                style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primary),
              ),
            ],
          ),
          const SizedBox(height: 6),
          if (logs.isEmpty)
            Padding(
              padding: const EdgeInsets.only(left: 26, top: 2),
              child: Text(
                'Aucun repas loggé',
                style: GoogleFonts.inter(
                  fontSize: 12, fontStyle: FontStyle.italic,
                  color: isDark ? AppColors.textDarkSecondary : AppColors.textSecondary,
                ),
              ),
            )
          else
            ...logs.map((log) {
              return Dismissible(
                key: Key('sched_meal_${log.id}'),
                direction: DismissDirection.endToStart,
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  margin: const EdgeInsets.only(bottom: 6),
                  decoration: BoxDecoration(
                    color: Colors.redAccent,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(Icons.delete_rounded, color: Colors.white),
                ),
                onDismissed: (_) async {
                  await mealCtrl.removeLog(log.id!);
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('${log.name} supprimé !'),
                        backgroundColor: Colors.redAccent,
                      ),
                    );
                  }
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 6),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.surfaceDark : Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: AppSizes.md, vertical: 10),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              log.name,
                              style: GoogleFonts.poppins(
                                fontSize: 13, fontWeight: FontWeight.bold,
                                color: isDark ? AppColors.textDarkPrimary : AppColors.textPrimary,
                              ),
                            ),
                            Text(
                              '${log.grams.round()}g — ${log.calories.round()} kcal',
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                color: isDark ? AppColors.textDarkSecondary : AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(Icons.chevron_left_rounded, size: 16,
                          color: isDark ? AppColors.textDarkSecondary : AppColors.textSecondary),
                    ],
                  ),
                ),
              );
            }),
        ],
      ),
    );
  }
}
