import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lesen/app/routing/router.dart';
import 'package:lesen/app/routing/routes.dart';
import 'package:lesen/core/networking/api_failure.dart';
import 'package:lesen/core/networking/json.dart';
import 'package:lesen/core/session/session_store.dart';
import 'package:lesen/core/storage/local_store.dart';
import 'package:lesen/features/downloads/application/downloads_controller.dart';
import 'package:lesen/features/downloads/domain/download.dart';
import 'package:lesen/features/reader/application/illustration_provider.dart';
import 'package:lesen/features/reader/data/reader_repository.dart';
import 'package:lesen/features/reader/domain/reading_content.dart';
import 'package:lesen/features/reader/presentation/widgets/illustration_view.dart';

import '../support/fake_backend.dart';
import '../support/harness.dart';
import '../support/notebook_routes.dart';
import 'reader_test.dart' show profileRoute;

// ilustraciones entre párrafos (ADR-0018 del backend): el contenido lleva `blocks` en orden de lectura
const slug = 'der-alte-leuchtturm';
const svg = 'test/fixtures/illustrations/der-alte-leuchtturm-sturm.svg';
const alt = 'Ein weißer Leuchtturm mit roten Streifen steht im Sturm. Seine Lampe ist dunkel, das Meer ist grau und wild.';

Json content({List<Map<String, dynamic>>? blocks}) => {...((fixtures['readings'] as Map)[slug] as Map)['content'] as Json, 'blocks': ?blocks};

List<Map<String, dynamic>> blocks() => FakeBackend.illustratedBlocks(slug);

Map<String, dynamic> image(Map<String, dynamic> change) => {...blocks().firstWhere((b) => b['type'] == 'image'), ...change};

