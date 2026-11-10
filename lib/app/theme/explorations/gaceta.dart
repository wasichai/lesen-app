// Generado a partir de lesen-ui/docs/design-system/lesen/explorations/tokens/gaceta.json (docs/design/README.md).
// Si la dirección cambia allí, se vuelve a generar; test/app/design_directions_test.dart lo comprueba.
import 'package:flutter/material.dart';

import '../../../features/reader/domain/reader_preferences.dart';
import '../../../features/reader/presentation/reader_theme.dart';
import '../tokens.dart';

// Gaceta: Editorial y literaria: una revista literaria internacional. Marfil, tinta azul noche, oxblood y filetes de oro.

const _type = LesenType(
  display: TypeStep(FontWeight(380), tracking: -0.02),
  h1: TypeStep(FontWeight(400), tracking: -0.015),
  h2: TypeStep(FontWeight(430), tracking: -0.01),
  h3: TypeStep(FontWeight(500), tracking: -0.005),
  h4: TypeStep(FontWeight(560)),
  label: TypeStep(FontWeight(500)),
);

const gacetaLight = LesenTokens(
  surface: Color(0xFFF7F2E8),
  surfaceMuted: Color(0xFFEEE6D6),
  surfaceRaised: Color(0xFFFFFCF5),
  ink: Color(0xFF141B2D),
  inkMuted: Color(0xFF4F5566),
  brand: Color(0xFF7A1F2B),
  brandStrong: Color(0xFF5E1520),
  brandSoft: Color(0xFFF3E1DF),
  focus: Color(0xFF1F4F8F),
  markSaved: Color(0xFFF0DC9A),
  markNew: Color(0xFF7A1F2B),
  markSentence: Color(0xFFEFE3CF),
  onBrand: Color(0xFFFFFFFF),
  tones: [Color(0xFF1F5566), Color(0xFF4A6247), Color(0xFF7D5A10), Color(0xFF5F3A5C)],
  displayFont: 'Fraunces',
  readingFont: 'SourceSerif4',
  interfaceFont: 'IBMPlexSans',
  typeScale: _type,
  radiusSm: 2,
  radiusMd: 4,
  radiusLg: 6,
  radiusXl: 10,
  radiusCard: 3,
  buttonRadius: 3,
  chipRadius: 2,
);

const gacetaDark = LesenTokens(
  surface: Color(0xFF121521),
  surfaceMuted: Color(0xFF0C0E17),
  surfaceRaised: Color(0xFF1B1F2E),
  ink: Color(0xFFEDE6D6),
  inkMuted: Color(0xFFAAA697),
  brand: Color(0xFFE8A3A8),
  brandStrong: Color(0xFFF3C6C9),
  brandSoft: Color(0xFF3A1C22),
  focus: Color(0xFF8FB0E8),
  markSaved: Color(0xFF514520),
  markNew: Color(0xFFE8A3A8),
  markSentence: Color(0xFF252736),
  onBrand: Color(0xFF1A0B0E),
  tones: [Color(0xFF8CC3D1), Color(0xFFA7C3A0), Color(0xFFDFBF73), Color(0xFFD3A9CF)],
  displayFont: 'Fraunces',
  readingFont: 'SourceSerif4',
  interfaceFont: 'IBMPlexSans',
  typeScale: _type,
  radiusSm: 2,
  radiusMd: 4,
  radiusLg: 6,
  radiusXl: 10,
  radiusCard: 3,
  buttonRadius: 3,
  chipRadius: 2,
);

const gacetaReader = {
  ReaderTheme.light: ReaderPalette(
    paper: Color(0xFFFFFCF4),
    ink: Color(0xFF1A1F2C),
    inkMuted: Color(0xFF535867),
    brand: Color(0xFF7A1F2B),
    saved: Color(0xFFF0DC9A),
    sentence: Color(0xFFF3E9D6),
    active: Color(0xFFF3E1DF),
    brightness: Brightness.light,
    tokens: gacetaLight,
  ),
  ReaderTheme.sepia: ReaderPalette(
    paper: Color(0xFFF1E7D3),
    ink: Color(0xFF33281B),
    inkMuted: Color(0xFF5A4A35),
    brand: Color(0xFF74202A),
    saved: Color(0xFFE8D08A),
    sentence: Color(0xFFE6D8BD),
    active: Color(0xFFEAD2C8),
    brightness: Brightness.light,
    tokens: gacetaLight,
  ),
  ReaderTheme.dark: ReaderPalette(
    paper: Color(0xFF0F111A),
    ink: Color(0xFFE4DCCB),
    inkMuted: Color(0xFFA39E90),
    brand: Color(0xFFE8A3A8),
    saved: Color(0xFF4B4020),
    sentence: Color(0xFF20222F),
    active: Color(0xFF3A1C22),
    brightness: Brightness.dark,
    tokens: gacetaDark,
  ),
};
