import 'package:flutter/material.dart';

import 'liquid_glass.dart';

class GopeedTheme {
  static ThemeData _build(Brightness brightness) {
    final dark = brightness == Brightness.dark;
    final scheme = ColorScheme.fromSeed(
      seedColor: LiquidGlassPalette.accent,
      brightness: brightness,
      surface: dark ? const Color(0xFF121A18) : const Color(0xFFF7FBF9),
    );

    final base = ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: Colors.transparent,
      canvasColor: Colors.transparent,
      splashFactory: InkSparkle.splashFactory,
    );

    final glass = LiquidGlassPalette.glassTint(brightness);
    final strongGlass = LiquidGlassPalette.strongGlassTint(brightness);
    final outline = LiquidGlassPalette.border(brightness);
    final radius16 = BorderRadius.circular(16);
    final radius20 = BorderRadius.circular(20);
    final radius24 = BorderRadius.circular(24);

    return base.copyWith(
      scaffoldBackgroundColor: Colors.transparent,
      appBarTheme: AppBarThemeData(
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        foregroundColor: scheme.onSurface,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: glass,
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.black.withOpacity(dark ? 0.18 : 0.07),
        margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        shape: RoundedRectangleBorder(
          borderRadius: radius20,
          side: BorderSide(color: outline.withOpacity(dark ? 0.65 : 0.70)),
        ),
      ),
      dialogTheme: DialogThemeData(
        elevation: 0,
        backgroundColor: strongGlass,
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.black.withOpacity(dark ? 0.30 : 0.12),
        shape: RoundedRectangleBorder(
          borderRadius: radius24,
          side: BorderSide(color: outline.withOpacity(0.70)),
        ),
      ),
      drawerTheme: DrawerThemeData(
        elevation: 0,
        backgroundColor: strongGlass,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: const BorderRadius.horizontal(left: Radius.circular(28)),
          side: BorderSide(color: outline.withOpacity(0.65)),
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        elevation: 0,
        modalElevation: 0,
        backgroundColor: strongGlass,
        modalBackgroundColor: strongGlass,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        elevation: 0,
        focusElevation: 0,
        hoverElevation: 0,
        highlightElevation: 0,
        backgroundColor: strongGlass,
        foregroundColor: scheme.primary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
          side: BorderSide(color: outline.withOpacity(0.72)),
        ),
      ),
      inputDecorationTheme: InputDecorationThemeData(
        filled: true,
        fillColor: glass,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: radius16,
          borderSide: BorderSide(color: outline.withOpacity(0.65)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: radius16,
          borderSide: BorderSide(color: outline.withOpacity(0.58)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: radius16,
          borderSide: BorderSide(
            color: scheme.primary.withOpacity(0.85),
            width: 1.4,
          ),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: radius20),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: strongGlass,
          foregroundColor: scheme.onSurface,
          surfaceTintColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: radius20,
            side: BorderSide(color: outline.withOpacity(0.60)),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          side: BorderSide(color: outline.withOpacity(0.75)),
          shape: RoundedRectangleBorder(borderRadius: radius20),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: ButtonStyle(
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          overlayColor: WidgetStatePropertyAll(
            scheme.primary.withOpacity(0.10),
          ),
        ),
      ),
      tabBarTheme: TabBarThemeData(
        dividerColor: Colors.transparent,
        indicatorSize: TabBarIndicatorSize.tab,
        labelColor: scheme.primary,
        unselectedLabelColor: scheme.onSurface.withOpacity(0.58),
        indicator: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: scheme.primary.withOpacity(dark ? 0.18 : 0.13),
          border: Border.all(color: outline.withOpacity(0.42)),
        ),
      ),
      listTileTheme: ListTileThemeData(
        iconColor: scheme.onSurface.withOpacity(0.72),
        shape: RoundedRectangleBorder(borderRadius: radius16),
      ),
      popupMenuTheme: PopupMenuThemeData(
        elevation: 0,
        color: strongGlass,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: radius20,
          side: BorderSide(color: outline.withOpacity(0.65)),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: scheme.onSurface.withOpacity(dark ? 0.10 : 0.08),
        thickness: 1,
        space: 1,
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: scheme.primary,
        linearTrackColor: scheme.onSurface.withOpacity(0.08),
        linearMinHeight: 3,
        borderRadius: BorderRadius.circular(99),
      ),
      checkboxTheme: CheckboxThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        side: BorderSide(color: outline.withOpacity(0.80)),
      ),
      switchTheme: SwitchThemeData(
        trackOutlineColor: WidgetStatePropertyAll(outline.withOpacity(0.45)),
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return scheme.primary;
          return scheme.onSurface.withOpacity(0.75);
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return scheme.primary.withOpacity(0.28);
          }
          return scheme.onSurface.withOpacity(0.10);
        }),
      ),
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: Colors.transparent,
        indicatorColor: scheme.primary.withOpacity(0.14),
        selectedIconTheme: IconThemeData(color: scheme.primary),
        selectedLabelTextStyle: TextStyle(color: scheme.primary),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        elevation: 0,
        backgroundColor: Colors.transparent,
        selectedItemColor: scheme.primary,
        unselectedItemColor: scheme.onSurface.withOpacity(0.58),
      ),
    );
  }

  static final ThemeData light = _build(Brightness.light);
  static final ThemeData dark = _build(Brightness.dark);
}
