// Generado a partir de lesen-ui/docs/design-system/lesen/explorations/tokens/atlas.json (docs/design/README.md).
// Si la dirección cambia allí, se vuelve a generar; test/app/design_directions_test.dart lo comprueba.
import 'package:flutter/material.dart';

import '../../../features/reader/domain/reader_preferences.dart';
import '../../../features/reader/presentation/reader_theme.dart';
import '../tokens.dart';

// Atlas: Minimal premium con un guiño cultural: neutros casi blancos y casi negros, un único acento ultramar y el bermellón reservado para el momento.

const _type = LesenType(
  display: TypeStep(FontWeight(600), tracking: -0.045),
  h1: TypeStep(FontWeight(600), tracking: -0.035),
  h2: TypeStep(FontWeight(600), tracking: -0.028),
  h3: TypeStep(FontWeight(600), tracking: -0.018),
  h4: TypeStep(FontWeight(600), tracking: -0.01),
  label: TypeStep(FontWeight(550)),
);

const atlasLight = LesenTokens(
  surface: Color(0xFFFAFAF8),
  surfaceMuted: Color(0xFFF0F0ED),
  surfaceRaised: Color(0xFFFFFFFF),
  ink: Color(0xFF0E0F12),
  inkMuted: Color(0xFF50525A),
  brand: Color(0xFF1C3FD1),
  brandStrong: Color(0xFF142FA3),
  brandSoft: Color(0xFFE5E9FC),
  focus: Color(0xFF1C3FD1),
  markSaved: Color(0xFFFFE58F),
  markNew: Color(0xFFD6361F),
  markSentence: Color(0xFFECEEF8),
  onBrand: Color(0xFFFFFFFF),
  tones: [Color(0xFF19606F), Color(0xFF3E6A4A), Color(0xFF845A00), Color(0xFF7A3D6E)],
  displayFont: 'Geist',
  readingFont: 'Newsreader',
  interfaceFont: 'Geist',
  typeScale: _type,
  radiusSm: 4,
  radiusMd: 6,
  radiusLg: 8,
  radiusXl: 12,
  radiusCard: 6,
  buttonRadius: 9999,
  chipRadius: 9999,
);

const atlasDark = LesenTokens(
  surface: Color(0xFF0C0C0E),
  surfaceMuted: Color(0xFF060607),
  surfaceRaised: Color(0xFF17171B),
  ink: Color(0xFFF2F2EE),
  inkMuted: Color(0xFFA8A8A2),
  brand: Color(0xFF8FA3FF),
  brandStrong: Color(0xFFB8C4FF),
  brandSoft: Color(0xFF1B2350),
  focus: Color(0xFF8FA3FF),
  markSaved: Color(0xFF4F4416),
  markNew: Color(0xFFFF7A5C),
  markSentence: Color(0xFF1E2030),
  onBrand: Color(0xFF0A0F2E),
  tones: [Color(0xFF7FCBD9), Color(0xFF9FCFAA), Color(0xFFE6BF6A), Color(0xFFE0A6D4)],
  displayFont: 'Geist',
  readingFont: 'Newsreader',
  interfaceFont: 'Geist',
  typeScale: _type,
  radiusSm: 4,
  radiusMd: 6,
  radiusLg: 8,
  radiusXl: 12,
  radiusCard: 6,
  buttonRadius: 9999,
  chipRadius: 9999,
);

const atlasReader = {
  ReaderTheme.light: ReaderPalette(
    paper: Color(0xFFFFFFFD),
    ink: Color(0xFF15161A),
    inkMuted: Color(0xFF55575E),
    brand: Color(0xFF1C3FD1),
    saved: Color(0xFFFFE58F),
    sentence: Color(0xFFEEF0F9),
    active: Color(0xFFE5E9FC),
    brightness: Brightness.light,
    tokens: atlasLight,
  ),
  ReaderTheme.sepia: ReaderPalette(
    paper: Color(0xFFF3ECDD),
    ink: Color(0xFF2F2A22),
    inkMuted: Color(0xFF5B5040),
    brand: Color(0xFF1A3AC2),
    saved: Color(0xFFEFD88C),
    sentence: Color(0xFFE8DFCA),
    active: Color(0xFFDFDFF0),
    brightness: Brightness.light,
    tokens: atlasLight,
  ),
  ReaderTheme.dark: ReaderPalette(
    paper: Color(0xFF0A0A0C),
    ink: Color(0xFFE6E6E1),
    inkMuted: Color(0xFFA0A09A),
    brand: Color(0xFF8FA3FF),
    saved: Color(0xFF4A3F14),
    sentence: Color(0xFF1B1D2B),
    active: Color(0xFF1B2350),
    brightness: Brightness.dark,
    tokens: atlasDark,
  ),
};
