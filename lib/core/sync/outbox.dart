import 'dart:async';
import 'dart:math';

import '../networking/api_failure.dart';
import '../networking/json.dart';
import '../storage/local_store.dart';
import '../utilities/ids.dart';

/// Una escritura pendiente de llegar al servidor (ADR-0007, `docs/architecture/offline-strategy.md` §3).
class Operation {
  const Operation({
    required this.id,
    required this.kind,
    required this.payload,
    required this.createdAt,
    this.collapseKey,
    this.attempts = 0,
    this.nextAt,
    this.rejected = false,
    this.error,
  });

  factory Operation.fromJson(Json j) => Operation(
    id: j.str('id'),
    kind: j.str('kind'),
    payload: j.obj('payload'),
    createdAt: DateTime.fromMicrosecondsSinceEpoch(j.integer('createdAt'), isUtc: true),
    collapseKey: j.strOrNull('collapseKey'),
    attempts: j.integerOrNull('attempts') ?? 0,
    nextAt: j['nextAt'] == null ? null : DateTime.fromMicrosecondsSinceEpoch(j.integer('nextAt'), isUtc: true),
    rejected: j.boolean('rejected'),
    error: j.strOrNull('error'),
  );

  final String id;

  /// Qué hace (`progress`, `completion`, `bookmark`, `saveWord`, `review`, `note`, `attempt`).
  final String kind;
  final Json payload;
  final DateTime createdAt;

  /// Las operaciones con la misma clave se colapsan: solo cuenta la última (el progreso de una lectura, su marcador).
  final String? collapseKey;
  final int attempts;
  final DateTime? nextAt;

  /// El servidor la rechazó de forma definitiva (4xx): se muestra, nunca se borra en silencio.
  final bool rejected;
  final String? error;

  String get storageKey => collapseKey == null ? 'op:$id' : 'c:$collapseKey';

  Operation retried(DateTime next, String error) =>
      Operation(id: id, kind: kind, payload: payload, createdAt: createdAt, collapseKey: collapseKey, attempts: attempts + 1, nextAt: next, error: error);

  Operation reject(String error) =>
      Operation(id: id, kind: kind, payload: payload, createdAt: createdAt, collapseKey: collapseKey, attempts: attempts + 1, rejected: true, error: error);

  Json toJson() => {
    'id': id,
    'kind': kind,
    'payload': payload,
    'createdAt': createdAt.microsecondsSinceEpoch,
    'collapseKey': collapseKey,
    'attempts': attempts,
    'nextAt': nextAt?.microsecondsSinceEpoch,
    'rejected': rejected,
    'error': error,
  };
}

/// Lo que hace cada tipo de operación contra la API. Devuelve la respuesta (si interesa a quien encoló).
typedef Executor = Future<Json?> Function(Json payload);

class SyncStatus {
  const SyncStatus({required this.pending, required this.rejected, required this.syncing, this.lastSyncedAt});

  static const idle = SyncStatus(pending: 0, rejected: [], syncing: false);

  final int pending;
  final List<Operation> rejected;
  final bool syncing;
  final DateTime? lastSyncedAt;
}

/// La cola de operaciones: persistente, en orden, con espera exponencial y sin perder nada.
class Outbox {
  Outbox(this._store, this._executors, {DateTime Function()? clock, Random? random}) : _clock = clock ?? DateTime.now, _random = random ?? Random();

  static const namespace = 'outbox';
  static const _maxDelay = Duration(minutes: 5);

  final LocalStore _store;
  final Map<String, Executor> _executors;
  final DateTime Function() _clock;
  final Random _random;
  final _status = StreamController<SyncStatus>.broadcast();
  final _done = StreamController<(Operation, Json?)>.broadcast();
  Future<void>? _flushing;
  bool _paused = false;
  SyncStatus _last = SyncStatus.idle;
  DateTime _lastCreated = DateTime.fromMicrosecondsSinceEpoch(0, isUtc: true);

  Stream<SyncStatus> get status => _status.stream;
  SyncStatus get current => _last;

  /// Cada operación que llega al servidor, con su respuesta.
  Stream<(Operation, Json?)> get completed => _done.stream;

