import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../networking/json.dart';
import 'local_database.dart';
import 'open_database.dart';

/// Documentos JSON pequeños por espacio y clave. No guarda secretos (eso es `SessionStore`).
abstract interface class LocalStore {
  Future<Json?> read(String namespace, String key);
  Future<void> write(String namespace, String key, Json value);
  Future<void> delete(String namespace, String key);
  Future<List<(String, Json)>> all(String namespace);
  Future<void> clearNamespaces(Iterable<String> namespaces);
}

/// En la base local SQLite.
class SqlLocalStore implements LocalStore {
  SqlLocalStore(this._db);

  final LocalDatabase _db;

  @override
  Future<Json?> read(String namespace, String key) async {
    final row = await _db
        .customSelect('SELECT value FROM kv WHERE namespace = ? AND key = ?', variables: [Variable.withString(namespace), Variable.withString(key)])
        .getSingleOrNull();
    if (row == null) return null;
    try {
      return (jsonDecode(row.read<String>('value')) as Map).cast<String, dynamic>();
    } on FormatException {
      return null;
    }
  }

  @override
  Future<void> write(String namespace, String key, Json value) => _db.customStatement(
    'INSERT INTO kv (namespace, key, value, updated_at) VALUES (?, ?, ?, ?) '
    'ON CONFLICT (namespace, key) DO UPDATE SET value = excluded.value, updated_at = excluded.updated_at',
    [namespace, key, jsonEncode(value), DateTime.now().millisecondsSinceEpoch],
  );

  @override
  Future<void> delete(String namespace, String key) => _db.customStatement('DELETE FROM kv WHERE namespace = ? AND key = ?', [namespace, key]);

  @override
  Future<List<(String, Json)>> all(String namespace) async {
    final rows = await _db.customSelect('SELECT key, value FROM kv WHERE namespace = ? ORDER BY key', variables: [Variable.withString(namespace)]).get();
    return [for (final r in rows) (r.read<String>('key'), (jsonDecode(r.read<String>('value')) as Map).cast<String, dynamic>())];
  }

  @override
  Future<void> clearNamespaces(Iterable<String> namespaces) async {
    for (final n in namespaces) {
      await _db.customStatement('DELETE FROM kv WHERE namespace = ?', [n]);
    }
  }
}

/// En memoria: pruebas y la compilación web de desarrollo.
class MemoryLocalStore implements LocalStore {
  final _data = <String, Map<String, String>>{};

  @override
  Future<Json?> read(String namespace, String key) async {
    final raw = _data[namespace]?[key];
    return raw == null ? null : (jsonDecode(raw) as Map).cast<String, dynamic>();
  }

  @override
  Future<void> write(String namespace, String key, Json value) async => (_data[namespace] ??= {})[key] = jsonEncode(value);

  @override
  Future<void> delete(String namespace, String key) async => _data[namespace]?.remove(key);

  @override
  Future<List<(String, Json)>> all(String namespace) async {
    final entries = (_data[namespace] ?? const <String, String>{}).entries.toList()..sort((a, b) => a.key.compareTo(b.key));
    return [for (final e in entries) (e.key, (jsonDecode(e.value) as Map).cast<String, dynamic>())];
  }

  @override
  Future<void> clearNamespaces(Iterable<String> namespaces) async => namespaces.forEach(_data.remove);
}

final localStoreProvider = Provider<LocalStore>((ref) {
  final executor = openLocalExecutor();
  if (executor == null) return MemoryLocalStore();
  final db = LocalDatabase(executor);
  ref.onDispose(db.close);
  return SqlLocalStore(db);
});
