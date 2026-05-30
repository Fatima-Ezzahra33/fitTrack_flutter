/// FitTrack : Next page button widget
///
/// A circular button with a chevron icon and an animated circular
/// progress border, used in the onboarding flow. The progress ring
/// fills as the user advances through pages.
library;
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';

class NextPageButton extends StatelessWidget {
  final VoidCallback onPressed;
  final double progress;

  const NextPageButton({
    super.key,
    required this.onPressed,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: SizedBox(
        width: AppSizes.nextButtonSize,
        height: AppSizes.nextButtonSize,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Background circle (track)
            Container(
              width: AppSizes.nextButtonSize,
              height: AppSizes.nextButtonSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.borderLight,
                  width: AppSizes.nextButtonBorderWidth,
                ),
              ),
            ),

            // Animated progress arc
            SizedBox(
              width: AppSizes.nextButtonSize,
              height: AppSizes.nextButtonSize,
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: progress),
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeInOut,
                builder: (context, value, child) {
                  return CustomPaint(
                    painter: _ProgressArcPainter(
                      progress: value,
                      strokeWidth: AppSizes.nextButtonBorderWidth,
                      color: AppColors.primary,
                    ),
                  );
                },
              ),
            ),

            // Inner filled circle with icon
            Container(
              width: AppSizes.nextButtonSize - 14,
              height: AppSizes.nextButtonSize - 14,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: AppColors.primaryGradient,
                boxShadow: [
                  BoxShadow(
                    color: Color(0x409B7BFF),
                    blurRadius: 8,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.textOnPrimary,
                size: AppSizes.iconLg,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Custom painter that draws a circular progress arc.
class _ProgressArcPainter extends CustomPainter {
  final double progress;
  final double strokeWidth;
  final Color color;

  _ProgressArcPainter({
    required this.progress,
    required this.strokeWidth,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final Rect rect = Rect.fromCircle(
      center: Offset(size.width / 2, size.height / 2),
      radius: (size.width - strokeWidth) / 2,
    );

    // Start from the top (-90°) and sweep clockwise
    canvas.drawArc(
      rect,
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _ProgressArcPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
