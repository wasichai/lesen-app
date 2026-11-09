import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/networking/api_client.dart';
import '../../../core/storage/files.dart';

/// Bytes de una portada (SVG público), por el mismo cliente HTTP que el resto de la app y con copia en el dispositivo,
/// para verla también sin conexión. `null` si no se puede: la tarjeta pinta su composición de respaldo.
final coverBytesProvider = FutureProvider.family<Uint8List?, String>((ref, url) => loadCover(ref, url));

/// La portada desde el dispositivo o la red (y la guarda). La usan el proveedor y las descargas.
Future<Uint8List?> loadCover(Ref ref, String url) async {
  final config = ref.read(appConfigProvider);
  final dir = await ref.read(filesDirProvider.future);
  final file = dir == null ? null : File('${dir.path}/covers/${safeFileName(Uri.parse(url).pathSegments.lastOrNull ?? url)}');
  if (file != null && file.existsSync()) return file.readAsBytes();
  try {
    final response = await ref.read(dioProvider).get<List<int>>(config.resolve(url), options: Options(responseType: ResponseType.bytes));
    final data = response.data;
    if (data == null) return null;
    final bytes = Uint8List.fromList(data);
    if (file != null) {
      await file.parent.create(recursive: true);
      await file.writeAsBytes(bytes, flush: true);
    }
    return bytes;
  } on DioException {
    return null;
  }
}
