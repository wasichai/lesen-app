import 'package:flutter/services.dart';

import '../theme/explorations/directions.dart';

/// Archivos de cada familia de exploración en `assets/fonts/explore/`, que solo entran en el flavor dev.
const exploreFontFiles = {
  'Fraunces': ['Fraunces.ttf', 'Fraunces-Italic.ttf'],
  'SourceSerif4': ['SourceSerif4.ttf', 'SourceSerif4-Italic.ttf'],
  'IBMPlexSans': ['IBMPlexSans.ttf', 'IBMPlexSans-Italic.ttf'],
  'PlusJakartaSans': ['PlusJakartaSans.ttf', 'PlusJakartaSans-Italic.ttf'],
  'Literata': ['Literata.ttf', 'Literata-Italic.ttf'],
  'Manrope': ['Manrope.ttf'],
  'Geist': ['Geist.ttf', 'Geist-Italic.ttf'],
};

final _loaded = <String>{};

/// Registra las familias que [direction] necesita. [load] lee un asset (por defecto, del bundle); las pruebas leen
/// los archivos del disco. Si un archivo no está (la web o un flavor sin las fuentes), la familia cae en la de reserva.
Future<void> loadExploreFonts(DesignDirection direction, {Future<ByteData> Function(String path)? load}) async {
  final read = load ?? rootBundle.load;
  for (final family in direction.extraFonts) {
    if (_loaded.contains(family)) continue;
    try {
      // se leen antes de dárselos al FontLoader: así un archivo que falta no queda como error sin atender
      final files = await Future.wait([for (final file in exploreFontFiles[family]!) read('assets/fonts/explore/$file')]);
      final loader = FontLoader(family);
      for (final bytes in files) {
        loader.addFont(Future.value(bytes));
      }
      await loader.load();
      _loaded.add(family);
    } catch (_) {
      // sin el archivo se ve la familia de reserva; los colores y las formas cambian igual
    }
  }
}
