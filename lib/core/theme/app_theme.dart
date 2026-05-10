import 'package:flutter/material.dart';
import 'package:token_watch/core/constants/app_colors.dart';
import 'package:token_watch/core/constants/app_typography.dart';

class AppTheme {
  AppTheme._();

  // ── Dark Theme ─────────────────────────────────────────────────
  static final ColorScheme darkColorScheme = ColorScheme.dark(
    primary: AppColors.primary,
    onPrimary: AppColors.onPrimary,
    secondary: AppColors.info,
    onSecondary: AppColors.onPrimary,
    surface: AppColors.surfaceDark,
    surfaceContainerHighest: AppColors.surfaceDarkElevated,
    onSurface: AppColors.onSurfaceDark,
    onSurfaceVariant: AppColors.onSurfaceVariantDark,
    error: AppColors.error,
    onError: AppColors.onPrimary,
    outline: AppColors.borderDark,
    outlineVariant: AppColors.borderDark.withValues(alpha: 0.5),
  );

  static ThemeData get darkTheme => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: darkColorScheme,
        textTheme: AppTypography.textTheme,
        scaffoldBackgroundColor: darkColorScheme.surface,
        cardTheme: CardThemeData(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side:
                BorderSide(color: AppColors.borderDark.withValues(alpha: 0.4)),
          ),
          color: AppColors.surfaceDarkElevated,
        ),
        appBarTheme: const AppBarTheme(elevation: 0, centerTitle: true),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.surfaceDarkElevated,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: AppColors.borderDark),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: AppColors.borderDark),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: AppColors.primary, width: 2),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        ),
        dividerTheme: const DividerThemeData(
          color: AppColors.borderDark,
          thickness: 1,
          space: 1,
        ),
        chipTheme: ChipThemeData(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(14))),
        ),
      );

  // ── Light Theme ────────────────────────────────────────────────
  static final ColorScheme lightColorScheme = ColorScheme.light(
    primary: AppColors.primary,
    onPrimary: AppColors.onPrimary,
    secondary: AppColors.info,
    onSecondary: AppColors.onPrimary,
    surface: AppColors.surfaceLight,
    surfaceContainerHighest: AppColors.surfaceLightElevated,
    onSurface: AppColors.onSurfaceLight,
    onSurfaceVariant: AppColors.onSurfaceVariantLight,
    error: AppColors.error,
    onError: AppColors.onPrimary,
    outline: AppColors.borderLight,
    outlineVariant: AppColors.borderLight.withValues(alpha: 0.5),
  );

  static ThemeData get lightTheme => ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorScheme: lightColorScheme,
        textTheme: AppTypography.textTheme,
        scaffoldBackgroundColor: lightColorScheme.surface,
        cardTheme: CardThemeData(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: AppColors.borderLight),
          ),
          color: AppColors.surfaceLightElevated,
        ),
        appBarTheme: const AppBarTheme(elevation: 0, centerTitle: true),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.grey.shade50,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: AppColors.borderLight),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: AppColors.borderLight),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: AppColors.primary, width: 2),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        ),
        dividerTheme: const DividerThemeData(
          color: AppColors.borderLight,
          thickness: 1,
          space: 1,
        ),
        chipTheme: ChipThemeData(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(14))),
        ),
      );
}
