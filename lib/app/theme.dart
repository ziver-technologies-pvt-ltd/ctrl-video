import 'package:flutter/material.dart';

/// Defines the neutral Material Design 3 color palettes and themes for ctrl+video.
class AppTheme {
  AppTheme._();

  // Neutral Light Theme
  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: const ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xFF1E1E1E),
      onPrimary: Color(0xFFFFFFFF),
      primaryContainer: Color(0xFFE8E8EC),
      onPrimaryContainer: Color(0xFF1C1B1F),
      secondary: Color(0xFF3B3D42),
      onSecondary: Color(0xFFFFFFFF),
      secondaryContainer: Color(0xFFE4E4E8),
      onSecondaryContainer: Color(0xFF191A1E),
      tertiary: Color(0xFF4C4D52),
      onTertiary: Color(0xFFFFFFFF),
      tertiaryContainer: Color(0xFFECECEF),
      onTertiaryContainer: Color(0xFF222327),
      error: Color(0xFFBA1A1A),
      onError: Color(0xFFFFFFFF),
      errorContainer: Color(0xFFFFDAD6),
      onErrorContainer: Color(0xFF410002),
      surface: Color(0xFFF9F9FB),
      onSurface: Color(0xFF191C1E),
      onSurfaceVariant: Color(0xFF45474C),
      outline: Color(0xFF75777D),
      outlineVariant: Color(0xFFC5C6CD),
      surfaceContainerLowest: Color(0xFFFFFFFF),
      surfaceContainerLow: Color(0xFFF5F5F8),
      surfaceContainer: Color(0xFFF0F0F4),
      surfaceContainerHigh: Color(0xFFEAEAEF),
      surfaceContainerHighest: Color(0xFFE2E2E8),
    ),
    scaffoldBackgroundColor: const Color(0xFFF9F9FB),
    cardTheme: CardThemeData(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Color(0xFFC5C6CD), width: 1),
      ),
      color: Colors.white,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFFFFFFFF),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFC5C6CD)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFC5C6CD)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF1E1E1E), width: 1.5),
      ),
    ),
    navigationRailTheme: const NavigationRailThemeData(
      backgroundColor: Color(0xFFF0F0F4),
      indicatorColor: Color(0xFF1E1E1E),
      selectedIconTheme: IconThemeData(color: Colors.white),
      unselectedIconTheme: IconThemeData(color: Color(0xFF45474C)),
      selectedLabelTextStyle: TextStyle(
        color: Color(0xFF1E1E1E),
        fontWeight: FontWeight.w600,
        fontSize: 12,
      ),
      unselectedLabelTextStyle: TextStyle(
        color: Color(0xFF45474C),
        fontWeight: FontWeight.normal,
        fontSize: 12,
      ),
    ),
  );

  // Neutral Dark Theme
  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: const ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xFFE2E2E6),
      onPrimary: Color(0xFF1A1C1E),
      primaryContainer: Color(0xFF2D2F33),
      onPrimaryContainer: Color(0xFFE2E2E6),
      secondary: Color(0xFFC5C6CD),
      onSecondary: Color(0xFF2E3035),
      secondaryContainer: Color(0xFF383A40),
      onSecondaryContainer: Color(0xFFE2E2E6),
      tertiary: Color(0xFFB0B2B8),
      onTertiary: Color(0xFF282A2E),
      tertiaryContainer: Color(0xFF3E4046),
      onTertiaryContainer: Color(0xFFE2E2E6),
      error: Color(0xFFFFB4AB),
      onError: Color(0xFF690005),
      errorContainer: Color(0xFF93000A),
      onErrorContainer: Color(0xFFFFDAD6),
      surface: Color(0xFF131316),
      onSurface: Color(0xFFE2E2E6),
      onSurfaceVariant: Color(0xFFC5C6CD),
      outline: Color(0xFF8F9097),
      outlineVariant: Color(0xFF44474E),
      surfaceContainerLowest: Color(0xFF0E0E11),
      surfaceContainerLow: Color(0xFF17171B),
      surfaceContainer: Color(0xFF1E1F24),
      surfaceContainerHigh: Color(0xFF282A2F),
      surfaceContainerHighest: Color(0xFF33353B),
    ),
    scaffoldBackgroundColor: const Color(0xFF131316),
    cardTheme: CardThemeData(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Color(0xFF44474E), width: 1),
      ),
      color: const Color(0xFF1E1F24),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFF1E1F24),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF44474E)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF44474E)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE2E2E6), width: 1.5),
      ),
    ),
    navigationRailTheme: const NavigationRailThemeData(
      backgroundColor: Color(0xFF17171B),
      indicatorColor: Color(0xFFE2E2E6),
      selectedIconTheme: IconThemeData(color: Color(0xFF1A1C1E)),
      unselectedIconTheme: IconThemeData(color: Color(0xFFC5C6CD)),
      selectedLabelTextStyle: TextStyle(
        color: Color(0xFFE2E2E6),
        fontWeight: FontWeight.w600,
        fontSize: 12,
      ),
      unselectedLabelTextStyle: TextStyle(
        color: Color(0xFF8F9097),
        fontWeight: FontWeight.normal,
        fontSize: 12,
      ),
    ),
  );
}
