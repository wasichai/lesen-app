import 'dart:io';

/// Familias del bloque `fonts:` de `pubspec.yaml` con sus archivos, para comprobarlas y cargarlas en las pruebas.
final Map<String, List<String>> pubspecFonts = () {
  final families = <String, List<String>>{};
  String? family;
  for (final line in File('pubspec.yaml').readAsLinesSync()) {
    final f = RegExp(r'^\s+- family: (.+)$').firstMatch(line);
    final a = RegExp(r'^\s+- asset: (.+)$').firstMatch(line);
    if (f != null) family = f.group(1)!.trim();
    if (a != null && family != null) (families[family] ??= []).add(a.group(1)!.trim());
  }
  return families;
}();
