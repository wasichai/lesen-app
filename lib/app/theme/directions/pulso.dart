// Generado a partir de lesen-ui/docs/design-system/lesen/explorations/tokens/pulso.json (docs/design/README.md,
// ADR-0011). Si cambia allí, se vuelve a generar; test/app/design_directions_test.dart lo comprueba.
import 'package:flutter/material.dart';

import '../../../features/reader/domain/reader_preferences.dart';
import '../../../features/reader/presentation/reader_theme.dart';
import '../tokens.dart';

// Pulso: Aprendizaje vibrante: energía de producto de consumo sin infantilizar. Índigo seguro, coral para lo nuevo, superficies frías y claras.

const _type = LesenType(
  display: TypeStep(FontWeight(800), tracking: -0.035),
  h1: TypeStep(FontWeight(800), tracking: -0.03),
  h2: TypeStep(FontWeight(750), tracking: -0.025),
  h3: TypeStep(FontWeight(700), tracking: -0.015),
  h4: TypeStep(FontWeight(700), tracking: -0.01),
  label: TypeStep(FontWeight(700)),
);

const pulsoLight = LesenTokens(
  surface: Color(0xFFF6F7FB),
  surfaceMuted: Color(0xFFECEEF7),
  surfaceRaised: Color(0xFFFFFFFF),
  ink: Color(0xFF161A33),
  inkMuted: Color(0xFF4E5373),
  brand: Color(0xFF4A3FD6),
  brandStrong: Color(0xFF3529B0),
  brandSoft: Color(0xFFE6E4FF),
  focus: Color(0xFF0A66C2),
  markSaved: Color(0xFFFFE27A),
  markNew: Color(0xFFD1432C),
  markSentence: Color(0xFFECE9FF),
  onBrand: Color(0xFFFFFFFF),
  tones: [Color(0xFF0F6476), Color(0xFF2E6B45), Color(0xFF8A5300), Color(0xFFA02C5A)],
  displayFont: 'Plus Jakarta Sans',
  readingFont: 'Literata',
  interfaceFont: 'Plus Jakarta Sans',
  typeScale: _type,
  radiusSm: 8,
  radiusMd: 14,
  radiusLg: 20,
  radiusXl: 28,
  radiusCard: 24,
  buttonRadius: 9999,
  chipRadius: 9999,
);

const pulsoDark = LesenTokens(
  surface: Color(0xFF0F1226),
  surfaceMuted: Color(0xFF0A0C1C),
  surfaceRaised: Color(0xFF191D38),
  ink: Color(0xFFEEF0FF),
  inkMuted: Color(0xFFAEB3D4),
  brand: Color(0xFFA49CFF),
  brandStrong: Color(0xFFC6C1FF),
  brandSoft: Color(0xFF2A2560),
  focus: Color(0xFF7CC0FF),
  markSaved: Color(0xFF5B4A12),
  markNew: Color(0xFFFF8A73),
  markSentence: Color(0xFF232650),
  onBrand: Color(0xFF120E3D),
  tones: [Color(0xFF7FD3E3), Color(0xFF8FD6A8), Color(0xFFF2C063), Color(0xFFFF9FC0)],
  displayFont: 'Plus Jakarta Sans',
  readingFont: 'Literata',
  interfaceFont: 'Plus Jakarta Sans',
  typeScale: _type,
  radiusSm: 8,
  radiusMd: 14,
  radiusLg: 20,
  radiusXl: 28,
  radiusCard: 24,
  buttonRadius: 9999,
  chipRadius: 9999,
);

const pulsoReader = {
  ReaderTheme.light: ReaderPalette(
    paper: Color(0xFFFDFCF9),
    ink: Color(0xFF1C1D2A),
    inkMuted: Color(0xFF53556A),
    brand: Color(0xFF4A3FD6),
    saved: Color(0xFFFFE27A),
    sentence: Color(0xFFEEEBFF),
    active: Color(0xFFE6E4FF),
    brightness: Brightness.light,
    tokens: pulsoLight,
  ),
  ReaderTheme.sepia: ReaderPalette(
    paper: Color(0xFFF3EAD8),
    ink: Color(0xFF352A1C),
    inkMuted: Color(0xFF5D4D38),
    brand: Color(0xFF4337C4),
    saved: Color(0xFFEFD58A),
    sentence: Color(0xFFE8DCC2),
    active: Color(0xFFE2DBF0),
    brightness: Brightness.light,
    tokens: pulsoLight,
  ),
  ReaderTheme.dark: ReaderPalette(
    paper: Color(0xFF0C0E1C),
    ink: Color(0xFFE3E5F5),
    inkMuted: Color(0xFFA3A8C8),
    brand: Color(0xFFA49CFF),
    saved: Color(0xFF544411),
    sentence: Color(0xFF1E2146),
    active: Color(0xFF2A2560),
    brightness: Brightness.dark,
    tokens: pulsoDark,
  ),
};
