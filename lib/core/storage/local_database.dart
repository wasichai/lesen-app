import 'package:drift/drift.dart';

/// Base local (ADR-0005, ADR-0009): drift sobre SQLite, sin generación de código, con SQL y valores ligados.
/// Cada versión del esquema es una migración aditiva en [_migrations]; nunca se edita una ya publicada.
class LocalDatabase extends GeneratedDatabase {
  LocalDatabase(super.executor);

  static final _migrations = <int, List<String>>{
    1: [
      // documentos JSON por clave: preferencias, progreso local, cachés pequeñas
      'CREATE TABLE kv (namespace TEXT NOT NULL, key TEXT NOT NULL, value TEXT NOT NULL, updated_at INTEGER NOT NULL, PRIMARY KEY (namespace, key))',
    ],
  };

  @override
  Iterable<TableInfo<Table, dynamic>> get allTables => const [];

  @override
  int get schemaVersion => _migrations.keys.reduce((a, b) => a > b ? a : b);

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      for (var v = 1; v <= schemaVersion; v++) {
        await _apply(v);
      }
    },
    onUpgrade: (m, from, to) async {
      for (var v = from + 1; v <= to; v++) {
        await _apply(v);
      }
    },
  );

  Future<void> _apply(int version) async {
    for (final sql in _migrations[version] ?? const <String>[]) {
      await customStatement(sql);
    }
  }
}
