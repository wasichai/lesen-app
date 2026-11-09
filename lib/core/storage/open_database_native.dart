import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';

/// El archivo `lesen.sqlite` en el directorio de soporte de la app (no se respalda como documento de usuario).
QueryExecutor? openLocalExecutor() => LazyDatabase(() async {
  final dir = await getApplicationSupportDirectory();
  return NativeDatabase.createInBackground(File('${dir.path}/lesen.sqlite'));
});
