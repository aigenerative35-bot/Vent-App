import 'package:flutter/material.dart';

/// Facebook-style brand colours.
class Brand {
  static const blue = Color(0xFF1877F2);
  static const blueDark = Color(0xFF0A66C2);
  static const green = Color(0xFF42B72A);
  static const red = Color(0xFFF02849);

  static const gradient = LinearGradient(
    colors: [Color(0xFF1877F2), Color(0xFF4B9BFF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const cover = LinearGradient(
    colors: [Color(0xFF1877F2), Color(0xFF6BB6FF)],
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
    bg: Color(0xFF18191A),
    surface: Color(0xFF242526),
    surfaceAlt: Color(0xFF3A3B3C),
    text: Color(0xFFE4E6EB),
    secondary: Color(0xFFB0B3B8),
    border: Color(0xFF3E4042),
    divider: Color(0xFF3E4042),
  );

  static const light = Palette(
    bg: Color(0xFFF0F2F5),
    surface: Color(0xFFFFFFFF),
    surfaceAlt: Color(0xFFF0F2F5),
    text: Color(0xFF050505),
    secondary: Color(0xFF65676B),
    border: Color(0xFFE4E6EB),
    divider: Color(0xFFE4E6EB),
  );

  bool get isDark => identical(this, dark);

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
      seedColor: Brand.blue,
      brightness: brightness,
    ).copyWith(primary: Brand.blue, surface: p.surface, onSurface: p.text),
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
      indicatorSize: TabBarIndicatorSize.tab,
      dividerColor: p.divider,
      labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
      unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: p.surfaceAlt,
      hintStyle: TextStyle(color: p.secondary),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(22),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(22),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(22),
        borderSide: const BorderSide(color: Brand.blue, width: 1.4),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: Brand.blue,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: p.text,
        side: BorderSide(color: p.border),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
      ),
    ),
  );
}

/// A flat Facebook-style card block.
class FbCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  const FbCard({super.key, required this.child, this.padding = EdgeInsets.zero, this.onTap});

  @override
  Widget build(BuildContext context) {
    final p = Palette.of(context);
    return Container(
      color: p.surface,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          child: Padding(padding: padding, child: child),
        ),
      ),
    );
  }
}
