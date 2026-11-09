import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';

/// El directorio de soporte de la app (no es de documentos del usuario ni se comparte); `null` en la web de desarrollo,
/// donde no hay descargas.
final filesDirProvider = FutureProvider<Directory?>((ref) async {
  if (kIsWeb) return null;
  return getApplicationSupportDirectory();
});

/// Un nombre de archivo seguro a partir de una clave (`der-alte-leuchtturm@1`).
String safeFileName(String key) => key.replaceAll(RegExp(r'[^a-zA-Z0-9@._-]'), '_');
