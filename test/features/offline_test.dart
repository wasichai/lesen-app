import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lesen/app/routing/router.dart';
import 'package:lesen/app/routing/routes.dart';
import 'package:lesen/core/audio/narration_engine.dart';
import 'package:lesen/core/session/session_store.dart';
import 'package:lesen/core/storage/local_store.dart';
import 'package:lesen/core/sync/sync.dart';
import 'package:lesen/features/downloads/application/downloads_controller.dart';
import 'package:lesen/features/downloads/domain/download.dart';
import 'package:lesen/features/reader/data/reader_repository.dart';
import 'package:lesen/features/reader/presentation/reader_screen.dart';

import '../support/fake_backend.dart';
import '../support/harness.dart';
import '../support/notebook_routes.dart';
import 'reader_test.dart' show profileRoute;

const slug = 'der-alte-leuchtturm';

void main() {
  late Directory files;

  setUp(() => files = Directory.systemTemp.createTempSync('lesen-test'));
  tearDown(() => files.deleteSync(recursive: true));

  test('descargar guarda texto, traducciones, preguntas y el audio en el dispositivo', () async {
    final backend = FakeBackend({...FakeBackend.readingRoutes(slug), ...notebookRoutes()});
    final local = MemoryLocalStore();
    final c = createContainerForTest(backend, local: local, files: files);
    await c.read(downloadsProvider.notifier).download(slug);
    final d = c.read(downloadsProvider)[slug]!;
    expect(d.state, DownloadState.done, reason: d.error);
    expect(File(d.audioFile!).lengthSync(), File('test/fixtures/audio/$slug.mp3').lengthSync());
    expect(d.bytes, greaterThan(100000));
    expect(c.read(downloadsProvider.notifier).localAudio(slug, 1), d.audioFile);

    // sin red, todo lo de la versión sale del dispositivo
    backend.offline = true;
    final repo = c.read(readerRepositoryProvider);
    expect((await repo.content(slug, 1)).paragraphs, hasLength(5));
    expect(await repo.translations(slug, 1, TranslationUnit.SENTENCE), containsPair('p1s1', 'Mia pasa el verano con su abuelo junto al mar del Norte.'));

    await c.read(downloadsProvider.notifier).remove(slug);
    expect(File(d.audioFile!).existsSync(), isFalse);
  });

  test('con «solo Wi-Fi» y datos móviles, el texto se descarga y el audio espera', () async {
    final c = createContainerForTest(FakeBackend({...FakeBackend.readingRoutes(slug), ...notebookRoutes()}), files: files, wifi: false);
    await c.read(downloadsProvider.notifier).download(slug);
    final d = c.read(downloadsProvider)[slug]!;
    expect(d.state, DownloadState.waitingWifi);
    expect(d.readableOffline, isTrue);
    expect(d.audioFile, isNull);
  });

  testWidgets('modo avión: leer lo descargado, avanzar y sincronizar al volver la red', (tester) async {
    final backend = FakeBackend({...profileRoute(), ...FakeBackend.readingRoutes(slug), ...notebookRoutes()});
    final local = MemoryLocalStore();
    final engine = FakeNarrationEngine();
    final container = await pumpLesenApp(tester, backend, store: MemorySessionStore(testSession()), local: local, engine: engine, files: files);

    // 18. descargar otra lectura: la E/S de archivos necesita tiempo real y el resto, el reloj de la prueba
    var finished = false;
    unawaited(container.read(downloadsProvider.notifier).download(slug).whenComplete(() => finished = true));
    for (var i = 0; i < 300 && !finished; i++) {
      await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 5)));
      await tester.pump(const Duration(milliseconds: 20));
    }
    expect(container.read(downloadsProvider)[slug]?.readableOffline, isTrue);

    // 19–20. modo avión y leer
    backend.offline = true;
    container.read(routerProvider).go(Routes.reader(slug));
    await tester.pumpAndSettle();
    expect(find.byType(ReaderScreen), findsOneWidget);
    expect(find.textContaining('Mia verbringt', findRichText: true), findsWidgets);
    // el audio descargado se reproduce desde el archivo
    expect(engine.loaded?.scheme, 'file');

    // 21. avanzar sin red: el progreso queda en el dispositivo y en la cola
    await tester.drag(find.byType(ListView), const Offset(0, -1500));
    await tester.pumpAndSettle(const Duration(seconds: 2));
    container.read(routerProvider).go(Routes.library);
    await tester.pumpAndSettle(const Duration(seconds: 2));
    final saved = await local.read(ReaderRepository.progressNs, slug);
    expect(saved!['pending'], isTrue);
    expect(container.read(outboxProvider).current.pending, greaterThan(0));
    expect(backend.count('PUT /lesen/readings/$slug/progress'), 0);

    // 22–23. vuelve la red y se sincroniza
    backend.offline = false;
    unawaited(container.read(outboxProvider).flush(force: true));
    await tester.pumpAndSettle(const Duration(milliseconds: 100));
    expect(backend.count('PUT /lesen/readings/$slug/progress'), 1);
    final put = backend.requests.lastWhere((r) => r.method == 'PUT' && r.path.endsWith('/progress'));
    expect((put.data as Map)['position'], saved['position']);
    expect(container.read(outboxProvider).current.pending, 0);
    expect((await local.read(ReaderRepository.progressNs, slug))!['pending'], isFalse);
    await closeApp(tester);
  }, timeout: const Timeout(Duration(minutes: 2)));

  testWidgets('responder las preguntas sin red las guarda para enviarlas al volver', (tester) async {
    final backend = FakeBackend({...profileRoute(), ...FakeBackend.readingRoutes(slug), ...notebookRoutes()});
    final local = MemoryLocalStore();
    final container = await pumpLesenApp(tester, backend, store: MemorySessionStore(testSession()), local: local);
    // primero con red, para tener las preguntas en el dispositivo
    container.read(routerProvider).go(Routes.quiz(slug, 1));
    await tester.pumpAndSettle();
    backend.offline = true;
    await tester.tap(find.text('Porque la lámpara funciona automáticamente'));
    for (var i = 0; i < 6; i++) {
      await tester.tap(find.text('Siguiente'));
      await tester.pumpAndSettle();
    }
    await tester.tap(find.text('Enviar respuestas'));
    await tester.pumpAndSettle();
    await tester.tap(find.descendant(of: find.byType(AlertDialog), matching: find.text('Enviar respuestas')));
    await tester.pumpAndSettle();
    expect(find.text('Respuestas guardadas'), findsOneWidget);
    expect(find.textContaining('Pendiente de evaluar'), findsOneWidget);

    backend.offline = false;
    unawaited(container.read(outboxProvider).flush(force: true));
    await tester.pumpAndSettle(const Duration(milliseconds: 100));
    expect(backend.requests.where((r) => r.method == 'POST' && r.path.endsWith('/attempts')), isNotEmpty);
    final stored = await local.read('attempts', assessmentFixture['id'] as String);
    expect(stored!['attemptId'], (attemptFixture['summary'] as Map)['id']);
  });
}
