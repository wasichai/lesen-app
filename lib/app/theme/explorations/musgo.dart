// Generado a partir de lesen-ui/docs/design-system/lesen/explorations/tokens/musgo.json (docs/design/README.md).
// Si la dirección cambia allí, se vuelve a generar; test/app/design_directions_test.dart lo comprueba.
import 'package:flutter/material.dart';

import '../../../features/reader/domain/reader_preferences.dart';
import '../../../features/reader/presentation/reader_theme.dart';
import '../tokens.dart';

// Musgo: Calma natural: crecimiento intelectual sereno. Arena, musgo y pizarra mineral; acento contenido y formas orgánicas suaves.

const _type = LesenType(
  display: TypeStep(FontWeight(500), tracking: -0.015),
  h1: TypeStep(FontWeight(520), tracking: -0.01),
  h2: TypeStep(FontWeight(560), tracking: -0.005),
  h3: TypeStep(FontWeight(600)),
  h4: TypeStep(FontWeight(640)),
  label: TypeStep(FontWeight(650)),
);

const musgoLight = LesenTokens(
  surface: Color(0xFFF3EFE6),
  surfaceMuted: Color(0xFFE9E3D6),
  surfaceRaised: Color(0xFFFAF8F2),
  ink: Color(0xFF1D2A24),
  inkMuted: Color(0xFF4D5A52),
  brand: Color(0xFF2F5E45),
  brandStrong: Color(0xFF224633),
  brandSoft: Color(0xFFDFE9DF),
  focus: Color(0xFF2F5F7A),
  markSaved: Color(0xFFEADB9F),
  markNew: Color(0xFFA0522D),
  markSentence: Color(0xFFE6E7D5),
  onBrand: Color(0xFFFFFFFF),
  tones: [Color(0xFF2F5F6E), Color(0xFF4F6A3E), Color(0xFF7F5B17), Color(0xFF6B4A5E)],
  displayFont: 'SourceSerif4',
  readingFont: 'SourceSerif4',
  interfaceFont: 'Manrope',
  typeScale: _type,
  radiusSm: 8,
  radiusMd: 12,
  radiusLg: 18,
  radiusXl: 26,
  radiusCard: 22,
  buttonRadius: 14,
  chipRadius: 9999,
);

const musgoDark = LesenTokens(
  surface: Color(0xFF141A17),
  surfaceMuted: Color(0xFF0E1311),
  surfaceRaised: Color(0xFF1C2420),
  ink: Color(0xFFE8E6DC),
  inkMuted: Color(0xFFA9ADA0),
  brand: Color(0xFF9FCAA9),
  brandStrong: Color(0xFFC2E0C8),
  brandSoft: Color(0xFF213429),
  focus: Color(0xFF93BFD6),
  markSaved: Color(0xFF4A4422),
  markNew: Color(0xFFE3A27E),
  markSentence: Color(0xFF24302A),
  onBrand: Color(0xFF0D1A12),
  tones: [Color(0xFF8FC3CF), Color(0xFFB2CC98), Color(0xFFDCBF7A), Color(0xFFD2ADC4)],
  displayFont: 'SourceSerif4',
  readingFont: 'SourceSerif4',
  interfaceFont: 'Manrope',
  typeScale: _type,
  radiusSm: 8,
  radiusMd: 12,
  radiusLg: 18,
  radiusXl: 26,
  radiusCard: 22,
  buttonRadius: 14,
  chipRadius: 9999,
);

const musgoReader = {
  ReaderTheme.light: ReaderPalette(
    paper: Color(0xFFFAF8F1),
    ink: Color(0xFF202B25),
    inkMuted: Color(0xFF535F57),
    brand: Color(0xFF2F5E45),
    saved: Color(0xFFEADB9F),
    sentence: Color(0xFFEBECDC),
    active: Color(0xFFDFE9DF),
    brightness: Brightness.light,
    tokens: musgoLight,
  ),
  ReaderTheme.sepia: ReaderPalette(
    paper: Color(0xFFEFE6D2),
    ink: Color(0xFF332B1D),
    inkMuted: Color(0xFF5A4C36),
    brand: Color(0xFF2D5A40),
    saved: Color(0xFFE6D08A),
    sentence: Color(0xFFE3D8BD),
    active: Color(0xFFDBE0CC),
    brightness: Brightness.light,
    tokens: musgoLight,
  ),
  ReaderTheme.dark: ReaderPalette(
    paper: Color(0xFF101512),
    ink: Color(0xFFDCDCCF),
    inkMuted: Color(0xFFA1A598),
    brand: Color(0xFF9FCAA9),
    saved: Color(0xFF45401F),
    sentence: Color(0xFF1F2924),
    active: Color(0xFF213429),
    brightness: Brightness.dark,
    tokens: musgoDark,
  ),
};
