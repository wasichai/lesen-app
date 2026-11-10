import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';

/// Peso y espaciado de un escalón tipográfico. [tracking] va en em (como el `letter-spacing` de la web) y
/// [trackingPx] en píxeles lógicos; «Papel y tinta» usa este último.
@immutable
class TypeStep {
  const TypeStep(this.weight, {this.tracking = 0, this.trackingPx = 0});

  final FontWeight weight;
  final double tracking;
  final double trackingPx;

  double letterSpacing(double fontSize) => tracking * fontSize + trackingPx;

  @override
  bool operator ==(Object other) => other is TypeStep && other.weight == weight && other.tracking == tracking && other.trackingPx == trackingPx;

  @override
  int get hashCode => Object.hash(weight, tracking, trackingPx);
}

/// La escala de títulos y etiquetas (`type` en los tokens de la web): display, h1…h4 y label.
@immutable
class LesenType {
  const LesenType({required this.display, required this.h1, required this.h2, required this.h3, required this.h4, required this.label});

  static const paper = LesenType(
    display: TypeStep(FontWeight.w500, trackingPx: -0.2),
    h1: TypeStep(FontWeight.w600, trackingPx: -0.2),
    h2: TypeStep(FontWeight.w600, trackingPx: -0.2),
    h3: TypeStep(FontWeight.w600, trackingPx: -0.2),
    h4: TypeStep(FontWeight.w600, trackingPx: -0.2),
    label: TypeStep(FontWeight.w600),
  );

  final TypeStep display;
  final TypeStep h1;
  final TypeStep h2;
  final TypeStep h3;
  final TypeStep h4;
  final TypeStep label;

  @override
  bool operator ==(Object other) =>
      other is LesenType && other.display == display && other.h1 == h1 && other.h2 == h2 && other.h3 == h3 && other.h4 == h4 && other.label == label;

  @override
  int get hashCode => Object.hash(display, h1, h2, h3, h4, label);
}

/// Tokens de «Papel y tinta» (ADR-0008), los mismos que `lesen-ui/docs/design-system/lesen/tokens.json`.
///
/// Los colores, las familias, los radios y la escala tipográfica viajan en el tema para que las direcciones del
/// laboratorio de diseño (`docs/design/README.md`) los cambien; los valores por defecto son los de «Papel y tinta».
@immutable
class LesenTokens extends ThemeExtension<LesenTokens> {
  const LesenTokens({
    required this.surface,
    required this.surfaceMuted,
    required this.surfaceRaised,
    required this.ink,
    required this.inkMuted,
    required this.brand,
    required this.brandStrong,
    required this.brandSoft,
    required this.focus,
    required this.markSaved,
    required this.markNew,
    required this.markSentence,
    required this.onBrand,
    this.tones = paperTones,
    this.displayFont = 'Newsreader',
    this.readingFont = 'Newsreader',
    this.interfaceFont = 'SourceSans3',
    this.typeScale = LesenType.paper,
    this.radiusSm = 6,
    this.radiusMd = 10,
    this.radiusLg = 14,
    this.radiusXl = 20,
    this.radiusCard = 18,
    this.buttonRadius = 14,
    this.chipRadius = 20,
  });

  static const light = LesenTokens(
    surface: Color(0xFFFBF7F0),
    surfaceMuted: Color(0xFFF3ECDF),
    surfaceRaised: Color(0xFFFFFDF9),
    ink: Color(0xFF1F2430),
    inkMuted: Color(0xFF565B67),
    brand: Color(0xFFA8402A),
    brandStrong: Color(0xFF85301D),
    brandSoft: Color(0xFFF6E3D8),
    focus: Color(0xFF2F5D8A),
    markSaved: Color(0xFFF4E2A8),
    markNew: Color(0xFFA8402A),
    markSentence: Color(0xFFF6EAD9),
    onBrand: Colors.white,
  );

  static const dark = LesenTokens(
    surface: Color(0xFF17181D),
    surfaceMuted: Color(0xFF111216),
    surfaceRaised: Color(0xFF212229),
    ink: Color(0xFFEFE8DC),
    inkMuted: Color(0xFFB4AD9F),
    brand: Color(0xFFF19A7B),
    brandStrong: Color(0xFFF7B8A0),
    brandSoft: Color(0xFF3B241C),
    focus: Color(0xFF8FB4E3),
    markSaved: Color(0xFF5A4A1E),
    markNew: Color(0xFFF19A7B),
    markSentence: Color(0xFF2A2620),
    onBrand: Color(0xFF2A130B),
  );

  /// Tonos de «Papel y tinta», iguales en claro y oscuro.
  static const paperTones = <Color>[Color(0xFF275C6B), Color(0xFF4F6F55), Color(0xFF8C6216), Color(0xFF6D4566)];

  final Color surface;
  final Color surfaceMuted;
  final Color surfaceRaised;
  final Color ink;
  final Color inkMuted;
  final Color brand;
  final Color brandStrong;
  final Color brandSoft;
  final Color focus;
  final Color markSaved;
  final Color markNew;
  final Color markSentence;

  /// Texto sobre el acento (botones rellenos).
  final Color onBrand;

  /// Tonos de los temas (mar, salvia, ocre, ciruela), para portadas sin acento y etiquetas.
  final List<Color> tones;