  /// Encola y devuelve la operación. No espera a la red.
  Future<Operation> enqueue(String kind, Json payload, {String? collapseKey}) async {
    // el orden de la cola es el de llegada, aunque dos operaciones caigan en el mismo microsegundo
    var created = _clock().toUtc();
    if (!created.isAfter(_lastCreated)) created = _lastCreated.add(const Duration(microseconds: 1));
    _lastCreated = created;
    final op = Operation(id: uuidV4(), kind: kind, payload: payload, createdAt: created, collapseKey: collapseKey);
    if (collapseKey != null) {
      // la nueva sustituye a la anterior pero conserva su sitio en la cola
      final previous = await _store.read(namespace, op.storageKey);
      final created = previous == null ? op.createdAt : Operation.fromJson(previous).createdAt;
      await _store.write(namespace, op.storageKey, Operation(id: op.id, kind: kind, payload: payload, createdAt: created, collapseKey: collapseKey).toJson());
    } else {
      await _store.write(namespace, op.storageKey, op.toJson());
    }
    await _publish();
    return op;
  }

  Future<List<Operation>> all() async {
    final ops = [for (final (_, j) in await _store.all(namespace)) Operation.fromJson(j)]..sort((a, b) => a.createdAt.compareTo(b.createdAt));
    return ops;
  }

  /// Un 401 detiene la cola hasta volver a entrar; al entrar, se reanuda.
  void pause() => _paused = true;

  void resume() => _paused = false;

  /// Vacía la cola en orden. Si ya se está vaciando, espera a esa vuelta. Con `force`, ignora las esperas
  /// (al volver la red o la app a primer plano).
  Future<void> flush({bool force = false}) => _flushing ??= _run(force).whenComplete(() => _flushing = null);

  Future<void> _run(bool force) async {
    _emit(syncing: true);
    try {
      for (final op in await all()) {
        if (_paused) break;
        if (op.rejected) continue;
        // en orden: si una espera su reintento, las de detrás también (terminar no adelanta al progreso)
        if (!force && op.nextAt != null && op.nextAt!.isAfter(_clock())) break;
        final exec = _executors[op.kind];
        if (exec == null) {
          await _store.write(namespace, op.storageKey, op.reject('tipo desconocido').toJson());
          continue;
        }
        try {
          final response = await exec(op.payload);
          await _removeIfSame(op);
          _done.add((op, response));
        } on ApiFailure catch (e) {
          if (e is UnauthorizedFailure) {
            _paused = true;
            break;
          }
          if (e.isTransient || e is RateLimitedFailure || e is TimeoutFailure) {
            await _store.write(namespace, op.storageKey, op.retried(_clock().add(_backoff(op.attempts)), e.runtimeType.toString()).toJson());
            // sin red no tiene sentido probar las siguientes ahora
            if (e is OfflineFailure || e is TimeoutFailure) break;
          } else {
            await _store.write(namespace, op.storageKey, op.reject('${e.runtimeType}: ${e.detail ?? ''}').toJson());
          }
        }
      }
    } finally {
      await _publish(syncing: false, synced: true);
    }
  }

  /// Si mientras se enviaba llegó una versión más nueva (misma clave de colapso), esa se queda.
  Future<void> _removeIfSame(Operation sent) async {
    final now = await _store.read(namespace, sent.storageKey);
    if (now == null || Operation.fromJson(now).id == sent.id) await _store.delete(namespace, sent.storageKey);
  }

  /// 2 s, 4 s, 8 s… hasta 5 min, con un poco de azar para no sincronizar a la vez.
  Duration _backoff(int attempts) {
    final base = Duration(seconds: 2) * (1 << attempts.clamp(0, 10));
    final capped = base > _maxDelay ? _maxDelay : base;
    return capped + Duration(milliseconds: _random.nextInt(500));
  }

  /// Anula una operación aún no enviada (una nota borrada antes de llegar al servidor).
  Future<void> cancel(String opId) async {
    for (final op in await all()) {
      if (op.id == opId) await _store.delete(namespace, op.storageKey);
    }
    await _publish();
  }

  /// Descarta una operación rechazada (lo decide la persona desde el estado de sincronización).
  Future<void> discard(Operation op) async {
    await _store.delete(namespace, op.storageKey);
    await _publish();
  }

  Future<void> _publish({bool? syncing, bool synced = false}) async {
    final ops = await all();
    _last = SyncStatus(
      pending: ops.where((o) => !o.rejected).length,
      rejected: ops.where((o) => o.rejected).toList(),
      syncing: syncing ?? _last.syncing,
      lastSyncedAt: synced ? _clock() : _last.lastSyncedAt,
    );
    _status.add(_last);
  }

  void _emit({required bool syncing}) {
    _last = SyncStatus(pending: _last.pending, rejected: _last.rejected, syncing: syncing, lastSyncedAt: _last.lastSyncedAt);
    _status.add(_last);
  }

  Future<void> dispose() async {
    await _status.close();
    await _done.close();
  }
}
