/// FitTrack — Activity Tab (Redesigned)
///
/// Displays a searchable grid of seeded exercises.
/// Tapping an exercise opens a bottom sheet for logging workout duration.
/// Shows activity history chronologically. No weight tracking here.
library;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../controllers/activity_log_controller.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../models/exercise_model.dart';
import '../../widgets/custom_text_field.dart';

class ActivityTab extends StatefulWidget {
  const ActivityTab({super.key});

  @override
  State<ActivityTab> createState() => _ActivityTabState();
}

class _ActivityTabState extends State<ActivityTab> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showLogWorkoutSheet(Exercise exercise) {
    final TextEditingController durationCtrl = TextEditingController(text: '${exercise.durationMinutes}');
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            final int dur = int.tryParse(durationCtrl.text) ?? 0;
            final double estimatedCal = dur * exercise.caloriesPerMinute;

            return Padding(
              padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
              child: Container(
                decoration: BoxDecoration(
                  color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                ),
                padding: const EdgeInsets.all(AppSizes.xl),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Handle
                    Container(
                      width: 48, height: 4,
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.borderDark : AppColors.borderLight,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(height: AppSizes.lg),

                    // Exercise icon + title
                    Container(
                      width: 64, height: 64,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: AppColors.primaryGradient,
                      ),
                      child: const Icon(Icons.fitness_center_rounded, color: Colors.white, size: 30),
                    ),
                    const SizedBox(height: AppSizes.md),
                    Text(
                      exercise.name,
                      style: GoogleFonts.poppins(
                        fontSize: 22, fontWeight: FontWeight.bold,
                        color: isDark ? AppColors.textDarkPrimary : AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      exercise.category,
                      style: GoogleFonts.inter(fontSize: 14, color: AppColors.primary, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: AppSizes.sm),
                    Text(
                      exercise.description,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: 13, color: isDark ? AppColors.textDarkSecondary : AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: AppSizes.xl),

                    // Duration input
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: durationCtrl,
                            keyboardType: TextInputType.number,
                            onChanged: (_) => setModalState(() {}),
                            decoration: InputDecoration(
                              labelText: 'Durée (minutes)',
                              prefixIcon: const Icon(Icons.timer_outlined, color: AppColors.primary),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                            ),
                            style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSizes.md),

                    // Auto-calculated calories
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(AppSizes.md),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.local_fire_department_rounded, color: Colors.orange, size: 22),
                          const SizedBox(width: 8),
                          Text(
                            'Calories brûlées : ${estimatedCal.round()} kcal',
                            style: GoogleFonts.poppins(
                              fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSizes.xl),

                    // Save button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          final int mins = int.tryParse(durationCtrl.text) ?? 0;
                          if (mins <= 0) return;

                          await context.read<ActivityLogController>().logWorkout(
                            exercise: exercise,
                            durationMinutes: mins,
                          );

                          if (ctx.mounted) {
                            Navigator.pop(ctx);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('${exercise.name} enregistré — ${(mins * exercise.caloriesPerMinute).round()} kcal brûlées !'),
                                backgroundColor: AppColors.success,
                              ),
                            );
                          }
                        },
                        icon: const Icon(Icons.save_rounded, color: Colors.white),
                        label: Text(
                          'Enregistrer la Séance',
                          style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          minimumSize: const Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSizes.md),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final controller = context.watch<ActivityLogController>();

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        title: Text(
          'Activités',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
      ),
      body: controller.isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : Column(
              children: [
                // Search bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSizes.xl),
                  child: CustomTextField(
                    hint: 'Rechercher un exercice...',
                    icon: Icons.search_rounded,
                    controller: _searchController,
                    onChanged: (val) => controller.searchExercises(val),
                  ),
                ),
                const SizedBox(height: AppSizes.md),

                // Exercises grid
                Expanded(
                  child: DefaultTabController(
                    length: 2,
                    child: Column(
                      children: [
                        TabBar(
                          labelColor: AppColors.primary,
                          unselectedLabelColor: isDark ? AppColors.textDarkSecondary : AppColors.textSecondary,
                          indicatorColor: AppColors.primary,
                          labelStyle: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 14),
                          tabs: const [
                            Tab(text: 'Exercices'),
                            Tab(text: 'Historique'),
                          ],
                        ),
                        Expanded(
                          child: TabBarView(
                            children: [
                              _buildExercisesList(controller, isDark),
                              _buildHistoryList(controller, isDark),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildExercisesList(ActivityLogController controller, bool isDark) {
    final exercises = controller.searchResults;

    if (exercises.isEmpty) {
      return Center(
        child: Text('Aucun exercice trouvé.',
          style: GoogleFonts.inter(color: isDark ? AppColors.textDarkSecondary : AppColors.textSecondary)),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(AppSizes.xl),
      itemCount: exercises.length,
      separatorBuilder: (_, __) => const SizedBox(height: AppSizes.md),
      itemBuilder: (context, index) {
        final exercise = exercises[index];

        return InkWell(
          onTap: () => _showLogWorkoutSheet(exercise),
          borderRadius: BorderRadius.circular(18),
          child: Container(
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceDark : Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 8, offset: const Offset(0, 3),
                ),
              ],
            ),
            padding: const EdgeInsets.all(AppSizes.lg),
            child: Row(
              children: [
                Container(
                  width: 52, height: 52,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primary.withValues(alpha: 0.1),
                  ),
                  child: Icon(
                    exercise.category == 'Cardio'
                        ? Icons.directions_run_rounded
                        : exercise.category == 'Souplesse'
                            ? Icons.self_improvement_rounded
                            : Icons.fitness_center_rounded,
                    color: AppColors.primary, size: 26,
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
                          fontSize: 15, fontWeight: FontWeight.bold,
                          color: isDark ? AppColors.textDarkPrimary : AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${exercise.category} • ${exercise.caloriesPerMinute.round()} kcal/min',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: isDark ? AppColors.textDarkSecondary : AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${exercise.durationMinutes} min',
                    style: GoogleFonts.inter(
                      fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHistoryList(ActivityLogController controller, bool isDark) {
    final logs = controller.activityLogs;

    if (logs.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history_rounded, size: 48, color: AppColors.textSecondary.withValues(alpha: 0.4)),
            const SizedBox(height: AppSizes.md),
            Text(
              'Aucune activité enregistrée.',
              style: GoogleFonts.inter(color: isDark ? AppColors.textDarkSecondary : AppColors.textSecondary),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(AppSizes.xl),
      itemCount: logs.length,
      separatorBuilder: (_, __) => const SizedBox(height: AppSizes.sm),
      itemBuilder: (context, index) {
        final log = logs[index];
        final parts = log.dateTime.split(' ');
        final String timeStr = parts.length > 1 ? parts[1] : '';
        final String dateStr = parts.isNotEmpty ? parts[0] : '';
        final bool isToday = dateStr == DateTime.now().toIso8601String().split('T').first;

        return Dismissible(
          key: Key('activity_${log.id}'),
          direction: DismissDirection.endToStart,
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            decoration: BoxDecoration(
              color: Colors.redAccent, borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.delete_rounded, color: Colors.white),
          ),
          onDismissed: (_) => controller.removeLog(log.id!),
          child: Container(
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceDark : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
            ),
            padding: const EdgeInsets.all(AppSizes.md),
            child: Row(
              children: [
                Container(
                  width: 44, height: 44,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.success.withValues(alpha: 0.12),
                  ),
                  child: const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 22),
                ),
                const SizedBox(width: AppSizes.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        log.name,
                        style: GoogleFonts.poppins(
                          fontSize: 14, fontWeight: FontWeight.bold,
                          color: isDark ? AppColors.textDarkPrimary : AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        '${log.durationMinutes} min — ${log.caloriesBurned.round()} kcal — ${isToday ? "Aujourd'hui" : dateStr} $timeStr',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          color: isDark ? AppColors.textDarkSecondary : AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
