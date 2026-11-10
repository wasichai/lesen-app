import 'package:flutter/material.dart';

import '../../../app/theme/explorations/directions.dart';
import '../../../app/theme/theme.dart';
import '../../../app/theme/tokens.dart';
import '../domain/reader_preferences.dart';

/// Colores del papel del lector (`lesen-reader-light|sepia|dark` de la web).
class ReaderPalette {
  const ReaderPalette({
    required this.paper,
    required this.ink,
    required this.inkMuted,
    required this.brand,
    required this.saved,
    required this.sentence,
    required this.active,
    required this.brightness,
    this.tokens,
  });

  /// El papel de [theme] en la dirección de diseño [direction] (por defecto, «Papel y tinta»).
  factory ReaderPalette.of(ReaderTheme theme, {DesignDirection direction = DesignDirection.actual}) => direction.reader(theme) ?? ReaderPalette._paper(theme);

  factory ReaderPalette._paper(ReaderTheme theme) => switch (theme) {
    ReaderTheme.light => const ReaderPalette(
      paper: Color(0xFFFFFDF8),
      ink: Color(0xFF22252E),
      inkMuted: Color(0xFF5C606B),
      brand: Color(0xFFA8402A),
      saved: Color(0xFFF4E2A8),
      sentence: Color(0xFFF6EAD9),
      active: Color(0xFFF6E3D8),
      brightness: Brightness.light,
    ),
    ReaderTheme.sepia => const ReaderPalette(
      paper: Color(0xFFF4ECDD),
      ink: Color(0xFF3A2F22),
      inkMuted: Color(0xFF6B5B47),
      brand: Color(0xFF9A3B25),
      saved: Color(0xFFEBD48F),
      sentence: Color(0xFFEADCC4),
      active: Color(0xFFEBCDBB),
      brightness: Brightness.light,
    ),
    ReaderTheme.dark => const ReaderPalette(
      paper: Color(0xFF121318),
      ink: Color(0xFFE2DCCF),
      inkMuted: Color(0xFFA49D90),
      brand: Color(0xFFF19A7B),
      saved: Color(0xFF4D4220),
      sentence: Color(0xFF2A2620),
      active: Color(0xFF3B241C),
      brightness: Brightness.dark,
    ),
  };

  final Color paper;
  final Color ink;
  final Color inkMuted;
  final Color brand;

  /// Fondo de una palabra guardada.
  final Color saved;

  /// Fondo de la oración seleccionada o hablada.
  final Color sentence;

  /// Fondo de la palabra abierta en el diccionario.
  final Color active;
  final Brightness brightness;

  /// Tokens de la app bajo este papel; sin ellos, los de «Papel y tinta» para [brightness].
  final LesenTokens? tokens;

  /// El tema de la app con el papel del lector, para hojas y controles dentro de la lectura.
  ThemeData theme() {
    final base = buildTheme(brightness, tokens: tokens);
    return base.copyWith(
      scaffoldBackgroundColor: paper,
      colorScheme: base.colorScheme.copyWith(surface: paper, onSurface: ink, primary: brand, onSurfaceVariant: inkMuted),
      appBarTheme: base.appBarTheme.copyWith(backgroundColor: paper, foregroundColor: ink),
    );
  }
}
