import 'package:flutter/material.dart';

/// Brand blue (Weibo-style layout, blue theme).
class Brand {
  static const blue = Color(0xFF1E7BFF);
  static const blueDark = Color(0xFF0B5CD6);
  static const green = Color(0xFF12B76A);
  static const red = Color(0xFFEF4444);
  static const amber = Color(0xFFF59E0B);

  static const gradient = LinearGradient(
    colors: [Color(0xFF1E7BFF), Color(0xFF4DA3FF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const cover = LinearGradient(
    colors: [Color(0xFF0B5CD6), Color(0xFF4DA3FF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

class Palette {
  final Color bg;
  final Color surface;
  final Color surfaceAlt;
  final Color text;
  final Color secondary;
  final Color border;
  final Color divider;

  const Palette({
    required this.bg,
    required this.surface,
    required this.surfaceAlt,
    required this.text,
    required this.secondary,
    required this.border,
    required this.divider,
  });

  static const dark = Palette(
    bg: Color(0xFF0F1218),
    surface: Color(0xFF171B23),
    surfaceAlt: Color(0xFF1F2530),
    text: Color(0xFFE9EDF3),
    secondary: Color(0xFF98A2B3),
    border: Color(0xFF262C38),
    divider: Color(0xFF232936),
  );

  static const light = Palette(
    bg: Color(0xFFF5F7FA),
    surface: Color(0xFFFFFFFF),
    surfaceAlt: Color(0xFFF0F3F8),
    text: Color(0xFF10131A),
    secondary: Color(0xFF6B7280),
    border: Color(0xFFE8EBF0),
    divider: Color(0xFFEDF0F5),
  );

  bool get isDark => identical(this, dark);

  static Palette of(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? dark : light;

  List<BoxShadow> get shadow => isDark
      ? const []
      : [
          BoxShadow(
            color: const Color(0xFF10131A).withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ];
}

ThemeData appTheme(Brightness brightness) {
  final p = brightness == Brightness.dark ? Palette.dark : Palette.light;

  return ThemeData(
    useMaterial3: true,
    brightness: brightness,
    scaffoldBackgroundColor: p.bg,
    colorScheme: ColorScheme.fromSeed(seedColor: Brand.blue, brightness: brightness)
        .copyWith(primary: Brand.blue, surface: p.surface, onSurface: p.text),
    appBarTheme: AppBarTheme(
      backgroundColor: p.surface,
      foregroundColor: p.text,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      surfaceTintColor: Colors.transparent,
      titleTextStyle: TextStyle(color: p.text, fontSize: 19, fontWeight: FontWeight.w800),
    ),
    dividerTheme: DividerThemeData(color: p.divider, thickness: 1, space: 1),
    tabBarTheme: TabBarThemeData(
      labelColor: Brand.blue,
      unselectedLabelColor: p.secondary,
      indicatorColor: Brand.blue,
      indicatorSize: TabBarIndicatorSize.label,
      dividerColor: p.divider,
      labelStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14.5),
      unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14.5),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: p.surfaceAlt,
      hintStyle: TextStyle(color: p.secondary),
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
      enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Brand.blue, width: 1.4),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: Brand.blue,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        textStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: p.text,
        side: BorderSide(color: p.border),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
      ),
    ),
  );
}

/// A rounded surface block.
class Block extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final Gradient? gradient;
  final Color? color;
  const Block({
    super.key,
    required this.child,
    this.padding = EdgeInsets.zero,
    this.onTap,
    this.gradient,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final p = Palette.of(context);
    return Container(
      decoration: BoxDecoration(
        color: gradient == null ? (color ?? p.surface) : null,
        gradient: gradient,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: gradient == null ? p.border : Colors.transparent),
        boxShadow: p.shadow,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(padding: padding, child: child),
        ),
      ),
    );
  }
}
