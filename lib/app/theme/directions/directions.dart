import 'package:flutter/material.dart';

import '../../../features/reader/domain/reader_preferences.dart';
import '../../../features/reader/presentation/reader_theme.dart';
import '../tokens.dart';
import 'atlas.dart';
import 'gaceta.dart';
import 'musgo.dart';
import 'pulso.dart';

/// Identidades visuales que cada persona elige en su perfil (ADR-0011). [papel] es «Papel y tinta», la clásica
/// (ADR-0008) y los valores por defecto de [LesenTokens]; [musgo] es la de quien no ha elegido.
enum DesignDirection {
  musgo('Musgo'),
  gaceta('Gaceta'),
  pulso('Pulso'),
  atlas('Atlas'),
  papel('Papel y tinta');

  const DesignDirection(this.label);

  /// La identidad de quien todavía no ha elegido.
  static const fallback = DesignDirection.musgo;

  /// Nombre propio de la identidad; no se traduce.
  final String label;

  LesenTokens tokens(Brightness brightness) {
    final light = brightness == Brightness.light;
    return switch (this) {
      papel => light ? LesenTokens.light : LesenTokens.dark,
      gaceta => light ? gacetaLight : gacetaDark,
      pulso => light ? pulsoLight : pulsoDark,
      musgo => light ? musgoLight : musgoDark,
      atlas => light ? atlasLight : atlasDark,
    };
  }

  /// El papel del lector de la identidad; `null` en [papel], que usa el de siempre.
  ReaderPalette? reader(ReaderTheme theme) => switch (this) {
    papel => null,
    gaceta => gacetaReader[theme],
    pulso => pulsoReader[theme],
    musgo => musgoReader[theme],
    atlas => atlasReader[theme],
  };
}
