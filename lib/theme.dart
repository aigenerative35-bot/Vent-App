import 'package:flutter/material.dart';

/// Brand accents (X-style).
class AppColors {
  static const blue = Color(0xFF1D9BF0);
  static const like = Color(0xFFF91880);
  static const repost = Color(0xFF00BA7C);
}

/// Two palettes so the app follows the system light / dark setting.
class Palette {
  final Color bg;
  final Color text;
  final Color secondary;
  final Color border;
  final Color chipBg;

  const Palette({
    required this.bg,
    required this.text,
    required this.secondary,
    required this.border,
    required this.chipBg,
  });

  static const light = Palette(
    bg: Color(0xFFFFFFFF),
    text: Color(0xFF0F1419),
    secondary: Color(0xFF536471),
    border: Color(0xFFEFF3F4),
    chipBg: Color(0xFFF7F9F9),
  );

  static const dark = Palette(
    bg: Color(0xFF000000),
    text: Color(0xFFE7E9EA),
    secondary: Color(0xFF71767B),
    border: Color(0xFF2F3336),
    chipBg: Color(0xFF16181C),
  );

  static Palette of(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? dark : light;
}

ThemeData appTheme(Brightness brightness) {
  final p = brightness == Brightness.dark ? Palette.dark : Palette.light;

  return ThemeData(
    useMaterial3: true,
    brightness: brightness,
    scaffoldBackgroundColor: p.bg,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.blue,
      brightness: brightness,
    ).copyWith(
      primary: AppColors.blue,
      surface: p.bg,
      onSurface: p.text,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: p.bg,
      foregroundColor: p.text,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      surfaceTintColor: Colors.transparent,
      titleTextStyle: TextStyle(color: p.text, fontSize: 19, fontWeight: FontWeight.w800),
    ),
    dividerTheme: DividerThemeData(color: p.border, thickness: 1, space: 1),
    tabBarTheme: TabBarThemeData(
      labelColor: p.text,
      unselectedLabelColor: p.secondary,
      indicatorColor: AppColors.blue,
      dividerColor: p.border,
      labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
      unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: p.chipBg,
      hintStyle: TextStyle(color: p.secondary),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(24),
        borderSide: BorderSide(color: p.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(24),
        borderSide: BorderSide(color: p.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(24),
        borderSide: const BorderSide(color: AppColors.blue, width: 1.4),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.blue,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 13),
        textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14.5),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: p.text,
        side: BorderSide(color: p.border),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
      ),
    ),
  );
}
