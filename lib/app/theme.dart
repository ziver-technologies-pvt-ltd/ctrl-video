import 'package:flutter/material.dart';

/// Semantic color tokens for ctrl+video v2:
/// - 5-level monochrome surface elevation (surface-0 to surface-4)
/// - Warm Amber signal accent for active trims, focus rings, and metrics
class AppColors {
  AppColors._();

  // Signal Accent Token (Warm Amber)
  static const Color accent = Color(0xFFF59E0B);
  static const Color accentLight = Color(0xFFFBBF24);
  static const Color accentDark = Color(0xFFD97706);

  // Light Mode Surfaces (Level 0 - Level 4)
  static const Color lightSurface0 = Color(0xFFF6F6F9); // Base window background
  static const Color lightSurface1 = Color(0xFFFFFFFF); // Cards / sidebar rail
  static const Color lightSurface2 = Color(0xFFECECEF); // Secondary panels / inputs
  static const Color lightSurface3 = Color(0xFFE2E2E8); // Hovered / raised containers
  static const Color lightSurface4 = Color(0xFFD5D5DC); // Modals / popups

  // Dark Mode Surfaces (Level 0 - Level 4)
  static const Color darkSurface0 = Color(0xFF0F0F12); // Deep window background
  static const Color darkSurface1 = Color(0xFF17171C); // Cards / sidebar rail
  static const Color darkSurface2 = Color(0xFF22222A); // Secondary panels / inputs
  static const Color darkSurface3 = Color(0xFF2E2E38); // Hovered / raised containers
  static const Color darkSurface4 = Color(0xFF3B3B48); // Modals / popups

  // Text Hierarchy
  static const Color lightInkPrimary = Color(0xFF141416);
  static const Color lightInkSecondary = Color(0xFF5A5B63);
  static const Color lightInkDisabled = Color(0xFF8E8F99);

  static const Color darkInkPrimary = Color(0xFFEBEBF0);
  static const Color darkInkSecondary = Color(0xFF9EA0AB);
  static const Color darkInkDisabled = Color(0xFF656670);

  // Status Colors
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
}

/// Defines the neutral + warm amber Material Design 3 themes for ctrl+video.
class AppTheme {
  AppTheme._();

  // Monospace font styling for timecodes, bitrates, speed, and ETA
  static const TextStyle monoStyle = TextStyle(
    fontFamily: 'monospace',
    fontFeatures: [FontFeature.tabularFigures()],
  );

  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: const ColorScheme(
      brightness: Brightness.light,
      primary: AppColors.lightInkPrimary,
      onPrimary: Colors.white,
      primaryContainer: AppColors.lightSurface2,
      onPrimaryContainer: AppColors.lightInkPrimary,
      secondary: AppColors.accent,
      onSecondary: Colors.black,
      secondaryContainer: Color(0xFFFEF3C7),
      onSecondaryContainer: Color(0xFF78350F),
      tertiary: Color(0xFF3B3D42),
      onTertiary: Colors.white,
      error: AppColors.error,
      onError: Colors.white,
      surface: AppColors.lightSurface0,
      onSurface: AppColors.lightInkPrimary,
      onSurfaceVariant: AppColors.lightInkSecondary,
      outline: Color(0xFFC5C6CD),
      outlineVariant: Color(0xFFE2E2E8),
      surfaceContainerLowest: AppColors.lightSurface1,
      surfaceContainerLow: AppColors.lightSurface0,
      surfaceContainer: AppColors.lightSurface1,
      surfaceContainerHigh: AppColors.lightSurface2,
      surfaceContainerHighest: AppColors.lightSurface3,
    ),
    scaffoldBackgroundColor: AppColors.lightSurface0,
    cardTheme: CardThemeData(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: const BorderSide(color: Color(0xFFE2E2E8), width: 1),
      ),
      color: AppColors.lightSurface1,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.lightSurface1,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFC5C6CD)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFC5C6CD)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.accent, width: 1.8),
      ),
    ),
    navigationRailTheme: const NavigationRailThemeData(
      backgroundColor: AppColors.lightSurface1,
      indicatorColor: AppColors.lightInkPrimary,
      selectedIconTheme: IconThemeData(color: Colors.white),
      unselectedIconTheme: IconThemeData(color: AppColors.lightInkSecondary),
      selectedLabelTextStyle: TextStyle(
        color: AppColors.lightInkPrimary,
        fontWeight: FontWeight.w600,
        fontSize: 12,
      ),
      unselectedLabelTextStyle: TextStyle(
        color: AppColors.lightInkSecondary,
        fontWeight: FontWeight.normal,
        fontSize: 12,
      ),
    ),
  );

  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: const ColorScheme(
      brightness: Brightness.dark,
      primary: AppColors.darkInkPrimary,
      onPrimary: AppColors.darkSurface0,
      primaryContainer: AppColors.darkSurface2,
      onPrimaryContainer: AppColors.darkInkPrimary,
      secondary: AppColors.accent,
      onSecondary: Colors.black,
      secondaryContainer: Color(0xFF451A03),
      onSecondaryContainer: Color(0xFFFDE68A),
      tertiary: Color(0xFFB0B2B8),
      onTertiary: Color(0xFF1E1F24),
      error: AppColors.error,
      onError: Colors.white,
      surface: AppColors.darkSurface0,
      onSurface: AppColors.darkInkPrimary,
      onSurfaceVariant: AppColors.darkInkSecondary,
      outline: Color(0xFF4A4B56),
      outlineVariant: Color(0xFF2E2E38),
      surfaceContainerLowest: AppColors.darkSurface0,
      surfaceContainerLow: AppColors.darkSurface1,
      surfaceContainer: AppColors.darkSurface1,
      surfaceContainerHigh: AppColors.darkSurface2,
      surfaceContainerHighest: AppColors.darkSurface3,
    ),
    scaffoldBackgroundColor: AppColors.darkSurface0,
    cardTheme: CardThemeData(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: const BorderSide(color: Color(0xFF2E2E38), width: 1),
      ),
      color: AppColors.darkSurface1,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.darkSurface1,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFF4A4B56)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFF4A4B56)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.accent, width: 1.8),
      ),
    ),
    navigationRailTheme: const NavigationRailThemeData(
      backgroundColor: AppColors.darkSurface1,
      indicatorColor: AppColors.darkInkPrimary,
      selectedIconTheme: IconThemeData(color: AppColors.darkSurface0),
      unselectedIconTheme: IconThemeData(color: AppColors.darkInkSecondary),
      selectedLabelTextStyle: TextStyle(
        color: AppColors.darkInkPrimary,
        fontWeight: FontWeight.w600,
        fontSize: 12,
      ),
      unselectedLabelTextStyle: TextStyle(
        color: AppColors.darkInkDisabled,
        fontWeight: FontWeight.normal,
        fontSize: 12,
      ),
    ),
  );
}
