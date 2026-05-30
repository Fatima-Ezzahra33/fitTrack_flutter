/// FitTrack : Registration Step 3 (Goal Selection)
///
/// Implements visual goal selection cards with gradient accents. Conditionally displays
/// Goal Weight text input if 'Lose Weight' or 'Gain Muscle' is chosen. Has loading states
/// and triggers the sqlite user insertion using AuthController.register().
library;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../controllers/auth_controller.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_strings.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/gradient_button.dart';
import '../../widgets/step_progress_bar.dart';
import '../main_shell.dart';

class RegisterStep3Screen extends StatefulWidget {
  const RegisterStep3Screen({super.key});

  @override
  State<RegisterStep3Screen> createState() => _RegisterStep3ScreenState();
}

class _RegisterStep3ScreenState extends State<RegisterStep3Screen> {
  final _formKey = GlobalKey<FormState>();
  final _goalWeightController = TextEditingController();
  String? _selectedGoalKey;

  final List<Map<String, dynamic>> _goals = [
    {
      'key': 'lose_weight',
      'title': AppStrings.loseWeight,
      'description': 'Burn fat and get leaner',
      'icon': Icons.trending_down_rounded,
      'imageUrl': 'https://images.unsplash.com/photo-1518611012118-696072aa579a?auto=format&fit=crop&w=400&q=80',
    },
    {
      'key': 'gain_muscle',
      'title': AppStrings.gainMuscle,
      'description': 'Build strength and muscle mass',
      'icon': Icons.fitness_center_rounded,
      'imageUrl': 'https://images.unsplash.com/photo-1581009146145-b5ef050c2e1e?auto=format&fit=crop&w=400&q=80',
    },
    {
      'key': 'keep_fit',
      'title': AppStrings.keepFit,
      'description': 'Maintain healthy weight and energy',
      'icon': Icons.favorite_rounded,
      'imageUrl': 'https://images.unsplash.com/photo-1571019614242-c5c5dee9f50b?auto=format&fit=crop&w=400&q=80',
    },
    {
      'key': 'improve_sleep',
      'title': AppStrings.improveSleep,
      'description': 'Enhance recovery and sleep quality',
      'icon': Icons.nightlight_round,
      'imageUrl': 'https://images.unsplash.com/photo-1541781774459-bb2af2f05b55?auto=format&fit=crop&w=400&q=80',
    },
  ];

  @override
  void dispose() {
    _goalWeightController.dispose();
    super.dispose();
  }

  bool _shouldShowGoalWeight() {
    return _selectedGoalKey == 'lose_weight' || _selectedGoalKey == 'gain_muscle';
  }

  void _handleRegister() async {
    if (_selectedGoalKey == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please select a fitness goal.',
            style: GoogleFonts.inter(color: Colors.white),
          ),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(AppSizes.md),
        ),
      );
      return;
    }

    if (_shouldShowGoalWeight() && !_formKey.currentState!.validate()) {
      return;
    }

    final authController = context.read<AuthController>();
    authController.saveStep3(
      goalType: _selectedGoalKey,
      goalWeight: _shouldShowGoalWeight()
          ? double.tryParse(_goalWeightController.text)
          : null,
    );

    final success = await authController.register();

    if (!mounted) return;

    if (success) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const MainShell()),
        (route) => false,
      );
    } else {
      final errorMessage = authController.error ?? AppStrings.registrationFailed;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            errorMessage,
            style: GoogleFonts.inter(color: Colors.white),
          ),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(AppSizes.md),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final isLoading = context.watch<AuthController>().isLoading;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.xl,
            vertical: AppSizes.lg,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Back Arrow
                IconButton(
                  padding: EdgeInsets.zero,
                  alignment: Alignment.centerLeft,
                  icon: const Icon(Icons.arrow_back_ios_new_rounded),
                  color: isDark ? AppColors.textDarkPrimary : AppColors.textPrimary,
                  onPressed: () {
                    final authController = context.read<AuthController>();
                    authController.setStep(1);
                    Navigator.of(context).pop();
                  },
                ),
                const SizedBox(height: AppSizes.sm),

                // Title
                Text(
                  AppStrings.createAccount,
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppColors.textDarkPrimary : AppColors.textPrimary,
                  ),
                ),
                Text(
                  AppStrings.registerSubtitle,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: isDark ? AppColors.textDarkSecondary : AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSizes.xl),

                // Progress Indicator
                const StepProgressBar(
                  currentStep: 2,
                  stepLabels: [
                    AppStrings.step1Title,
                    AppStrings.step2Title,
                    AppStrings.step3Title,
                  ],
                ),
                const SizedBox(height: AppSizes.xxl),

                // Goal Instructions
                Text(
                  AppStrings.goalType,
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppColors.textDarkPrimary : AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: AppSizes.xs),
                Text(
                  'Choose the goal that best fits your training preference.',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: isDark ? AppColors.textDarkSecondary : AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSizes.xl),

                // Goal Cards Grid (2x2)
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: AppSizes.md,
                    mainAxisSpacing: AppSizes.md,
                    childAspectRatio: 0.85,
                  ),
                  itemCount: _goals.length,
                  itemBuilder: (context, index) {
                    final goal = _goals[index];
                    final String key = goal['key'];
                    final bool isSelected = _selectedGoalKey == key;

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedGoalKey = key;
                        });
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                          borderRadius: BorderRadius.circular(16),
                          image: DecorationImage(
                            image: NetworkImage(goal['imageUrl']),
                            fit: BoxFit.cover,
                            colorFilter: ColorFilter.mode(
                              isSelected 
                                ? AppColors.primary.withValues(alpha: 0.5) 
                                : Colors.black.withValues(alpha: 0.6),
                              BlendMode.darken,
                            ),
                          ),
                          border: Border.all(
                            color: isSelected ? AppColors.primary : Colors.transparent,
                            width: 2,
                          ),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: AppColors.primary.withValues(alpha: 0.3),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ]
                              : null,
                        ),
                        padding: const EdgeInsets.all(AppSizes.md),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Beautiful Gradient/Primary Circle for Icon
                            Container(
                              padding: const EdgeInsets.all(AppSizes.sm),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isSelected
                                    ? AppColors.primary
                                    : Colors.white.withValues(alpha: 0.2),
                              ),
                              child: Icon(
                                goal['icon'],
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              goal['title'],
                              style: GoogleFonts.poppins(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              goal['description'],
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                height: 1.3,
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: AppSizes.xl),

                // Conditional Goal Weight input field
                if (_shouldShowGoalWeight()) ...[
                  CustomTextField(
                    label: AppStrings.goalWeight,
                    hint: 'kg',
                    icon: Icons.track_changes_rounded,
                    controller: _goalWeightController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return AppStrings.requiredField;
                      }
                      if (double.tryParse(value) == null) {
                        return AppStrings.invalidNumber;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: AppSizes.xl),
                ],

                // Submit/Finish Button
                GradientButton(
                  text: AppStrings.finish,
                  isLoading: isLoading,
                  onPressed: _handleRegister,
                ),
                const SizedBox(height: AppSizes.xl),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
