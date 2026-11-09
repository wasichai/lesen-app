import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:lesen/app/routing/router.dart';
import 'package:lesen/app/routing/routes.dart';
import 'package:lesen/core/session/session_store.dart';
import 'package:lesen/core/storage/local_store.dart';
import 'package:lesen/features/reader/application/reading_tracker.dart';
import 'package:lesen/features/reader/data/reader_repository.dart';
import 'package:lesen/features/reader/presentation/reader_screen.dart';

import '../support/fake_backend.dart';
import '../support/harness.dart';

const slug = 'der-alte-leuchtturm';

Map<String, Handler> profileRoute() => {
  'GET /lesen/learner/profile': (_) => {
    'interfaceLanguage': 'es',
    'targetLanguage': 'de',
    'level': 'A2',
    'levelEstimated': false,
    'goals': <String>[],
    'topics': <String>[],
    'dailyMinutes': 10,
    'difficulty': 'BALANCED',
  },
};

Future<void> openReader(WidgetTester tester, FakeBackend backend, {LocalStore? local, Size size = const Size(390, 844)}) async {
  final container = await pumpLesenApp(tester, backend, store: MemorySessionStore(testSession()), local: local, size: size);
  container.read(routerProvider).go(Routes.reader(slug));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('tocar una palabra abre su entrada y guardarla la manda al cuaderno con su contexto', (tester) async {
    final backend = FakeBackend({...profileRoute(), ...FakeBackend.readingRoutes(slug)});
    await openReader(tester, backend);
    expect(find.byType(ReaderScreen), findsOneWidget);
    expect(find.text('Der alte Leuchtturm'), findsWidgets);

    await tester.tapOnText(find.textRange.ofSubstring('verbringt'));
    await tester.pumpAndSettle();
    expect(find.text('pasar (tiempo)'), findsOneWidget);
    expect(find.text('«verbringt» es una forma de «verbringen».'), findsOneWidget);

    await tester.tap(find.text('Guardar en mi vocabulario'));
    await tester.pumpAndSettle();
    final post = backend.requests.lastWhere((r) => r.method == 'POST' && r.path == '/lesen/vocabulary');
    expect(post.data, {'entryKey': 'de:verbringen', 'reading': slug, 'version': 1, 'tokenRef': 'p1s1t2'});
    expect(find.text('En tu vocabulario'), findsOneWidget);

    // traducir la oración, a demanda
    await tester.ensureVisible(find.text('Traducir la oración'));
    await tester.tap(find.text('Traducir la oración'));
    await tester.pumpAndSettle();
    expect(find.text('Mia pasa el verano con su abuelo junto al mar del Norte.'), findsOneWidget);
  });

  testWidgets('una palabra sin entrada lo dice, sin inventar', (tester) async {
    final routes = {...profileRoute(), ...FakeBackend.readingRoutes(slug)};
    final lookup = routes['GET /lesen/dictionary/lookup']!;
    routes['GET /lesen/dictionary/lookup'] = (r) => {...(lookup(r)! as Map<String, dynamic>), 'entry': null};
    await openReader(tester, FakeBackend(routes));
    await tester.tapOnText(find.textRange.ofSubstring('Sommer'));
    await tester.pumpAndSettle();
    expect(find.text('Todavía no tenemos esta palabra en el diccionario.'), findsOneWidget);
    expect(find.text('Guardar en mi vocabulario'), findsNothing);
  });

  testWidgets('en tableta ancha, el diccionario va en un panel al lado del texto', (tester) async {
    await openReader(tester, FakeBackend({...profileRoute(), ...FakeBackend.readingRoutes(slug)}), size: const Size(1200, 820));
    await tester.tapOnText(find.textRange.ofSubstring('verbringt'));
    await tester.pumpAndSettle();
    expect(find.byType(BottomSheet), findsNothing);
    expect(find.text('pasar (tiempo)'), findsOneWidget);
    await tester.tap(find.byTooltip('Cerrar'));
    await tester.pumpAndSettle();
    expect(find.text('pasar (tiempo)'), findsNothing);
  });

  testWidgets('la traducción del párrafo aparece a demanda', (tester) async {
    await openReader(tester, FakeBackend({...profileRoute(), ...FakeBackend.readingRoutes(slug)}));
    await tester.ensureVisible(find.text('Traducir el párrafo').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Traducir el párrafo').first);
    await tester.pumpAndSettle();
    expect(find.textContaining('Mia pasa el verano'), findsOneWidget);
    await closeApp(tester);
  });

  testWidgets('al salir se guarda el progreso; sin red, queda pendiente en el dispositivo', (tester) async {
    final routes = {...profileRoute(), ...FakeBackend.readingRoutes(slug)};
    routes['PUT /lesen/readings/$slug/progress'] = (_) => const Reply(503);
    final local = MemoryLocalStore();
    await openReader(tester, FakeBackend(routes), local: local);
    await tester.drag(find.byType(ListView), const Offset(0, -1500));
    await tester.pumpAndSettle(const Duration(seconds: 2));
    final router = GoRouter.of(tester.element(find.byType(ReaderScreen)));
    router.go(Routes.discover);
    await tester.pumpAndSettle(const Duration(seconds: 2));
    final saved = await local.read(ReaderRepository.progressNs, slug);
    expect(saved, isNotNull);
    expect(saved!['pending'], isTrue);
    expect(saved['position'], isNot('p1s1'));
    expect((saved['percent'] as int) > 0, isTrue);
  });

  testWidgets('al volver, se abre en la oración donde se quedó', (tester) async {
    final local = MemoryLocalStore();
    await local.write(ReaderRepository.progressNs, slug, {
      'version': 1,
      'position': 'p5s1',
      'percent': 70,
      'secondsRead': 40,
      'completed': false,
      'updatedAt': DateTime.now().toUtc().toIso8601String(),
      'pending': false,
    });
    await openReader(tester, FakeBackend({...profileRoute(), ...FakeBackend.readingRoutes(slug)}), local: local);
    final scrollable = tester.state<ScrollableState>(find.byType(Scrollable).first);
    expect(scrollable.position.pixels, greaterThan(200));
    expect(find.text('Quedan 1 min'), findsOneWidget);
    await closeApp(tester);
  });

  test('el rastreador nunca baja el porcentaje y guarda con pausa', () async {
    final backend = FakeBackend({...FakeBackend.readingRoutes(slug)});
    final container = createContainerForTest(backend);
    final repo = container.read(readerRepositoryProvider);
    final content = await repo.content(slug, 1);
    final tracker = ReadingTracker(repository: repo, content: content, initial: null, debounce: const Duration(milliseconds: 10))..resume();
    tracker.moveTo('p4s1');
    final high = tracker.percent;
    tracker.moveTo('p1s1');
    expect(tracker.percent, high);
    await Future<void>.delayed(const Duration(milliseconds: 50));
    expect(backend.count('PUT /lesen/readings/$slug/progress'), 1);
    expect(backend.requests.last.data, containsPair('position', 'p1s1'));
    tracker.dispose();
  });
}
