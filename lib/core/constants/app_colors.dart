import 'package:flutter/material.dart';

/// Minimalistic color palette for AI Token Observability.
/// Clean, professional, no flashiness.
class AppColors {
  AppColors._();

  // ── Primary ────────────────────────────────────────────────────
  static const Color primary = Color(0xFF2563EB);
  static const Color onPrimary = Color(0xFFFFFFFF);

  // ── Surfaces ───────────────────────────────────────────────────
  static const Color surfaceDark = Color(0xFF000000);
  static const Color surfaceDarkElevated = Color(0xFF0A0A0A);
  static const Color surfaceLight = Color(0xFFF9FAFB);
  static const Color surfaceLightElevated = Color(0xFFFFFFFF);

  // ── Usage Levels (domain-critical) ─────────────────────────────
  static const Color usageGreen = Color(0xFF059669);
  static const Color usageYellow = Color(0xFFD97706);
  static const Color usageRed = Color(0xFFDC2626);
  static const Color usageDarkRed = Color(0xFF991B1B);

  // ── Semantic ───────────────────────────────────────────────────
  static const Color success = Color(0xFF059669);
  static const Color warning = Color(0xFFD97706);
  static const Color error = Color(0xFFDC2626);
  static const Color info = Color(0xFF0284C7);

  // ── Borders / Dividers ─────────────────────────────────────────
  static const Color borderDark = Color(0xFF374151);
  static const Color borderLight = Color(0xFFE5E7EB);

  // ── On-Surface ─────────────────────────────────────────────────
  static const Color onSurfaceDark = Color(0xFFF9FAFB);
  static const Color onSurfaceLight = Color(0xFF111827);
  static const Color onSurfaceVariantDark = Color(0xFF9CA3AF);
  static const Color onSurfaceVariantLight = Color(0xFF6B7280);

  // ── Charts ─────────────────────────────────────────────────────
  static const List<Color> chartGradient = [primary, Color(0xFF7C3AED)];
}
