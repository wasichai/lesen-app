import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../networking/api_client.dart';
import 'files.dart';

/// Dónde guarda el dispositivo un archivo público (portada, ilustración) de una URL: `<soporte>/<carpeta>/<nombre>`.
/// `null` donde no hay almacenamiento (la web de desarrollo).
Future<File?> publicFileFor(Ref ref, String url, String folder) async {
  final dir = await ref.read(filesDirProvider.future);
  if (dir == null) return null;
  return File('${dir.path}/$folder/${safeFileName(Uri.parse(url).pathSegments.lastOrNull ?? url)}');
}

/// Un archivo público e inmutable desde el dispositivo o, si no está, desde la red por el mismo cliente HTTP que el resto
/// de la app (y se guarda, para verlo también sin conexión). `null` si no se puede: quien lo pinta lo dice.
Future<Uint8List?> loadPublicFile(Ref ref, String url, String folder) async {
  final file = await publicFileFor(ref, url, folder);
  if (file != null && file.existsSync()) return file.readAsBytes();
  try {
    final response = await ref.read(dioProvider).get<List<int>>(ref.read(appConfigProvider).resolve(url), options: Options(responseType: ResponseType.bytes));
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

/// Si unos bytes son un SVG (las ilustraciones de la demostración lo son; las subidas, PNG, JPEG o WebP).
bool isSvg(Uint8List bytes) {
  final head = String.fromCharCodes(bytes.take(256)).trimLeft();
  return head.startsWith('<svg') || head.startsWith('<?xml');
}
