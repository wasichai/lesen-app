import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../connectivity/connectivity.dart';
import '../networking/api_client.dart';
import '../networking/json.dart';
import '../session/session_controller.dart';
import '../storage/local_store.dart';
import 'outbox.dart';

/// Los tipos de operación de la cola y su llamada a la API: solo rutas y cuerpos, así que `core` no depende
/// de ninguna funcionalidad.
abstract final class Ops {
  static const progress = 'progress';
  static const completion = 'completion';
  static const bookmark = 'bookmark';
  static const saveWord = 'saveWord';
  static const review = 'review';
  static const note = 'note';
  static const attempt = 'attempt';
}

Map<String, Executor> executors(Api api, LocalStore local) {
  String r(Json p) => '/lesen/readings/${Uri.encodeComponent(p.str('slug'))}';
  return {
    Ops.progress: (p) async {
      final j = await api.send('PUT', '${r(p)}/progress', body: p.obj('body'));
      final stored = await local.read('progress', p.str('slug'));
      // solo se marca confirmado si lo guardado sigue siendo lo que se envió
      if (stored != null && stored['percent'] == p.obj('body')['percent'] && stored['position'] == p.obj('body')['position']) {
        await local.write('progress', p.str('slug'), {...stored, 'pending': false});
      }
      return j;
    },
    Ops.completion: (p) => api.send('POST', '${r(p)}/completion', body: p.obj('body')),
    Ops.bookmark: (p) => api.send(p.boolean('value') ? 'PUT' : 'DELETE', '${r(p)}/bookmark'),
    Ops.saveWord: (p) => api.send('POST', '/lesen/vocabulary', body: p.obj('body')),
    Ops.review: (p) => api.send('POST', '/lesen/vocabulary/reviews', body: p.obj('body')),
    Ops.note: (p) => api.send('POST', '${r(p)}/notes', body: p.obj('body')),
    Ops.attempt: (p) async {
      final j = await api.send('POST', '/lesen/assessments/${Uri.encodeComponent(p.str('assessmentId'))}/attempts', body: p.obj('body'));
      // el resultado queda a mano para abrirlo cuando se quiera
      final summary = j?.objOrNull('summary');
      if (summary != null) {
        await local.write('attempts', p.str('assessmentId'), {'attemptId': summary['id'], 'slug': p.str('slug'), 'version': p.integer('version')});
      }
      return j;
    },
  };
}

final outboxProvider = Provider<Outbox>((ref) {
  final outbox = Outbox(ref.watch(localStoreProvider), executors(ref.watch(apiProvider), ref.watch(localStoreProvider)));
  ref.onDispose(outbox.dispose);
  return outbox;
});

final syncStatusProvider = StreamProvider<SyncStatus>((ref) async* {
  final outbox = ref.watch(outboxProvider);
  yield outbox.current;
  yield* outbox.status;
});

/// Cuándo se vacía la cola: al arrancar con sesión, al volver la red, al volver la app a primer plano y cada minuto (las
/// que esperan su turno de reintento se respetan). Un 401 la detiene hasta volver a entrar.
/// Cada cuánto se reintenta lo que espera; `null` en pruebas (sin temporizadores pendientes).
final syncIntervalProvider = Provider<Duration?>((ref) => const Duration(minutes: 1));

final syncTriggersProvider = Provider<void>((ref) {
  final outbox = ref.watch(outboxProvider);
  void flush({bool force = false}) => unawaited(outbox.flush(force: force));

  ref.listen(sessionControllerProvider.select((s) => s.status), (_, status) {
    if (status == SessionStatus.signedIn) {
      outbox.resume();
      flush(force: true);
    } else {
      outbox.pause();
    }
  }, fireImmediately: true);
  ref.listen(onlineProvider, (previous, next) {
    if (previous?.value == false && next.value == true) flush(force: true);
  });
  final lifecycle = AppLifecycleListener(onResume: () => flush(force: true));
  final interval = ref.watch(syncIntervalProvider);
  final timer = interval == null ? null : Timer.periodic(interval, (_) => flush());
  ref.onDispose(() {
    lifecycle.dispose();
    timer?.cancel();
  });
});
