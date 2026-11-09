import 'package:flutter/material.dart';

import 'tokens.dart';

const readingFont = 'Newsreader';
const interfaceFont = 'SourceSans3';

ThemeData buildTheme(Brightness brightness) {
  final t = brightness == Brightness.light ? LesenTokens.light : LesenTokens.dark;
  final onBrand = brightness == Brightness.light ? Colors.white : const Color(0xFF2A130B);
  final scheme = ColorScheme(
    brightness: brightness,
    primary: t.brand,
    onPrimary: onBrand,
    primaryContainer: t.brandSoft,
    onPrimaryContainer: t.brandStrong,
    secondary: LesenTokens.tones[0],
    onSecondary: Colors.white,
    tertiary: LesenTokens.tones[2],
    onTertiary: Colors.white,
    error: const Color(0xFFB3261E),
    onError: Colors.white,
    surface: t.surface,
    onSurface: t.ink,
    onSurfaceVariant: t.inkMuted,
    surfaceContainerLowest: t.surfaceRaised,
    surfaceContainerLow: t.surfaceRaised,
    surfaceContainer: t.surfaceMuted,
    surfaceContainerHigh: t.surfaceMuted,
    surfaceContainerHighest: t.surfaceMuted,
    outline: t.inkMuted.withValues(alpha: 0.45),
    outlineVariant: t.inkMuted.withValues(alpha: 0.2),
  );

  final base = ThemeData(useMaterial3: true, colorScheme: scheme, fontFamily: interfaceFont);
  TextStyle serif(double size, FontWeight weight, {double height = 1.15}) =>
      TextStyle(fontFamily: readingFont, fontSize: size, fontWeight: weight, height: height, color: t.ink, letterSpacing: -0.2);
  TextStyle sans(double size, FontWeight weight, {double height = 1.4, Color? color}) =>
      TextStyle(fontFamily: interfaceFont, fontSize: size, fontWeight: weight, height: height, color: color ?? t.ink);

  final text = base.textTheme.copyWith(
    displayLarge: serif(52, FontWeight.w500),
    displayMedium: serif(40, FontWeight.w500),
    displaySmall: serif(34, FontWeight.w500),
    headlineLarge: serif(30, FontWeight.w600),
    headlineMedium: serif(26, FontWeight.w600),
    headlineSmall: serif(23, FontWeight.w600),
    titleLarge: serif(21, FontWeight.w600, height: 1.2),
    titleMedium: sans(17, FontWeight.w600),
    titleSmall: sans(15, FontWeight.w600),
    bodyLarge: sans(17, FontWeight.w400, height: 1.5),
    bodyMedium: sans(15, FontWeight.w400, height: 1.45),
    bodySmall: sans(13, FontWeight.w400, color: t.inkMuted),
    labelLarge: sans(15, FontWeight.w600),
    labelMedium: sans(13, FontWeight.w600),
    labelSmall: sans(12, FontWeight.w600, color: t.inkMuted),
  );

  final shape = RoundedRectangleBorder(borderRadius: BorderRadius.circular(LesenTokens.radiusLg));
  const minSize = Size(LesenTokens.target, LesenTokens.target);
  return base.copyWith(
    extensions: [t],
    scaffoldBackgroundColor: t.surface,
    textTheme: text,
    appBarTheme: AppBarTheme(
      backgroundColor: t.surface,
      foregroundColor: t.ink,
      elevation: 0,
      scrolledUnderElevation: 0.5,
      centerTitle: false,
      titleTextStyle: text.titleLarge,
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(minimumSize: const Size(64, 52), shape: shape, textStyle: text.labelLarge),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(64, 52),
        shape: shape,
        foregroundColor: t.ink,
        side: BorderSide(color: scheme.outline),
        textStyle: text.labelLarge,
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(minimumSize: minSize, foregroundColor: t.brand, textStyle: text.labelLarge),
    ),
    iconButtonTheme: IconButtonThemeData(style: IconButton.styleFrom(minimumSize: minSize)),
    chipTheme: ChipThemeData(
      backgroundColor: t.surfaceRaised,
      selectedColor: t.brandSoft,
      side: BorderSide(color: scheme.outlineVariant),
      labelStyle: text.labelMedium,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(LesenTokens.radiusXl)),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: t.surfaceRaised,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(LesenTokens.radiusMd),
        borderSide: BorderSide(color: scheme.outline),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(LesenTokens.radiusMd),
        borderSide: BorderSide(color: scheme.outline),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(LesenTokens.radiusMd),
        borderSide: BorderSide(color: t.focus, width: 2),
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: t.surfaceRaised,
      indicatorColor: t.brandSoft,
      elevation: 0,
      height: 68,
      labelTextStyle: WidgetStatePropertyAll(text.labelSmall!.copyWith(color: t.ink)),
      iconTheme: WidgetStateProperty.resolveWith((s) => IconThemeData(color: s.contains(WidgetState.selected) ? t.brandStrong : t.inkMuted)),
    ),
    navigationRailTheme: NavigationRailThemeData(
      backgroundColor: t.surfaceRaised,
      indicatorColor: t.brandSoft,
      selectedIconTheme: IconThemeData(color: t.brandStrong),
      unselectedIconTheme: IconThemeData(color: t.inkMuted),
      selectedLabelTextStyle: text.labelMedium!.copyWith(color: t.ink),
      unselectedLabelTextStyle: text.labelMedium!.copyWith(color: t.inkMuted),
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: t.surfaceRaised,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(LesenTokens.radiusXl))),
    ),
    dividerTheme: DividerThemeData(color: scheme.outlineVariant, space: 1),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: t.ink,
      contentTextStyle: sans(15, FontWeight.w500, color: t.surface),
    ),
  );
}
