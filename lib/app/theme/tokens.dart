import 'package:flutter/material.dart';

/// Tokens de «Papel y tinta» (ADR-0008), los mismos que `lesen-ui/docs/design-system/lesen/tokens.json`.
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
  );

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

  /// Tonos de los temas, para portadas sin acento y etiquetas.
  static const tones = <Color>[Color(0xFF275C6B), Color(0xFF4F6F55), Color(0xFF8C6216), Color(0xFF6D4566)];

  static const radiusSm = 6.0;
  static const radiusMd = 10.0;
  static const radiusLg = 14.0;
  static const radiusXl = 20.0;
  static const radiusCard = 18.0;

  /// Objetivo táctil mínimo (48 dp, la pauta de Android; iOS pide 44).
  static const target = 48.0;

  /// Ancho máximo de un bloque de texto (38rem en la web).
  static const measure = 608.0;

  static LesenTokens of(BuildContext context) => Theme.of(context).extension<LesenTokens>()!;

  @override
  LesenTokens copyWith() => this;

  @override
  LesenTokens lerp(LesenTokens? other, double t) {
    if (other == null) return this;
    Color l(Color a, Color b) => Color.lerp(a, b, t)!;
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
    );
  }
}

/// Color de acento de una lectura: el suyo si lo trae (`#RRGGBB`), si no un tono estable por su slug.
Color accentFor(String slug, String? accent) {
  if (accent != null && RegExp(r'^#[0-9a-fA-F]{6}$').hasMatch(accent)) {
    return Color(int.parse('FF${accent.substring(1)}', radix: 16));
  }
  final hash = slug.codeUnits.fold<int>(0, (a, c) => (a * 31 + c) & 0x7fffffff);
  return LesenTokens.tones[hash % LesenTokens.tones.length];
}
