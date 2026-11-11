import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/storage/public_files.dart';

/// Carpeta del dispositivo donde se guardan las ilustraciones de los textos (ADR-0018 del backend).
const illustrationsFolder = 'illustrations';

/// Bytes de una ilustración entre párrafos, desde el dispositivo (descargada o ya vista) o la red. `null` si no se
/// puede: el lector lo dice, no inventa una imagen.
final illustrationBytesProvider = FutureProvider.family<Uint8List?, String>((ref, url) => loadPublicFile(ref, url, illustrationsFolder));
