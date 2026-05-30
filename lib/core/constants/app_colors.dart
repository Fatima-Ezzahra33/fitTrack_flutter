/// FitTrack : Application color palette
///
/// Inspired by the DIDPOOLFit Figma kit. All colors are defined as
/// static constants to avoid magic values throughout the codebase.
/// Supports both light and dark themes.
library;
import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // ── Primary brand colors ──────────────────────────────────────────
  static const Color primary = Color(0xFF9B7BFF);
  static const Color primaryLight = Color(0xFFF3E8FF);
  static const Color primaryDark = Color(0xFF7C5CE0);
  static const Color primarySurface = Color(0xFFEDE5FF);

  // ── Accent / success / status ─────────────────────────────────────
  static const Color success = Color(0xFF4ADE80);
  static const Color successDark = Color(0xFF22C55E);
  static const Color error = Color(0xFFEF4444);
  static const Color errorLight = Color(0xFFFEE2E2);
  static const Color warning = Color(0xFFFBBF24);
  static const Color info = Color(0xFF3B82F6);

  // ── Background ────────────────────────────────────────────────────
  static const Color backgroundLight = Color(0xFFF8F9FE);
  static const Color backgroundDark = Color(0xFF111827);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceDark = Color(0xFF1F2937);
  static const Color cardDark = Color(0xFF374151);

  // ── Text ──────────────────────────────────────────────────────────
  static const Color textPrimary = Color(0xFF1F2937);
  static const Color textSecondary = Color(0xFF9CA3AF);
  static const Color textTertiary = Color(0xFFD1D5DB);
  static const Color textOnPrimary = Color(0xFFFFFFFF);
  static const Color textDarkPrimary = Color(0xFFF9FAFB);
  static const Color textDarkSecondary = Color(0xFF9CA3AF);

  // ── Borders / Dividers ────────────────────────────────────────────
  static const Color borderLight = Color(0xFFE5E7EB);
  static const Color borderDark = Color(0xFF374151);
  static const Color dividerLight = Color(0xFFF3F4F6);
  static const Color dividerDark = Color(0xFF4B5563);

  // ── Input field ───────────────────────────────────────────────────
  static const Color inputFillLight = Color(0xFFF3F4F6);
  static const Color inputFillDark = Color(0xFF374151);

  // ── Gradient colors ───────────────────────────────────────────────
  static const Color gradientPink = Color(0xFFEC4899);
  static const Color gradientPurple = Color(0xFF9B7BFF);
  static const Color gradientBlue = Color(0xFF6366F1);
  static const Color gradientMagenta = Color(0xFFC084FC);

  // ── Predefined gradients ──────────────────────────────────────────
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, primaryDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient splashGradient = LinearGradient(
    colors: [gradientPink, gradientPurple],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient onboardingGradient1 = LinearGradient(
    colors: [gradientPink, gradientPurple],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient onboardingGradient2 = LinearGradient(
    colors: [gradientBlue, gradientPurple],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient onboardingGradient3 = LinearGradient(
    colors: [gradientPink, gradientMagenta],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ── Bottom nav ────────────────────────────────────────────────────
  static const Color navBarLight = Color(0xFFFFFFFF);
  static const Color navBarDark = Color(0xFF1F2937);
  static const Color navIconInactive = Color(0xFF9CA3AF);
}
