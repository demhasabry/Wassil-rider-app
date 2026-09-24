import 'package:flutter/material.dart';

/// Wassil design tokens — colors.
///
/// Every token from the design handoff exists in both apps even though a
/// given app's ThemeData only seeds its ColorScheme from one of
/// `primary`/`accent` — the rider app still needs `primary` for the
/// drop-off-square marker on its route strip, and the customer app still
/// needs `accent` for bid prices, so neither is app-specific.
class AppColors {
  AppColors._();

  // Customer brand
  static const Color primary = Color(0xFF2551CA);
  static const Color primaryDark = Color(0xFF1B3C97);
  static const Color primaryTint = Color(0xFFEEF2FD);
  static const Color primaryTintAlt = Color(0xFFF1F4FB);
  static const Color primaryFocusBg = Color(0xFFF7F9FE);
  static const Color primaryBorder = Color(0xFFC9CFEA);

  // Rider brand
  static const Color accent = Color(0xFFC9603A);
  static const Color accentTint = Color(0xFFFBF6F1);
  static const Color accentTintAlt = Color(0xFFFBF1EC);
  static const Color accentBorder = Color(0xFFF0E2D6);
  static const Color accentInk = Color(0xFF9A8577);
  static const Color accentOnDark = Color(0xFFE4B79E);

  // Ink / dark surfaces
  static const Color ink = Color(0xFF101520);
  static const Color inkAlt = Color(0xFF0B1220);
  static const Color inkPanel = Color(0xFF121B2C);

  // Text
  static const Color bodyText = Color(0xFF5A6272);
  static const Color muted = Color(0xFF6B7280);
  static const Color mutedLight = Color(0xFF9AA1AE);
  static const Color mutedOnDark = Color(0xFF8B95A8);
  static const Color placeholder = Color(0xFFA9AEB8);

  // Borders / dividers
  static const Color divider = Color(0xFFF3F1EC);
  static const Color border = Color(0xFFE3E0D8);
  static const Color borderAlt = Color(0xFFEDEAE3);
  static const Color borderDashed = Color(0xFFDCD6CA);

  // Surfaces
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceAlt = Color(0xFFFAF8F4);
  static const Color background = Color(0xFFF7F5F1);

  // Semantic
  static const Color success = Color(0xFF1C8F63);
  static const Color successText = Color(0xFF1C7A56);
  static const Color successTint = Color(0xFFEAF6F0);
  static const Color successTintAlt = Color(0xFFF6FBF8);
  static const Color successBorder = Color(0xFFCFE5DA);
  static const Color successOnDark = Color(0xFF4ADE9B);
  static const Color danger = Color(0xFFB4483C);
  static const Color dangerTint = Color(0xFFFBEEEC);
  static const Color dangerTintAlt = Color(0xFFFDF3F2);
  static const Color dangerBorder = Color(0xFFF0D9D5);

  // Ratings — the empty-star glyph color on both apps' rating screens.
  static const Color starInactive = Color(0xFFDDD8D0);
  // The rider home header's "★ 4.9 · 312" mono text, over the ink background.
  static const Color ratingOnDark = Color(0xFFC9915A);
}
