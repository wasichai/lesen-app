import 'package:flutter/material.dart';

import 'tokens.dart';

/// Familia con los signos del AFI, empaquetada siempre.
const ipaFont = 'SourceSans3';

/// El tema de la app para un brillo; [tokens] cambia la dirección de diseño (por defecto, «Papel y tinta»).
ThemeData buildTheme(Brightness brightness, {LesenTokens? tokens}) {
  final t = tokens ?? (brightness == Brightness.light ? LesenTokens.light : LesenTokens.dark);
  final onBrand = t.onBrand;
  final scheme = ColorScheme(
    brightness: brightness,
    primary: t.brand,
    onPrimary: onBrand,
    primaryContainer: t.brandSoft,
    onPrimaryContainer: t.brandStrong,
    secondary: t.tones[0],
    onSecondary: Colors.white,
    tertiary: t.tones[2],
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

  // la transcripción fonética (AFI) solo la cubre Source Sans 3; las demás familias caen en ella para esos signos
  final fallback = t.interfaceFont == ipaFont ? null : const [ipaFont];
  final base = ThemeData(useMaterial3: true, colorScheme: scheme, fontFamily: t.interfaceFont, fontFamilyFallback: fallback);
  final type = t.typeScale;
  TextStyle heading(double size, TypeStep step, {double height = 1.15}) =>
      TextStyle(fontFamily: t.displayFont, fontSize: size, fontWeight: step.weight, height: height, color: t.ink, letterSpacing: step.letterSpacing(size));
  TextStyle sans(double size, FontWeight weight, {double height = 1.4, Color? color}) =>
      TextStyle(fontFamily: t.interfaceFont, fontFamilyFallback: fallback, fontSize: size, fontWeight: weight, height: height, color: color ?? t.ink);

  final text = base.textTheme.copyWith(
    displayLarge: heading(52, type.display),
    displayMedium: heading(40, type.display),
    displaySmall: heading(34, type.display),
    headlineLarge: heading(30, type.h1),
    headlineMedium: heading(26, type.h2),
    headlineSmall: heading(23, type.h3),
    titleLarge: heading(21, type.h4, height: 1.2),
    titleMedium: sans(17, FontWeight.w600),
    titleSmall: sans(15, FontWeight.w600),
    bodyLarge: sans(17, FontWeight.w400, height: 1.5),
    bodyMedium: sans(15, FontWeight.w400, height: 1.45),
    bodySmall: sans(13, FontWeight.w400, color: t.inkMuted),
    labelLarge: sans(15, type.label.weight),
    labelMedium: sans(13, type.label.weight),
    labelSmall: sans(12, type.label.weight, color: t.inkMuted),
  );

  OutlinedBorder rounded(double radius) => radius >= 9999 ? const StadiumBorder() : RoundedRectangleBorder(borderRadius: BorderRadius.circular(radius));
  final shape = rounded(t.buttonRadius);
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
      shape: rounded(t.chipRadius),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: t.surfaceRaised,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(t.radiusMd),
        borderSide: BorderSide(color: scheme.outline),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(t.radiusMd),
        borderSide: BorderSide(color: scheme.outline),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(t.radiusMd),
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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(t.radiusXl))),
    ),
    dividerTheme: DividerThemeData(color: scheme.outlineVariant, space: 1),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: t.ink,
      contentTextStyle: sans(15, FontWeight.w500, color: t.surface),
    ),
  );
}
