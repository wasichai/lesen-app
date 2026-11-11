import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/storage/public_files.dart';

/// Bytes de una portada (SVG público), por el mismo cliente HTTP que el resto de la app y con copia en el dispositivo,
/// para verla también sin conexión. `null` si no se puede: la tarjeta pinta su composición de respaldo.
final coverBytesProvider = FutureProvider.family<Uint8List?, String>((ref, url) => loadCover(ref, url));

/// La portada desde el dispositivo o la red (y la guarda). La usan el proveedor y las descargas.
Future<Uint8List?> loadCover(Ref ref, String url) => loadPublicFile(ref, url, 'covers');