  /// Familia de los títulos.
  final String displayFont;

  /// Familia del texto que se lee (lector, citas, ejemplos).
  final String readingFont;

  /// Familia de la interfaz.
  final String interfaceFont;
  final LesenType typeScale;

  final double radiusSm;
  final double radiusMd;
  final double radiusLg;
  final double radiusXl;
  final double radiusCard;

  /// Radio de los botones; 9999 o más es una píldora.
  final double buttonRadius;

  /// Radio de los chips; 9999 o más es una píldora.
  final double chipRadius;

  /// Objetivo táctil mínimo (48 dp, la pauta de Android; iOS pide 44).
  static const target = 48.0;

  /// Ancho máximo de un bloque de texto (38rem en la web).
  static const measure = 608.0;

  static LesenTokens of(BuildContext context) => Theme.of(context).extension<LesenTokens>()!;

  @override
  LesenTokens copyWith({
    Color? surface,
    Color? surfaceMuted,
    Color? surfaceRaised,
    Color? ink,
    Color? inkMuted,
    Color? brand,
    Color? brandStrong,
    Color? brandSoft,
    Color? focus,
    Color? markSaved,
    Color? markNew,
    Color? markSentence,
    Color? onBrand,
    List<Color>? tones,
    String? displayFont,
    String? readingFont,
    String? interfaceFont,
    LesenType? typeScale,
    double? radiusSm,
    double? radiusMd,
    double? radiusLg,
    double? radiusXl,
    double? radiusCard,
    double? buttonRadius,
    double? chipRadius,
  }) => LesenTokens(
    surface: surface ?? this.surface,
    surfaceMuted: surfaceMuted ?? this.surfaceMuted,
    surfaceRaised: surfaceRaised ?? this.surfaceRaised,
    ink: ink ?? this.ink,
    inkMuted: inkMuted ?? this.inkMuted,
    brand: brand ?? this.brand,
    brandStrong: brandStrong ?? this.brandStrong,
    brandSoft: brandSoft ?? this.brandSoft,
    focus: focus ?? this.focus,
    markSaved: markSaved ?? this.markSaved,
    markNew: markNew ?? this.markNew,
    markSentence: markSentence ?? this.markSentence,
    onBrand: onBrand ?? this.onBrand,
    tones: tones ?? this.tones,
    displayFont: displayFont ?? this.displayFont,
    readingFont: readingFont ?? this.readingFont,
    interfaceFont: interfaceFont ?? this.interfaceFont,
    typeScale: typeScale ?? this.typeScale,
    radiusSm: radiusSm ?? this.radiusSm,
    radiusMd: radiusMd ?? this.radiusMd,
    radiusLg: radiusLg ?? this.radiusLg,
    radiusXl: radiusXl ?? this.radiusXl,
    radiusCard: radiusCard ?? this.radiusCard,
    buttonRadius: buttonRadius ?? this.buttonRadius,
    chipRadius: chipRadius ?? this.chipRadius,
  );

  @override
  LesenTokens lerp(LesenTokens? other, double t) {
    if (other == null) return this;
    Color l(Color a, Color b) => Color.lerp(a, b, t)!;
    double d(double a, double b) => lerpDouble(a, b, t)!;
    // familias y escala no se interpolan: cambian a mitad de la transición
    final near = t < 0.5 ? this : other;
    return LesenTokens(
      surface: l(surface, other.surface),
      surfaceMuted: l(surfaceMuted, other.surfaceMuted),
      surfaceRaised: l(surfaceRaised, other.surfaceRaised),
      ink: l(ink, other.ink),
      inkMuted: l(inkMuted, other.inkMuted),
      brand: l(brand, other.brand),
      brandStrong: l(brandStrong, other.brandStrong),
      brandSoft: l(brandSoft, other.brandSoft),
      focus: l(focus, other.focus),
      markSaved: l(markSaved, other.markSaved),
      markNew: l(markNew, other.markNew),
      markSentence: l(markSentence, other.markSentence),
      onBrand: l(onBrand, other.onBrand),
      tones: [for (var i = 0; i < tones.length; i++) l(tones[i], other.tones[i])],
      displayFont: near.displayFont,
      readingFont: near.readingFont,
      interfaceFont: near.interfaceFont,
      typeScale: near.typeScale,
      radiusSm: d(radiusSm, other.radiusSm),
      radiusMd: d(radiusMd, other.radiusMd),
      radiusLg: d(radiusLg, other.radiusLg),
      radiusXl: d(radiusXl, other.radiusXl),
      radiusCard: d(radiusCard, other.radiusCard),
      buttonRadius: d(buttonRadius, other.buttonRadius),
      chipRadius: d(chipRadius, other.chipRadius),
    );
  }
}

/// Color de acento de una lectura: el suyo si lo trae (`#RRGGBB`), si no un tono estable por su slug.
Color accentFor(String slug, String? accent, {List<Color> tones = LesenTokens.paperTones}) {
  if (accent != null && RegExp(r'^#[0-9a-fA-F]{6}$').hasMatch(accent)) {
    return Color(int.parse('FF${accent.substring(1)}', radix: 16));
  }
  final hash = slug.codeUnits.fold<int>(0, (a, c) => (a * 31 + c) & 0x7fffffff);
  return tones[hash % tones.length];
}
