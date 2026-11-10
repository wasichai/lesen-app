import 'package:flutter/material.dart';

import '../../../features/reader/domain/reader_preferences.dart';
import '../../../features/reader/presentation/reader_theme.dart';
import '../tokens.dart';
import 'atlas.dart';
import 'gaceta.dart';
import 'musgo.dart';
import 'pulso.dart';

/// Direcciones de diseño del laboratorio (docs/design/README.md). [actual] es «Papel y tinta», la identidad de la app;
/// las demás son exploraciones que solo se ven en desarrollo.
enum DesignDirection {
  actual('Papel y tinta'),
  gaceta('Gaceta'),
  pulso('Pulso'),
  musgo('Musgo'),
  atlas('Atlas');

  const DesignDirection(this.label);

  /// Nombre propio de la dirección; no se traduce.
  final String label;

  LesenTokens tokens(Brightness brightness) {
    final light = brightness == Brightness.light;
    return switch (this) {
      actual => light ? LesenTokens.light : LesenTokens.dark,
      gaceta => light ? gacetaLight : gacetaDark,
      pulso => light ? pulsoLight : pulsoDark,
      musgo => light ? musgoLight : musgoDark,
      atlas => light ? atlasLight : atlasDark,
    };
  }

  /// El papel del lector de la dirección; `null` en [actual], que usa el de siempre.
  ReaderPalette? reader(ReaderTheme theme) => switch (this) {
    actual => null,
    gaceta => gacetaReader[theme],
    pulso => pulsoReader[theme],
    musgo => musgoReader[theme],
    atlas => atlasReader[theme],
  };

  /// Familias que la dirección necesita y la app no trae de serie.
  Set<String> get extraFonts {
    final t = tokens(Brightness.light);
    return {t.displayFont, t.readingFont, t.interfaceFont}.difference(bundledFonts);
  }
}

/// Familias declaradas en `pubspec.yaml` (`fonts:`), presentes en todas las compilaciones.
const bundledFonts = {'Newsreader', 'SourceSans3'};
