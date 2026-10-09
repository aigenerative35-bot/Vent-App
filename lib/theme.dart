import 'package:flutter/material.dart';

/// Brand accents and gradients.
class Brand {
  static const violet = Color(0xFF6D5EF8);
  static const cyan = Color(0xFF22D3EE);
  static const pink = Color(0xFFF43F8E);
  static const green = Color(0xFF22C55E);
  static const amber = Color(0xFFF59E0B);
  static const primary = violet;

  static const gradient = LinearGradient(
    colors: [violet, cyan],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

/// Dark + light palettes so the app follows the system setting.
class Palette {
  final Color bg;
  final Color surface;
  final Color surfaceAlt;
  final Color text;
  final Color secondary;
  final Color border;

  const Palette({
    required this.bg,
    required this.surface,
    required this.surfaceAlt,
    required this.text,
    required this.secondary,
    required this.border,
  });

  static const dark = Palette(
    bg: Color(0xFF0A0E1A),
    surface: Color(0xFF121829),
    surfaceAlt: Color(0xFF1A2133),
    text: Color(0xFFF2F5FF),
    secondary: Color(0xFF9AA4BF),
    border: Color(0xFF232B40),
  );

  static const light = Palette(
    bg: Color(0xFFF5F6FB),
    surface: Color(0xFFFFFFFF),
    surfaceAlt: Color(0xFFEFF1F8),
    text: Color(0xFF0F1424),
    secondary: Color(0xFF5B6478),
    border: Color(0xFFE6E9F2),
  );

  bool get isDark => identical(this, dark);

  static Palette of(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? dark : light;

  List<BoxShadow> get cardShadow => isDark
      ? const []
      : [
          BoxShadow(
            color: const Color(0xFF0F1424).withValues(alpha: 0.05),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ];
}

ThemeData appTheme(Brightness brightness) {
  final p = brightness == Brightness.dark ? Palette.dark : Palette.light;

  return ThemeData(
    useMaterial3: true,
    brightness: brightness,
    scaffoldBackgroundColor: p.bg,
    colorScheme: ColorScheme.fromSeed(
      seedColor: Brand.violet,
      brightness: brightness,
    ).copyWith(
      primary: Brand.violet,
      surface: p.surface,
      onSurface: p.text,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: p.bg,
      foregroundColor: p.text,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      surfaceTintColor: Colors.transparent,
      titleTextStyle: TextStyle(color: p.text, fontSize: 20, fontWeight: FontWeight.w800),
    ),
    dividerTheme: DividerThemeData(color: p.border, thickness: 1, space: 1),
    tabBarTheme: TabBarThemeData(
      labelColor: p.text,
      unselectedLabelColor: p.secondary,
      indicatorColor: Brand.violet,
      indicatorSize: TabBarIndicatorSize.label,
      dividerColor: p.border,
      labelStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
      unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: p.surfaceAlt,
      hintStyle: TextStyle(color: p.secondary),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: p.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: p.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Brand.violet, width: 1.6),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: Brand.violet,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        textStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: p.text,
        side: BorderSide(color: p.border),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 13),
        textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
      ),
    ),
  );
}

/// A soft, rounded card used across the app.
class SoftCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final Gradient? gradient;

  const SoftCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.onTap,
    this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    final p = Palette.of(context);
    return Container(
      decoration: BoxDecoration(
        color: gradient == null ? p.surface : null,
        gradient: gradient,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: gradient == null ? p.border : Colors.transparent),
        boxShadow: p.cardShadow,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onTap,
          child: Padding(padding: padding, child: child),
        ),
      ),
    );
  }
}
