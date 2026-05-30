/// FitTrack : Splash screen
///
/// Welcoming landing screen with subtle fade-in logo animation and
/// "Everybody Can Train" tag. Performs initial session/onboarding checks
/// and guides users to onboarding, login, or main shell.
library;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../controllers/auth_controller.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/constants/app_strings.dart';
import '../../services/preferences_service.dart';
import '../widgets/gradient_button.dart';
import 'onboarding_screen.dart';
import 'auth/login_screen.dart';
import 'main_shell.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  bool _isChecking = true;
  bool _showGetStarted = false;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeIn);

    _animController.forward();
    _initializeApp();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Future<void> _initializeApp() async {
    // 1. Wait for splash animation to show for at least 1.5 seconds
    await Future.delayed(const Duration(milliseconds: 1500));

    if (!mounted) return;

    final prefs = context.read<PreferencesService>();
    final auth = context.read<AuthController>();

    // 2. Check if first launch
    final bool isFirst = prefs.isFirstLaunch();
    if (isFirst) {
      setState(() {
        _isChecking = false;
        _showGetStarted = true;
      });
      return;
    }

    // 3. Check if user session exists
    final bool hasSession = await auth.checkSession();
    if (!mounted) return;

    if (hasSession) {
      _navigateTo(const MainShell());
    } else {
      _navigateTo(const LoginScreen());
    }
  }

  void _navigateTo(Widget screen) {
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, anim1, anim2) => screen,
        transitionsBuilder: (context, anim, secondaryAnim, child) {
          return FadeTransition(opacity: anim, child: child);
        },
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSizes.xl),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              // Logo and App Title with Fade transition
              FadeTransition(
                opacity: _fadeAnim,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Decorative abstract logo shape
                    SizedBox(
        width: 150,
        height: 150,
        child: Image.asset('assets/images/fit_track_logo.png', fit: BoxFit.contain),
      ),
                    const SizedBox(height: AppSizes.lg),
                    Text(
                      AppStrings.appTagline,
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        color: isDark ? AppColors.textDarkSecondary : AppColors.textSecondary,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              // Conditional bottom button or spinner
              SizedBox(
                height: 80,
                child: _isChecking
                    ? const Center(
                        child: CircularProgressIndicator(
                          strokeWidth: 3,
                          valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                        ),
                      )
                    : _showGetStarted
                        ? FadeTransition(
                            opacity: _fadeAnim,
                            child: Center(
                              child: GradientButton(
                                text: AppStrings.getStarted,
                                onPressed: () {
                                  _navigateTo(const OnboardingScreen());
                                },
                              ),
                            ),
                          )
                        : const SizedBox.shrink(),
              ),
              const SizedBox(height: AppSizes.xl),
            ],
          ),
        ),
      ),
    );
  }
}
