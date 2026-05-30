/// FitTrack : Onboarding page data model
///
/// Pure data class representing a single onboarding screen.
/// Provides a static factory for the 4 default onboarding pages.
library;
import 'package:flutter/material.dart';

import '../core/constants/app_colors.dart';
import '../core/constants/app_strings.dart';

class OnboardingPage {
  final String title;
  final String description;
  final IconData iconData;
  final List<Color> gradientColors;

  const OnboardingPage({
    required this.title,
    required this.description,
    required this.iconData,
    required this.gradientColors,
  });

  /// The default 4-page onboarding sequence matching the Figma design.
  static List<OnboardingPage> get defaultPages => const [
        OnboardingPage(
          title: AppStrings.onboardingTitle1,
          description: AppStrings.onboardingDesc1,
          iconData: Icons.directions_run_rounded,
          gradientColors: [AppColors.gradientPink, AppColors.gradientPurple],
        ),
        OnboardingPage(
          title: AppStrings.onboardingTitle2,
          description: AppStrings.onboardingDesc2,
          iconData: Icons.restaurant_rounded,
          gradientColors: [AppColors.gradientBlue, AppColors.gradientPurple],
        ),
        OnboardingPage(
          title: AppStrings.onboardingTitle3,
          description: AppStrings.onboardingDesc3,
          iconData: Icons.nightlight_round,
          gradientColors: [AppColors.gradientPink, AppColors.gradientMagenta],
        ),
        OnboardingPage(
          title: AppStrings.onboardingTitle4,
          description: AppStrings.onboardingDesc4,
          iconData: Icons.track_changes_rounded,
          gradientColors: [AppColors.gradientPink, AppColors.gradientPurple],
        ),
      ];

  OnboardingPage copyWith({
    String? title,
    String? description,
    IconData? iconData,
    List<Color>? gradientColors,
  }) {
    return OnboardingPage(
      title: title ?? this.title,
      description: description ?? this.description,
      iconData: iconData ?? this.iconData,
      gradientColors: gradientColors ?? this.gradientColors,
    );
  }
}
