/// FitTrack : Application sizing constants
///
/// Centralized spacing, border radius, icon size, and component
/// dimension values. Use these instead of hardcoded pixel values
/// to ensure visual consistency across the entire app.
library;

class AppSizes {
  AppSizes._();

  // ── Spacing scale ─────────────────────────────────────────────────
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 20.0;
  static const double xxl = 24.0;
  static const double xxxl = 32.0;
  static const double huge = 48.0;
  static const double massive = 64.0;

  // ── Border radius ─────────────────────────────────────────────────
  static const double radiusSm = 8.0;
  static const double radiusMd = 12.0;
  static const double radiusLg = 16.0;
  static const double radiusXl = 24.0;
  static const double radiusXxl = 28.0;
  static const double radiusFull = 999.0;

  // ── Icon sizes ────────────────────────────────────────────────────
  static const double iconSm = 16.0;
  static const double iconMd = 20.0;
  static const double iconLg = 24.0;
  static const double iconXl = 32.0;
  static const double iconXxl = 48.0;
  static const double iconHuge = 64.0;

  // ── Button dimensions ─────────────────────────────────────────────
  static const double buttonHeight = 56.0;
  static const double buttonHeightSm = 44.0;
  static const double buttonRadius = 28.0;
  static const double buttonIconSize = 24.0;

  // ── Input field dimensions ────────────────────────────────────────
  static const double inputHeight = 56.0;
  static const double inputRadius = 16.0;

  // ── Card dimensions ───────────────────────────────────────────────
  static const double cardRadius = 16.0;
  static const double cardElevation = 2.0;
  static const double cardPadding = 16.0;

  // ── Bottom nav ────────────────────────────────────────────────────
  static const double bottomNavHeight = 72.0;
  static const double bottomNavIconSize = 24.0;

  // ── Avatar ────────────────────────────────────────────────────────
  static const double avatarSm = 32.0;
  static const double avatarMd = 48.0;
  static const double avatarLg = 64.0;
  static const double avatarXl = 96.0;

  // ── Onboarding ────────────────────────────────────────────────────
  static const double onboardingBlobHeight = 0.55; // fraction of screen
  static const double nextButtonSize = 60.0;
  static const double nextButtonBorderWidth = 3.0;
  static const double dotSize = 8.0;
  static const double dotActiveWidth = 24.0;

  // ── Step progress ─────────────────────────────────────────────────
  static const double stepIndicatorSize = 36.0;
  static const double stepLineHeight = 3.0;
}
