import '../networking/api_failure.dart';
import '../networking/json.dart';
import 'local_store.dart';

/// Lecturas de la API con copia en el dispositivo.
extension CachedReads on LocalStore {
  static const ns = 'cache';

  /// Lo inmutable (contenido, traducciones, tiempos de una versión): si está en el dispositivo, no se pide.
  Future<Json> cacheFirst(String key, Future<Json> Function() fetch) async {
    final hit = await read(ns, key);
    if (hit != null) return hit;
    final fresh = await fetch();
    await write(ns, key, fresh);
    return fresh;
  }

  /// Lo que cambia (ficha, biblioteca, preguntas con su último intento): de la red y, sin ella, la última copia.
  Future<Json> networkFirst(String key, Future<Json> Function() fetch) async {
    try {
      final fresh = await fetch();
      await write(ns, key, fresh);
      return fresh;
    } on ApiFailure catch (e) {
      if (!e.isTransient) rethrow;
      final hit = await read(ns, key);
      if (hit == null) rethrow;
      return hit;
    }
  }
}
