import 'package:flutter_test/flutter_test.dart';
import 'package:lesen/app/routing/router.dart';
import 'package:lesen/app/routing/routes.dart';
import 'package:lesen/core/audio/narration_engine.dart';
import 'package:lesen/core/networking/json.dart';
import 'package:lesen/core/session/session_store.dart';
import 'package:lesen/features/audio/data/audio_repository.dart';
import 'package:lesen/features/audio/presentation/mini_player.dart';
import 'package:lesen/features/audio/presentation/reader_audio_bar.dart';
import 'package:lesen/features/reader/presentation/widgets/paragraph_view.dart';

import '../support/fake_backend.dart';
import '../support/harness.dart';
import 'reader_test.dart' show profileRoute;

const slug = 'der-alte-leuchtturm';

void main() {
  final asset = AudioRepository.parseAsset(((((fixtures['readings'] as Map)[slug] as Map)['audio'] as Map)['assets'] as List).first as Json);

  Future<(FakeNarrationEngine, dynamic)> open(WidgetTester tester, {Map<String, Handler> extra = const {}}) async {
    final engine = FakeNarrationEngine();
    final container = await pumpLesenApp(
      tester,
      FakeBackend({...profileRoute(), ...FakeBackend.readingRoutes(slug), ...extra}),
      store: MemorySessionStore(testSession()),
      engine: engine,
    );
    container.read(routerProvider).go(Routes.reader(slug));
    await tester.pumpAndSettle();
    return (engine, container);
  }

  testWidgets('con narración, la barra de audio; al avanzar, solo se reconstruye el párrafo que suena', (tester) async {
    final (engine, _) = await open(tester);
    expect(find.byType(ReaderAudioBar), findsOneWidget);
    expect(engine.loaded, isNotNull);

    await tester.tap(find.byTooltip('Escuchar'));
    await tester.pump();
    expect(engine.playing, isTrue);

    // tres palabras seguidas del primer párrafo
    ParagraphViewState.builds = 0;
    for (final w in [asset.words[1], asset.words[2], asset.words[3]]) {
      engine.advanceTo(Duration(milliseconds: w.startMs + 10));
      await tester.pump();
    }
    // una reconstrucción por cambio de palabra, nunca las de todo el documento
    expect(ParagraphViewState.builds, lessThanOrEqualTo(4));
    expect(find.byTooltip('Pausar'), findsOneWidget);
  });

  testWidgets('mientras suena, tocar una palabra lleva la narración a ella', (tester) async {
    final (engine, _) = await open(tester);
    await tester.tap(find.byTooltip('Escuchar'));
    await tester.pump();
    await tester.tapOnText(find.textRange.ofSubstring('Großvater'));
    await tester.pumpAndSettle();
    final w = asset.words.byId('p1s1t7')!;
    expect(engine.position.inMilliseconds, w.startMs);
    expect(find.text('pasar (tiempo)'), findsNothing);
  });

  testWidgets('sin narración, el lector sigue igual y sin barra', (tester) async {
    await open(
      tester,
      extra: {
        'GET /lesen/readings/$slug/versions/1/audio': (_) => const Reply(404, {'status': 404}),
      },
    );
    expect(find.byType(ReaderAudioBar), findsNothing);
    expect(find.text('Der alte Leuchtturm'), findsWidgets);
  });

  testWidgets('al salir del lector sigue sonando en el mini reproductor', (tester) async {
    final (engine, container) = await open(tester);
    await tester.tap(find.byTooltip('Escuchar'));
    await tester.pump();
    container.read(routerProvider).go(Routes.vocabulary);
    await tester.pumpAndSettle();
    expect(find.byType(MiniPlayer), findsOneWidget);
    expect(find.descendant(of: find.byType(MiniPlayer), matching: find.text('Der alte Leuchtturm')), findsWidgets);
    expect(engine.playing, isTrue);
    await tester.tap(find.byTooltip('Pausar'));
    await tester.pump();
    expect(engine.playing, isFalse);
    await tester.tap(find.byTooltip('Cerrar el reproductor'));
    await tester.pumpAndSettle();
    expect(find.text('Der alte Leuchtturm'), findsNothing);
  });
}
