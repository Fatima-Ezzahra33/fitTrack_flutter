/// FitTrack — Registration Step 2 (Profile Details)
///
/// Collects phone number, date of birth (using date picker), gender (dropdown),
/// height (cm), and weight (kg). Features step indicator and validation,
/// with navigation back to step 1 or forward to step 3.
library;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../controllers/auth_controller.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_strings.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/gradient_button.dart';
import '../../widgets/step_progress_bar.dart';
import 'register_step3_screen.dart';

class RegisterStep2Screen extends StatefulWidget {
  const RegisterStep2Screen({super.key});

  @override
  State<RegisterStep2Screen> createState() => _RegisterStep2ScreenState();
}

class _RegisterStep2ScreenState extends State<RegisterStep2Screen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _dobController = TextEditingController();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();

  DateTime? _selectedDob;
  String? _selectedGender;

  // Used to show a validation error beneath the gender dropdown
  bool _genderTouched = false;

  final List<String> _genders = [
    AppStrings.male,
    AppStrings.female,
    AppStrings.other,
  ];

  @override
  void dispose() {
    _phoneController.dispose();
    _dobController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  Future<void> _selectDateOfBirth() async {
    final DateTime now = DateTime.now();
    final DateTime eighteenYearsAgo =
        DateTime(now.year - 18, now.month, now.day);
    final DateTime hundredYearsAgo = DateTime(now.year - 100);

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: eighteenYearsAgo,
      firstDate: hundredYearsAgo,
      lastDate: now,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedDob = picked;
        _dobController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  void _handleNextStep() {
    // Mark gender as touched so the error shows if still null
    setState(() {
      _genderTouched = true;
    });

    if (!_formKey.currentState!.validate()) return;

    // Manual gender validation (DropdownMenu has no built-in validator)
    if (_selectedGender == null) return;

    final authController = context.read<AuthController>();
    authController.saveStep2(
      phoneNumber:
          _phoneController.text.isNotEmpty ? _phoneController.text : null,
      dateOfBirth: _selectedDob,
      gender: _selectedGender,
      height: _heightController.text.isNotEmpty
          ? double.tryParse(_heightController.text)
          : null,
      weight: _weightController.text.isNotEmpty
          ? double.tryParse(_weightController.text)
          : null,
    );
    authController.setStep(2);

    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const RegisterStep3Screen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
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
                  color: isDark
                      ? AppColors.textDarkPrimary
                      : AppColors.textPrimary,
                  onPressed: () {
                    final authController = context.read<AuthController>();
                    authController.setStep(0);
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
                    color: isDark
                        ? AppColors.textDarkPrimary
                        : AppColors.textPrimary,
                  ),
                ),
                Text(
                  AppStrings.registerSubtitle,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: isDark
                        ? AppColors.textDarkSecondary
                        : AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSizes.xl),

                // Progress Indicator
                const StepProgressBar(
                  currentStep: 1,
                  stepLabels: [
                    AppStrings.step1Title,
                    AppStrings.step2Title,
                    AppStrings.step3Title,
                  ],
                ),
                const SizedBox(height: AppSizes.xxl),

                // Phone number
                CustomTextField(
                  label: AppStrings.phoneNumber,
                  hint: 'enter your phone number (optional)',
                  icon: Icons.phone_outlined,
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: AppSizes.md),

                // Date of Birth
                CustomTextField(
                  label: AppStrings.dateOfBirth,
                  hint: 'select date of birth',
                  icon: Icons.calendar_month_outlined,
                  controller: _dobController,
                  readOnly: true,
                  onTap: _selectDateOfBirth,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return AppStrings.requiredField;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppSizes.md),

                // ── Gender DropdownMenu (replaces DropdownButtonFormField) ──
                // DropdownMenu renders a floating overlay anchored to the field
                // instead of a full-width bottom sheet, which looks much cleaner.
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DropdownMenu<String>(
                      width: MediaQuery.of(context).size.width -
                          (AppSizes.xl * 2),
                      initialSelection: _selectedGender,
                      label: Text(
                        AppStrings.gender,
                        style: TextStyle(
                          color: isDark
                              ? AppColors.textDarkSecondary
                              : AppColors.textSecondary,
                        ),
                      ),
                      leadingIcon: Padding(
                        padding: const EdgeInsets.only(
                          left: AppSizes.lg,
                          right: AppSizes.md,
                        ),
                        child: Icon(
                          Icons.wc_rounded,
                          size: AppSizes.iconMd,
                          color: isDark
                              ? AppColors.textDarkSecondary
                              : AppColors.textSecondary,
                        ),
                      ),
                      menuStyle: MenuStyle(
                        backgroundColor: WidgetStateProperty.all(
                          isDark
                              ? AppColors.surfaceDark
                              : AppColors.surfaceLight,
                        ),
                        elevation: WidgetStateProperty.all(4),
                        shape: WidgetStateProperty.all(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      textStyle: Theme.of(context).textTheme.bodyLarge,
                      inputDecorationTheme:
                          Theme.of(context).inputDecorationTheme,
                      dropdownMenuEntries: _genders.map((String gender) {
                        return DropdownMenuEntry<String>(
                          value: gender,
                          label: gender,
                        );
                      }).toList(),
                      onSelected: (value) {
                        setState(() {
                          _selectedGender = value;
                          _genderTouched = true;
                        });
                      },
                    ),
                    // Show validation error manually (DropdownMenu has no validator)
                    if (_genderTouched && _selectedGender == null)
                      Padding(
                        padding: const EdgeInsets.only(
                          top: 6,
                          left: AppSizes.lg,
                        ),
                        child: Text(
                          AppStrings.requiredField,
                          style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(context).colorScheme.error,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: AppSizes.md),

                // Height and Weight Side by Side
                Row(
                  children: [
                    Expanded(
                      child: CustomTextField(
                        label: 'Height',
                        hint: 'cm',
                        icon: Icons.height_rounded,
                        controller: _heightController,
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
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
                    ),
                    const SizedBox(width: AppSizes.md),
                    Expanded(
                      child: CustomTextField(
                        label: 'Weight',
                        hint: 'kg',
                        icon: Icons.monitor_weight_outlined,
                        controller: _weightController,
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
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
                    ),
                  ],
                ),
                const SizedBox(height: AppSizes.xxl),

                // Next Step Button
                GradientButton(
                  text: AppStrings.next,
                  onPressed: _handleNextStep,
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