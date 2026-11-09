import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lesen/core/networking/api_failure.dart';
import 'package:lesen/core/storage/local_database.dart';
import 'package:lesen/core/storage/local_store.dart';
import 'package:lesen/core/sync/outbox.dart';

void main() {
  late LocalStore store;
  late List<String> sent;
  late List<Object> script;
  var now = DateTime.utc(2026, 11, 9, 12);

  Outbox outbox() => Outbox(store, {
    't': (p) async {
      final next = script.isEmpty ? null : script.removeAt(0);
      if (next is ApiFailure) throw next;
      sent.add(p['v'].toString());
      return null;
    },
  }, clock: () => now);

  setUpAll(() => driftRuntimeOptions.dontWarnAboutMultipleDatabases = true);

  setUp(() {
    store = SqlLocalStore(LocalDatabase(NativeDatabase.memory()));
    sent = [];
    script = [];
    now = DateTime.utc(2026, 11, 9, 12);
  });

  test('envía en orden y vacía la cola', () async {
    final o = outbox();
    await o.enqueue('t', {'v': 1});
    await o.enqueue('t', {'v': 2});
    await o.flush();
    expect(sent, ['1', '2']);
    expect(await o.all(), isEmpty);
    expect(o.current.pending, 0);
  });

  test('colapsa por clave: solo la última, en el sitio de la primera', () async {
    final o = outbox();
    await o.enqueue('t', {'v': 'a1'}, collapseKey: 'progress:a');
    now = now.add(const Duration(seconds: 1));
    await o.enqueue('t', {'v': 'b'});
    now = now.add(const Duration(seconds: 1));
    await o.enqueue('t', {'v': 'a2'}, collapseKey: 'progress:a');
    expect((await o.all()).length, 2);
    await o.flush();
    expect(sent, ['a2', 'b']);
  });

  test('sin red: espera creciente, no se pierde y se para hasta que vuelva', () async {
    final o = outbox();
    await o.enqueue('t', {'v': 1});
    await o.enqueue('t', {'v': 2});
    script = [const OfflineFailure()];
    await o.flush();
    expect(sent, isEmpty);
    final ops = await o.all();
    expect(ops, hasLength(2));
    expect(ops.first.attempts, 1);
    expect(ops.first.nextAt!.isAfter(now), isTrue);
    // un vaciado normal respeta la espera
    await o.flush();
    expect(sent, isEmpty);
    // al volver la red (forzado) se envía todo
    await o.flush(force: true);
    expect(sent, ['1', '2']);
  });

  test('un rechazo definitivo (4xx) se queda a la vista y no bloquea las demás', () async {
    final o = outbox();
    await o.enqueue('t', {'v': 1});
    await o.enqueue('t', {'v': 2});
    script = [const ValidationFailure('posición no válida', {})];
    await o.flush();
    expect(sent, ['2']);
    expect(o.current.rejected, hasLength(1));
    expect(o.current.rejected.first.error, contains('ValidationFailure'));
    await o.discard(o.current.rejected.first);
    expect(await o.all(), isEmpty);
  });

  test('un 401 detiene la cola hasta volver a entrar', () async {
    final o = outbox();
    await o.enqueue('t', {'v': 1});
    script = [const UnauthorizedFailure()];
    await o.flush();
    expect(await o.all(), hasLength(1));
    await o.flush(force: true);
    expect(sent, isEmpty);
    o.resume();
    await o.flush(force: true);
    expect(sent, ['1']);
  });

  test('sobrevive a reabrir la app (persistente)', () async {
    await outbox().enqueue('t', {'v': 'x'});
    final again = outbox();
    await again.flush();
    expect(sent, ['x']);
  });
}
