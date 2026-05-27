/// FitTrack — Meals Tab (New)
///
/// Full meal tracking tab: calorie progress, food log modal,
/// today's meals grouped by type with swipe-to-delete,
/// and ready meals recipe browser.
library;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../controllers/food_controller.dart';
import '../../../controllers/meal_log_controller.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../models/food_model.dart';
import '../../../models/meal_log_model.dart';
import '../../../models/ready_meal_model.dart';
import '../../widgets/calorie_progress_bar.dart';
import '../meals/ready_meal_detail_screen.dart';
import '../meal_schedule_screen.dart';

class MealsTab extends StatefulWidget {
  const MealsTab({super.key});

  @override
  State<MealsTab> createState() => _MealsTabState();
}

class _MealsTabState extends State<MealsTab> {
  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final mealCtrl = context.watch<MealLogController>();

    // Group logs
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
        title: Text(
          'Repas',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_month_rounded, color: AppColors.primary),
            tooltip: 'Historique & Planning',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const MealScheduleScreen()),
              );
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        onPressed: () => _showAddFoodLogModal(isDark),
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
      body: mealCtrl.isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: AppSizes.xl, vertical: AppSizes.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Calorie bar
                  CalorieProgressBar(
                    current: mealCtrl.todayCalories,
                    goal: mealCtrl.dailyCaloriesGoal,
                  ),
                  const SizedBox(height: AppSizes.xl),

                  // Today's meals grouped
                  Text(
                    'Repas du Jour',
                    style: GoogleFonts.poppins(
                      fontSize: 18, fontWeight: FontWeight.bold,
                      color: isDark ? AppColors.textDarkPrimary : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: AppSizes.md),
                  ...grouped.entries.map((e) => _buildMealGroup(e.key, e.value, isDark)),
                  const SizedBox(height: AppSizes.xl),

                  // Ready Meals
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Recettes Prêtes',
                        style: GoogleFonts.poppins(
                          fontSize: 18, fontWeight: FontWeight.bold,
                          color: isDark ? AppColors.textDarkPrimary : AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        '${mealCtrl.readyMeals.length} recettes',
                        style: GoogleFonts.inter(fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSizes.md),
                  _buildReadyMealsList(mealCtrl.readyMeals, isDark),
                  const SizedBox(height: 80),
                ],
              ),
            ),
    );
  }

  Widget _buildMealGroup(String type, List<MealLog> logs, bool isDark) {
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
              Icon(iconMap[type] ?? Icons.restaurant, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                labelMap[type] ?? type,
                style: GoogleFonts.poppins(
                  fontSize: 15, fontWeight: FontWeight.bold,
                  color: isDark ? AppColors.textDarkPrimary : AppColors.textPrimary,
                ),
              ),
              const Spacer(),
              Text(
                '${total.round()} kcal',
                style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primary),
              ),
            ],
          ),
          const SizedBox(height: 6),
          if (logs.isEmpty)
            Padding(
              padding: const EdgeInsets.only(left: 28),
              child: Text(
                'Aucun repas ajouté',
                style: GoogleFonts.inter(
                  fontSize: 12, fontStyle: FontStyle.italic,
                  color: isDark ? AppColors.textDarkSecondary : AppColors.textSecondary,
                ),
              ),
            )
          else
            ...logs.map((log) {
              return Dismissible(
                key: Key('meal_${log.id}'),
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
                onDismissed: (_) => context.read<MealLogController>().removeLog(log.id!),
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

  Widget _buildReadyMealsList(List<ReadyMeal> meals, bool isDark) {
    if (meals.isEmpty) {
      return Text('Aucune recette disponible.', style: GoogleFonts.inter(color: AppColors.textSecondary));
    }

    return SizedBox(
      height: 195,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: meals.length,
        itemBuilder: (context, index) {
          final meal = meals[index];
          final Map<String, Color> catColor = {
            'breakfast': AppColors.success,
            'lunch': AppColors.primary,
            'dinner': Colors.deepOrange,
            'snack': Colors.teal,
          };
          final Color accent = catColor[meal.category] ?? AppColors.primary;

          return GestureDetector(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => ReadyMealDetailScreen(meal: meal)),
              );
            },
            child: Container(
              width: 155,
              margin: const EdgeInsets.only(right: 14),
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: accent.withValues(alpha: 0.2)),
              ),
              padding: const EdgeInsets.all(AppSizes.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 50, height: 50,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: accent.withValues(alpha: 0.15),
                    ),
                    child: Icon(Icons.restaurant_menu_rounded, color: accent, size: 24),
                  ),
                  const Spacer(),
                  Text(
                    meal.name,
                    maxLines: 2, overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold, fontSize: 13,
                      color: isDark ? Colors.white : AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    '${meal.totalCalories.round()} kcal • ${meal.ingredients.length} ingrédients',
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      color: isDark ? Colors.white70 : AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    height: 28,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => ReadyMealDetailScreen(meal: meal)),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: accent,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        padding: EdgeInsets.zero,
                      ),
                      child: Text('Voir', style: GoogleFonts.poppins(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
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

  void _showAddFoodLogModal(bool isDark) {
    final TextEditingController searchCtrl = TextEditingController();
    final TextEditingController gramsCtrl = TextEditingController(text: '100');
    Food? selectedFood;
    String selectedMealType = 'Breakfast';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            final foodCtrl = context.read<FoodController>();

            return Padding(
              padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
              child: Container(
                height: MediaQuery.of(ctx).size.height * 0.85,
                decoration: BoxDecoration(
                  color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                ),
                padding: const EdgeInsets.all(AppSizes.xl),
                child: Column(
                  children: [
                    // Handle
                    Container(
                      width: 48, height: 4,
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.borderDark : AppColors.borderLight,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(height: AppSizes.md),
                    Text(
                      'Ajouter un Aliment',
                      style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: AppSizes.md),

                    // Search
                    TextField(
                      controller: searchCtrl,
                      onChanged: (val) {
                        foodCtrl.searchCatalog(val);
                        setModalState(() {});
                      },
                      decoration: InputDecoration(
                        hintText: 'Rechercher un aliment...',
                        prefixIcon: const Icon(Icons.search_rounded, color: AppColors.primary),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                    ),
                    const SizedBox(height: AppSizes.md),

                    // If food is selected → show details
                    if (selectedFood != null) ...[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(AppSizes.md),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(selectedFood!.name,
                                style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.primary)),
                            const SizedBox(height: 4),
                            Text('${selectedFood!.caloriesPer100g.round()} kcal/100g • P: ${selectedFood!.proteinsPer100g}g • C: ${selectedFood!.carbsPer100g}g • F: ${selectedFood!.fatsPer100g}g',
                                style: GoogleFonts.inter(fontSize: 12)),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSizes.md),
                      // Grams
                      TextField(
                        controller: gramsCtrl,
                        keyboardType: TextInputType.number,
                        onChanged: (_) => setModalState(() {}),
                        decoration: InputDecoration(
                          labelText: 'Quantité (grammes)',
                          prefixIcon: const Icon(Icons.scale_rounded, color: AppColors.primary),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                      ),
                      const SizedBox(height: AppSizes.sm),
                      // Meal type dropdown
                      DropdownButtonFormField<String>(
                        value: selectedMealType,
                        decoration: InputDecoration(
                          labelText: 'Type de repas',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        items: ['Breakfast', 'Lunch', 'Dinner', 'Snack']
                            .map((v) => DropdownMenuItem(value: v, child: Text(v)))
                            .toList(),
                        onChanged: (v) {
                          if (v != null) setModalState(() => selectedMealType = v);
                        },
                      ),
                      const SizedBox(height: AppSizes.sm),
                      // Auto calc
                      Builder(builder: (_) {
                        final g = double.tryParse(gramsCtrl.text) ?? 100;
                        final cal = (selectedFood!.caloriesPer100g * g) / 100;
                        return Text(
                          '≈ ${cal.round()} kcal pour ${g.round()}g',
                          style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.primary),
                        );
                      }),
                      const SizedBox(height: AppSizes.md),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () async {
                            final g = double.tryParse(gramsCtrl.text) ?? 100;
                            await context.read<MealLogController>().logFoodPortion(
                              food: selectedFood!,
                              grams: g,
                              mealType: selectedMealType,
                            );
                            if (ctx.mounted) {
                              Navigator.pop(ctx);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('${selectedFood!.name} ajouté !'),
                                  backgroundColor: AppColors.success,
                                ),
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            minimumSize: const Size(double.infinity, 48),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                          child: Text('Ajouter au Journal', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.white)),
                        ),
                      ),
                    ] else ...[
                      // List of foods to select
                      Expanded(
                        child: Material(
                          type: MaterialType.transparency,
                          child: ListView.builder(
                            itemCount: foodCtrl.searchResults.length,
                            itemBuilder: (_, i) {
                              final food = foodCtrl.searchResults[i];
                              return ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                                  child: const Icon(Icons.restaurant_rounded, color: AppColors.primary, size: 18),
                                ),
                                title: Text(food.name, style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 14)),
                                subtitle: Text(
                                  '${food.caloriesPer100g.round()} kcal/100g — ${food.category}',
                                  style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary),
                                ),
                                onTap: () {
                                  setModalState(() {
                                    selectedFood = food;
                                  });
                                },
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