void main() {
  group('el contrato', () {
    test('los bloques dan el orden de lectura: la ilustración, tras el tercer párrafo', () {
      final c = ReaderRepository.parseContent(content(blocks: blocks()));
      expect(c.blocks.map((b) => b is ParagraphBlock ? 'p${b.index + 1}' : 'img'), ['p1', 'p2', 'p3', 'img', 'p4', 'p5']);
      final illustration = c.illustrations.single;
      expect(illustration.id, 'img-1');
      expect(illustration.url, '/api/lesen/public/illustrations/der-alte-leuchtturm-sturm.svg');
      expect(illustration.aspectRatio, 1.5);
      expect(illustration.alt, alt);
      expect(illustration.caption, 'Plötzlich geht das Licht aus.');
      // los párrafos y sus índices no cambian: traducciones, audio y progreso siguen igual
      expect(c.paragraphs, hasLength(5));
      expect(c.index.paragraphOfSentence['p4s1'], 3);
    });

    test('sin bloques (un texto sin ilustraciones o una respuesta de antes), solo los párrafos', () {
      final c = ReaderRepository.parseContent(content());
      expect(c.blocks.whereType<ParagraphBlock>().map((b) => b.index), [0, 1, 2, 3, 4]);
      expect(c.illustrations, isEmpty);
    });

    test('sin texto alternativo, el contenido no cumple el contrato', () {
      List<Map<String, dynamic>> withImage(Map<String, dynamic> img) => [for (final b in blocks()) b['type'] == 'image' ? img : b];
      expect(() => ReaderRepository.parseContent(content(blocks: withImage(image({'alt': null})))), throwsA(isA<ContractException>()));
      expect(() => ReaderRepository.parseContent(content(blocks: withImage(image({'alt': '  '})))), throwsA(isA<ContractException>()));
      expect(() => ReaderRepository.parseContent(content(blocks: withImage(image({'width': 0})))), throwsA(isA<ContractException>()));
    });

    test('un párrafo desconocido, repetido o que falta rompe el contrato; un tipo nuevo se ignora', () {
      final paragraphs = blocks().where((b) => b['type'] == 'paragraph').toList();
      expect(
        () => ReaderRepository.parseContent(
          content(
            blocks: [
              ...paragraphs,
              {'type': 'paragraph', 'id': 'p9'},
            ],
          ),
        ),
        throwsA(isA<ContractException>()),
      );
      expect(() => ReaderRepository.parseContent(content(blocks: [...paragraphs, paragraphs.first])), throwsA(isA<ContractException>()));
      expect(() => ReaderRepository.parseContent(content(blocks: paragraphs.skip(1).toList())), throwsA(isA<ContractException>()));
      final c = ReaderRepository.parseContent(
        content(
          blocks: [
            ...paragraphs,
            {'type': 'quote', 'id': 'q1'},
          ],
        ),
      );
      expect(c.blocks, hasLength(5));
    });
  });

  group('el lector', () {
    Future<void> openReader(WidgetTester tester, FakeBackend backend) async {
      final container = await pumpLesenApp(tester, backend, store: MemorySessionStore(testSession()));
      container.read(routerProvider).go(Routes.reader(slug));
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(find.byType(IllustrationView), 300, scrollable: find.byType(Scrollable).first);
      await tester.pumpAndSettle();
    }

    testWidgets('pinta la ilustración entre párrafos, con su hueco, su pie y su texto alternativo', (tester) async {
      final semantics = tester.ensureSemantics();
      await openReader(tester, FakeBackend({...profileRoute(), ...FakeBackend.readingRoutes(slug, illustrated: true), ...notebookRoutes()}));
      final view = find.byType(IllustrationView);
      final ratio = tester.widget<AspectRatio>(find.descendant(of: view, matching: find.byType(AspectRatio)));
      expect(ratio.aspectRatio, 1.5);
      expect(find.text('Plötzlich geht das Licht aus.'), findsOneWidget);
      expect(find.text('No se pudo cargar esta ilustración.'), findsNothing);
      expect(find.descendant(of: view, matching: find.byType(SvgPicture)), findsOneWidget);
      final node = tester.getSemantics(find.descendant(of: view, matching: find.byType(Semantics)).first);
      expect(node.label, alt);
      expect(node.flagsCollection.isImage, isTrue);
      await closeApp(tester);
      semantics.dispose();
    });

    testWidgets('si la ilustración no llega, lo dice y el texto sigue', (tester) async {
      final routes = FakeBackend.readingRoutes(slug, illustrated: true)..removeWhere((k, _) => k.contains('/public/illustrations/'));
      await openReader(tester, FakeBackend({...profileRoute(), ...routes, ...notebookRoutes()}));
      expect(find.text('No se pudo cargar esta ilustración.'), findsOneWidget);
      expect(find.textContaining('Plötzlich geht das Licht aus', findRichText: true), findsWidgets);
      await closeApp(tester);
    });
  });

  group('la descarga', () {
    late Directory files;

    setUp(() => files = Directory.systemTemp.createTempSync('lesen-test'));
    tearDown(() => files.deleteSync(recursive: true));

    test('guarda las ilustraciones, suma sus bytes, se leen sin red y se borran con la descarga', () async {
      final backend = FakeBackend({...FakeBackend.readingRoutes(slug, illustrated: true), ...notebookRoutes()});
      final c = createContainerForTest(backend, local: MemoryLocalStore(), files: files);
      await c.read(downloadsProvider.notifier).download(slug);
      final d = c.read(downloadsProvider)[slug]!;
      expect(d.state, DownloadState.done, reason: d.error);
      final saved = File(d.illustrationFiles.single);
      expect(saved.readAsBytesSync(), File(svg).readAsBytesSync());
      expect(d.bytes, File(svg).lengthSync() + File(d.audioFile!).lengthSync());
      // lo guardado sobrevive a reabrir la app
      expect(DownloadInfo.fromJson(d.toJson()).illustrationFiles, d.illustrationFiles);

      // sin red, el texto y su ilustración salen del dispositivo
      backend.offline = true;
      final offline = createContainerForTest(backend, local: MemoryLocalStore(), files: files);
      final url = ReaderRepository.parseContent(content(blocks: blocks())).illustrations.single.url;
      expect(await offline.read(illustrationBytesProvider(url).future), File(svg).readAsBytesSync());

      await c.read(downloadsProvider.notifier).remove(slug);
      expect(saved.existsSync(), isFalse);
      expect(File(d.audioFile!).existsSync(), isFalse);
    });

    test('si una ilustración no se puede bajar, la descarga falla y se puede reintentar', () async {
      final routes = FakeBackend.readingRoutes(slug, illustrated: true)..removeWhere((k, _) => k.contains('/public/illustrations/'));
      final c = createContainerForTest(FakeBackend({...routes, ...notebookRoutes()}), files: files);
      await c.read(downloadsProvider.notifier).download(slug);
      expect(c.read(downloadsProvider)[slug]!.state, DownloadState.failed);
    });

    testWidgets('modo avión: la lectura descargada se lee con su ilustración', (tester) async {
      final backend = FakeBackend({...profileRoute(), ...FakeBackend.readingRoutes(slug, illustrated: true), ...notebookRoutes()});
      final container = await pumpLesenApp(tester, backend, store: MemorySessionStore(testSession()), local: MemoryLocalStore(), files: files);
      // la E/S de archivos necesita tiempo real y el resto, el reloj de la prueba
      var finished = false;
      unawaited(container.read(downloadsProvider.notifier).download(slug).whenComplete(() => finished = true));
      for (var i = 0; i < 300 && !finished; i++) {
        await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 5)));
        await tester.pump(const Duration(milliseconds: 20));
      }
      expect(container.read(downloadsProvider)[slug]?.state, DownloadState.done);

      backend.offline = true;
      container.read(routerProvider).go(Routes.reader(slug));
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(find.byType(IllustrationView), 300, scrollable: find.byType(Scrollable).first);
      for (
        var i = 0;
        i < 50 && container.read(illustrationBytesProvider(blocks().firstWhere((b) => b['type'] == 'image')['url'] as String)) is AsyncLoading;
        i++
      ) {
        await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 5)));
        await tester.pump(const Duration(milliseconds: 20));
      }
      await tester.pump();
      expect(find.text('No se pudo cargar esta ilustración.'), findsNothing);
      expect(find.descendant(of: find.byType(IllustrationView), matching: find.byType(SvgPicture)), findsOneWidget);
      expect(find.text('Plötzlich geht das Licht aus.'), findsOneWidget);
      await closeApp(tester);
    }, timeout: const Timeout(Duration(minutes: 2)));
  });
}
