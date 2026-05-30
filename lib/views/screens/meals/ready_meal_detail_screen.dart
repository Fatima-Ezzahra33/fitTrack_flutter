/// FitTrack : Ready Meal Detail Screen
///
/// Premium French UI details page for a recipe / ready meal.
/// Displays ingredients and allows the user to log the entire meal.
library;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../controllers/meal_log_controller.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../models/ready_meal_model.dart';

class ReadyMealDetailScreen extends StatefulWidget {
  final ReadyMeal meal;

  const ReadyMealDetailScreen({super.key, required this.meal});

  @override
  State<ReadyMealDetailScreen> createState() => _ReadyMealDetailScreenState();
}

class _ReadyMealDetailScreenState extends State<ReadyMealDetailScreen> {
  late String _selectedMealType;

  @override
  void initState() {
    super.initState();
    // Default selected meal type based on recipe category, matched to standard MealTypes
    final String cat = widget.meal.category.toLowerCase();
    if (cat == 'breakfast') {
      _selectedMealType = 'Breakfast';
    } else if (cat == 'lunch') {
      _selectedMealType = 'Lunch';
    } else if (cat == 'dinner') {
      _selectedMealType = 'Dinner';
    } else {
      _selectedMealType = 'Snack';
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final String cat = widget.meal.category.toLowerCase();

    // Color definitions for category
    final Map<String, Color> catColor = {
      'breakfast': AppColors.success,
      'lunch': AppColors.primary,
      'dinner': Colors.deepOrange,
      'snack': Colors.teal,
    };
    final Color accent = catColor[cat] ?? AppColors.primary;

    final Map<String, String> catLabel = {
      'breakfast': 'Breakfast',
      'lunch': 'Lunch',
      'dinner': 'Dinner',
      'snack': 'Snack',
    };

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      body: CustomScrollView(
        slivers: [
          // Elegant Header with gradient image background
          SliverAppBar(
            expandedHeight: 250,
            pinned: true,
            backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      accent.withValues(alpha: 0.8),
                      accent.withValues(alpha: 0.15),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Backdrop icon design
                    Opacity(
                      opacity: 0.15,
                      child: Icon(Icons.restaurant_menu_rounded, size: 200, color: isDark ? Colors.white : Colors.black),
                    ),
                    Positioned(
                      bottom: 40,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.surfaceDark : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.local_fire_department_rounded, color: Colors.orange, size: 20),
                            const SizedBox(width: 6),
                            Text(
                              '${widget.meal.totalCalories.round()} kcal',
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: isDark ? AppColors.textDarkPrimary : AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),

          // Main contents
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppSizes.xl),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Recipe Tag Category
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: accent.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: accent.withValues(alpha: 0.3)),
                    ),
                    child: Text(
                      catLabel[cat] ?? widget.meal.category,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: accent,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSizes.md),

                  // Recipe Name
                  Text(
                    widget.meal.name,
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: isDark ? AppColors.textDarkPrimary : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: AppSizes.md),

                  // Dividers
                  Divider(color: isDark ? AppColors.borderDark : AppColors.borderLight, thickness: 1),
                  const SizedBox(height: AppSizes.md),

                  // Ingredients subtitle
                  Text(
                    'Ingredients',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDark ? AppColors.textDarkPrimary : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: AppSizes.sm),

                  // Ingredients list cards
                  ...widget.meal.ingredients.map((ing) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(AppSizes.md),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.surfaceDark : Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isDark ? AppColors.borderDark : AppColors.borderLight,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.primary.withValues(alpha: 0.1),
                            ),
                            child: const Icon(Icons.check_rounded, color: AppColors.primary, size: 16),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              ing,
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                color: isDark ? AppColors.textDarkPrimary : AppColors.textPrimary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),

                  const SizedBox(height: AppSizes.xl),
                  Divider(color: isDark ? AppColors.borderDark : AppColors.borderLight, thickness: 1),
                  const SizedBox(height: AppSizes.md),

                  // Meal Type selection logic
                  Text(
                    'Log this meal under:',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isDark ? AppColors.textDarkPrimary : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: AppSizes.sm),

                  DropdownButtonFormField<String>(
                    value: _selectedMealType,
                    style: GoogleFonts.poppins(
                      color: isDark ? AppColors.textDarkPrimary : AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: isDark ? AppColors.surfaceDark : AppColors.inputFillLight,
                      contentPadding: const EdgeInsets.symmetric(horizontal: AppSizes.md, vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(color: isDark ? AppColors.borderDark : AppColors.borderLight),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(color: isDark ? AppColors.borderDark : AppColors.borderLight),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: AppColors.primary, width: 2),
                      ),
                    ),
                    dropdownColor: isDark ? AppColors.surfaceDark : Colors.white,
                    items: const [
                      DropdownMenuItem(value: 'Breakfast', child: Text('Breakfast')),
                      DropdownMenuItem(value: 'Lunch', child: Text('Lunch')),
                      DropdownMenuItem(value: 'Dinner', child: Text('Dinner')),
                      DropdownMenuItem(value: 'Snack', child: Text('Snack')),
                    ],
                    onChanged: (val) {
                      if (val != null) {
                        setState(() {
                          _selectedMealType = val;
                        });
                      }
                    },
                  ),

                  const SizedBox(height: AppSizes.xl),

                  // Button Log meal
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        final mealLogCtrl = context.read<MealLogController>();
                        await mealLogCtrl.logReadyMeal(
                          meal: widget.meal,
                          mealType: _selectedMealType,
                        );

                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('${widget.meal.name} logged for $_selectedMealType!'),
                              backgroundColor: AppColors.success,
                            ),
                          );
                          Navigator.of(context).pop();
                        }
                      },
                      icon: const Icon(Icons.add_task_rounded, color: Colors.white),
                      label: Text(
                        'Log this Meal',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 2,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSizes.xl),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
