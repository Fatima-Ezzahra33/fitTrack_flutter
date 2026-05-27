/// FitTrack — Onboarding Screen
///
/// Implements a 4-step premium onboarding experience featuring custom
/// organic gradient blobs (via GradientBlob), interactive icon elements,
/// page indicator dots, and a custom circular progress next button (NextPageButton).
library;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../controllers/onboarding_controller.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../widgets/gradient_blob.dart';
import '../widgets/next_page_button.dart';
import '../widgets/page_indicator.dart';
import 'auth/register_step1_screen.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Consumer<OnboardingController>(
      builder: (context, onboardingController, child) {
        final pages = onboardingController.pages;
        final currentPage = onboardingController.currentPage;
        final activePage = pages[currentPage];

        return Scaffold(
          backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
          body: Stack(
            children: [
              // 1. Sliding Top Gradient Blob & Floating Icon
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: SizedBox(
                  height: MediaQuery.of(context).size.height * 0.55,
                  child: Stack(
                    children: [
                      // Interactive Blob Background
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 500),
                        child: GradientBlob(
                          key: ValueKey<int>(currentPage),
                          gradientColors: activePage.gradientColors,
                        ),
                      ),
                      // Animated Center Icon
                      Center(
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 400),
                          transitionBuilder: (Widget child, Animation<double> animation) {
                            return ScaleTransition(
                              scale: animation,
                              child: FadeTransition(
                                opacity: animation,
                                child: child,
                              ),
                            );
                          },
                          child: Container(
                            key: ValueKey<int>(currentPage),
                            width: 130,
                            height: 130,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withValues(alpha: 0.18),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.3),
                                width: 2,
                              ),
                            ),
                            child: Icon(
                              activePage.iconData,
                              color: Colors.white,
                              size: 64,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // 2. Main PageView Content
              PageView.builder(
                controller: onboardingController.pageController,
                onPageChanged: onboardingController.onPageChanged,
                itemCount: pages.length,
                itemBuilder: (context, index) {
                  final page = pages[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppSizes.xl),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Spacer to push text below the blob
                        SizedBox(height: MediaQuery.of(context).size.height * 0.58),
                        Text(
                          page.title,
                          style: GoogleFonts.poppins(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            height: 1.25,
                            color: isDark ? AppColors.textDarkPrimary : AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: AppSizes.md),
                        Text(
                          page.description,
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            height: 1.5,
                            color: isDark ? AppColors.textDarkSecondary : AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),

              // 3. Bottom controls (Dots Indicator & Circular Next Button)
              Positioned(
                bottom: 40,
                left: AppSizes.xl,
                right: AppSizes.xl,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Dot Page Indicator
                    PageIndicator(
                      currentPage: currentPage,
                      pageCount: pages.length,
                    ),

                    // Next Page Button with progress outline
                    NextPageButton(
                      progress: onboardingController.progress,
                      onPressed: () async {
                        if (onboardingController.isLastPage) {
                          await onboardingController.completeOnboarding();
                          if (context.mounted) {
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                builder: (_) => const RegisterStep1Screen(),
                              ),
                            );
                          }
                        } else {
                          await onboardingController.nextPage();
                        }
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
