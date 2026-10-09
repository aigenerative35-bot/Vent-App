import 'package:flutter/material.dart';

/// Zoho-style palette: light background, white cards, blue accent, soft borders.
class ZColors {
  static const primary = Color(0xFF2C6BE4);
  static const bg = Color(0xFFF4F6FA);
  static const surface = Color(0xFFFFFFFF);
  static const border = Color(0xFFE3E8EF);
  static const textPrimary = Color(0xFF16233A);
  static const textSecondary = Color(0xFF6B7A90);
  static const success = Color(0xFF12B76A);
  static const danger = Color(0xFFE5484D);
  static const chipBg = Color(0xFFEAF1FE);
}

ThemeData zohoTheme() {
  final scheme = ColorScheme.fromSeed(
    seedColor: ZColors.primary,
    brightness: Brightness.light,
  ).copyWith(
    primary: ZColors.primary,
    surface: ZColors.surface,
    onSurface: ZColors.textPrimary,
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: ZColors.bg,
    appBarTheme: const AppBarTheme(
      backgroundColor: ZColors.surface,
      foregroundColor: ZColors.textPrimary,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      surfaceTintColor: Colors.transparent,
      titleTextStyle: TextStyle(
        color: ZColors.textPrimary,
        fontSize: 20,
        fontWeight: FontWeight.w700,
      ),
    ),
    dividerTheme: const DividerThemeData(
      color: ZColors.border,
      thickness: 1,
      space: 1,
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: ZColors.surface,
      selectedItemColor: ZColors.primary,
      unselectedItemColor: ZColors.textSecondary,
      type: BottomNavigationBarType.fixed,
      showUnselectedLabels: true,
      elevation: 8,
      selectedLabelStyle: TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
      unselectedLabelStyle: TextStyle(fontSize: 11),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: ZColors.surface,
      hintStyle: const TextStyle(color: ZColors.textSecondary),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: ZColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: ZColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: ZColors.primary, width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: ZColors.primary,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
      ),
    ),
  );
}
