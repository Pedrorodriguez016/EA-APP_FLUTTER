import 'package:flutter/material.dart';

// =========================================================
//  VARIABLES BASE (MAPPED FROM CSS)
// =========================================================

// --- LIGHT MODE COLORS ---
// --purple-700 (Primary Brand)
const Color _lightPrimaryColor = Color(0xFF7C3AED);
// --accent-blue
const Color _lightSecondaryColor = Color(0xFF3B82F6);
// --bg-gradient-start / end (We use start as fallback)
const Color _lightBackgroundColor = Color(0xFFF8FAFC);
// --surface-card (#ffffff)
const Color _lightSurfaceCard = Color(0xFFFFFFFF);
// --surface-elev (#f1f5f9) - Inputs
const Color _lightSurfaceElev = Color(0xFFF1F5F9);
// --text-primary
const Color _lightOnBackground = Color(0xFF0F172A);
// --text-secondary
const Color _lightSecondaryText = Color(0xFF64748B);
// --border
const Color _lightBorderColor = Color(0xFFE2E8F0);

// --- DARK MODE COLORS ---
// --purple-500/600 (Lighter for dark mode contrast)
const Color _darkPrimaryColor = Color(0xFFD8B4FE);
// --accent-blue-light
const Color _darkSecondaryColor = Color(0xFF60A5FA);
// --bg-gradient-start (Deep Space)
const Color _darkBackgroundColor = Color(0xFF0F172A);
// --surface-card (rgba(15, 23, 42, 0.6)) -> Solid approx or with opacity
const Color _darkSurfaceCard = Color(0xFF1E293B);
// --surface-elev (Input background in dark mode)
const Color _darkSurfaceElev = Color(0xFF1E293B);
// --text-primary
const Color _darkOnBackground = Color(0xFFF8FAFC);
// --text-secondary
const Color _darkSecondaryText = Color(0xFF94A3B8);
// --border (Purple glow trace: rgba(124, 58, 237, 0.2))
const Color _darkBorderColor = Color(0x337C3AED);

// =========================================================
//  HELPER FOR GRADIENTS (Since Theme doesn't hold gradients)
// =========================================================
class AppGradients {
  static const LinearGradient primaryBtn = LinearGradient(
    colors: [_lightPrimaryColor, _lightSecondaryColor, Color(0xFF0EA5E9)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient lightBg = LinearGradient(
    colors: [Colors.white, _lightBackgroundColor],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient darkSpaceBg = LinearGradient(
    colors: [_darkBackgroundColor, Color(0xFF1E1B4B)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

// =========================================================
//  THEME DEFINITION
// =========================================================
class AppTheme {
  AppTheme._();

  // === TEMA CLARO (Clean & Professional) ===
  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,

    // Defines the core colors
    colorScheme: const ColorScheme.light(
      primary: _lightPrimaryColor,
      onPrimary: Colors.white,
      secondary: _lightSecondaryColor,
      background: _lightBackgroundColor,
      onBackground: _lightOnBackground,
      surface: _lightSurfaceCard,
      onSurface: _lightOnBackground,
      outline: _lightBorderColor,
      error: Color(0xFFEF4444),
    ),

    scaffoldBackgroundColor: _lightBackgroundColor,

    // App Bar (Glass effect needs separate Widget logic, but this sets base)
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent, // Allow background gradient to show
      foregroundColor: _lightOnBackground,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w900, // CSS: font-weight: 900
        color: _lightOnBackground,
        letterSpacing: -0.5,
      ),
      iconTheme: IconThemeData(color: _lightOnBackground),
    ),

    // Card (White, Clean, Bordered)
    cardTheme: CardThemeData(
      color: _lightSurfaceCard,
      elevation: 2, // --shadow-sm / md
      shadowColor: const Color.fromRGBO(0, 0, 0, 0.05),
      margin: const EdgeInsets.all(12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20), // CSS: 20px
        side: const BorderSide(color: _lightBorderColor, width: 1),
      ),
    ),

    // Inputs (Matches CSS Input styles)
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: _lightSurfaceElev,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _lightBorderColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _lightBorderColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _lightPrimaryColor, width: 2),
      ),
      hintStyle: const TextStyle(color: _lightSecondaryText),
    ),

    // Typography
    textTheme: const TextTheme(
      titleLarge: TextStyle(
        color: _lightOnBackground,
        fontWeight: FontWeight.w900,
      ),
      bodyLarge: TextStyle(color: _lightOnBackground), // Primary text
      bodyMedium: TextStyle(color: _lightOnBackground),
      bodySmall: TextStyle(color: _lightSecondaryText), // Secondary text
    ),

    iconTheme: const IconThemeData(color: _lightOnBackground),

    // Buttons (Base style - for Gradient use Container+Decoration)
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: _lightPrimaryColor,
        foregroundColor: Colors.white,
        elevation: 4,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: const TextStyle(fontWeight: FontWeight.w700),
      ),
    ),
  );

  // === TEMA OSCURO (Neon / Deep Space) ===
  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,

    colorScheme: const ColorScheme.dark(
      primary: _darkPrimaryColor,
      onPrimary: Colors.black, // Contrast on light purple
      secondary: _darkSecondaryColor,
      background: _darkBackgroundColor,
      onBackground: _darkOnBackground,
      surface: _darkSurfaceCard,
      onSurface: _darkOnBackground,
      outline: _darkBorderColor,
      error: Color(0xFFEF4444),
    ),

    // Fallback solid color (Use AppGradients.darkSpaceBg in scaffold body for full effect)
    scaffoldBackgroundColor: _darkBackgroundColor,

    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      foregroundColor: _darkOnBackground,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w900,
        color: _darkOnBackground,
        letterSpacing: -0.5,
      ),
      iconTheme: IconThemeData(color: _darkOnBackground),
    ),

    // Card (Glassy Dark)
    cardTheme: CardThemeData(
      color: _darkSurfaceCard.withOpacity(0.6), // Simulating glass transparency
      elevation:
          0, // CSS uses shadows differently, but flutter needs 0 for glass
      margin: const EdgeInsets.all(12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: _darkBorderColor), // Purple glow border
      ),
    ),

    // Inputs Dark Mode
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: _darkSurfaceElev, // Elevated surface
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _darkBorderColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _darkBorderColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _darkPrimaryColor, width: 2),
      ),
      hintStyle: const TextStyle(color: _darkSecondaryText),
    ),

    textTheme: const TextTheme(
      titleLarge: TextStyle(
        color: _darkOnBackground,
        fontWeight: FontWeight.w900,
      ),
      bodyLarge: TextStyle(color: _darkOnBackground),
      bodyMedium: TextStyle(color: _darkOnBackground),
      bodySmall: TextStyle(color: _darkSecondaryText),
    ),

    iconTheme: const IconThemeData(color: _darkOnBackground),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: _darkPrimaryColor,
        foregroundColor: Colors.black,
        elevation: 8,
        shadowColor: _darkPrimaryColor.withOpacity(0.5), // Glow effect
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: const TextStyle(fontWeight: FontWeight.w700),
      ),
    ),
  );
}
