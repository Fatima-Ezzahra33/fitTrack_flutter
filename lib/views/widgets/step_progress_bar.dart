/// FitTrack — Step progress bar widget
///
/// A horizontal 3-step progress indicator for the registration wizard.
/// Shows numbered circles connected by lines. Completed steps are
/// filled with the primary color, current step is outlined, and
/// future steps are greyed out.
library;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';

class StepProgressBar extends StatelessWidget {
  final int currentStep;
  final List<String> stepLabels;

  const StepProgressBar({
    super.key,
    required this.currentStep,
    required this.stepLabels,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(stepLabels.length * 2 - 1, (index) {
        // Even indices are step circles, odd indices are connecting lines
        if (index.isEven) {
          final int stepIndex = index ~/ 2;
          return _buildStepCircle(context, stepIndex);
        } else {
          final int beforeStep = index ~/ 2;
          return _buildConnectingLine(beforeStep);
        }
      }),
    );
  }

  Widget _buildStepCircle(BuildContext context, int stepIndex) {
    final bool isCompleted = stepIndex < currentStep;
    final bool isCurrent = stepIndex == currentStep;
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: AppSizes.stepIndicatorSize,
          height: AppSizes.stepIndicatorSize,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isCompleted
                ? AppColors.primary
                : isCurrent
                    ? Colors.transparent
                    : Colors.transparent,
            border: Border.all(
              color: isCompleted || isCurrent
                  ? AppColors.primary
                  : isDark
                      ? AppColors.borderDark
                      : AppColors.borderLight,
              width: 2,
            ),
          ),
          child: Center(
            child: isCompleted
                ? const Icon(
                    Icons.check_rounded,
                    color: AppColors.textOnPrimary,
                    size: 18,
                  )
                : Text(
                    '${stepIndex + 1}',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isCurrent
                          ? AppColors.primary
                          : isDark
                              ? AppColors.textDarkSecondary
                              : AppColors.textSecondary,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: AppSizes.xs),
        Text(
          stepLabels[stepIndex],
          style: GoogleFonts.inter(
            fontSize: 10,
            fontWeight: isCurrent ? FontWeight.w600 : FontWeight.w400,
            color: isCompleted || isCurrent
                ? AppColors.primary
                : isDark
                    ? AppColors.textDarkSecondary
                    : AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildConnectingLine(int beforeStep) {
    final bool isCompleted = beforeStep < currentStep;

    return Expanded(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 18),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          height: AppSizes.stepLineHeight,
          decoration: BoxDecoration(
            color: isCompleted
                ? AppColors.primary
                : AppColors.primary.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ),
    );
  }
}
