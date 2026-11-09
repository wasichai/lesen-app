import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/networking/api_client.dart';

/// Bytes de una portada (SVG público e inmutable de 7 días), por el mismo cliente HTTP que el resto de la app.
/// `null` si no se puede cargar: la tarjeta pinta su composición de respaldo. Se queda en memoria durante la sesión de la
/// app (unos KB por portada); la caché en disco llega con las descargas (fase 5).
final coverBytesProvider = FutureProvider.family<Uint8List?, String>((ref, url) async {
  final config = ref.watch(appConfigProvider);
  try {
    final response = await ref.watch(dioProvider).get<List<int>>(config.resolve(url), options: Options(responseType: ResponseType.bytes));
    final data = response.data;
    return data == null ? null : Uint8List.fromList(data);
  } on DioException {
    return null;
  }
});
