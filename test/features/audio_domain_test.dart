import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:lesen/core/audio/narration_engine.dart';
import 'package:lesen/core/networking/json.dart';
import 'package:lesen/core/storage/local_store.dart';
import 'package:lesen/features/audio/application/playback_controller.dart';
import 'package:lesen/features/audio/data/audio_repository.dart';
import 'package:lesen/features/audio/domain/timing_index.dart';
import 'package:lesen/features/catalog/data/catalog_dto.dart';
import 'package:lesen/features/reader/data/reader_repository.dart';

import '../support/fake_backend.dart';
import '../support/harness.dart';

Json reading(String slug) => ((fixtures['readings'] as Map)[slug] as Map).cast<String, dynamic>();

void main() {
  final r = reading('der-alte-leuchtturm');
  final asset = AudioRepository.parseAsset(((r['audio'] as Map)['assets'] as List).first as Json);
  final content = ReaderRepository.parseContent(r['content'] as Json);

  group('TimingIndex', () {
    final idx = TimingIndex(const [TimedSpan('a', 0, 400), TimedSpan('b', 500, 900), TimedSpan('c', 2000, 2600)]);

    test('búsqueda binaria del último tramo empezado', () {
      expect(idx.lastStartedAt(-1), -1);
      expect(idx.lastStartedAt(0), 0);
      expect(idx.lastStartedAt(650), 1);
      expect(idx.lastStartedAt(99999), 2);
    });

    test('la palabra sigue activa 250 ms tras terminar y después ninguna', () {
      expect(idx.activeAt(450)?.id, 'a');
      expect(idx.activeAt(1100)?.id, 'b');
      expect(idx.activeAt(1200), isNull);
      expect(idx.activeAt(2100)?.id, 'c');
    });

    test('siguiente y anterior; atrás vuelve al inicio del actual si ya se oyó más de un segundo', () {
      expect(idx.neighbourStart(100, 1), 500);
      expect(idx.neighbourStart(2500, 1), isNull);
      expect(idx.neighbourStart(2200, -1), 500);
      expect(idx.neighbourStart(3500, -1), 2000);
      expect(idx.neighbourStart(100, -1), 0);
    });
  });

  test('los tiempos reales casan con los tokens de la versión', () {
    expect(asset.duration, const Duration(milliseconds: 72227));
    expect(asset.words.length, content.index.words.length);
    for (var i = 0; i < asset.words.length; i++) {
      final w = asset.words[i];
      expect(content.index.tokenById[w.id]?.isWord, isTrue, reason: w.id);
      expect(w.endMs, greaterThanOrEqualTo(w.startMs));
    }
    expect(asset.sentences.length, content.index.sentences.length);
  });

  test('lo activo en un instante: palabra, oración y párrafo', () {
    final word = asset.words[5];
    final a = activeSpanAt(asset, content, word.startMs + 10)!;
    expect(a.tokenId, word.id);
    expect(a.sentenceId, content.index.sentenceOfToken[word.id]);
    expect(a.paragraph, content.index.paragraphOfSentence[a.sentenceId]);
    expect(activeSpanAt(asset, content, -5), isNull);
  });

  group('PlaybackController', () {
    late FakeNarrationEngine engine;
    late PlaybackController c;
    late MemoryLocalStore local;

    setUp(() async {
      engine = FakeNarrationEngine();
      local = MemoryLocalStore();
      final container = createContainerForTest(FakeBackend(), engine: engine, local: local);
      container.read(playbackProvider);
      c = container.read(playbackProvider.notifier);
      await local.write('audio', 'der-alte-leuchtturm@1', {'positionMs': 4000});
      final card = CatalogDto.card((r['detail'] as Map)['reading'] as Json);
      await c.open(reading: card, content: content, asset: asset);
    });

    test('carga la URL resuelta en la posición guardada, sin sonar', () {
      expect(engine.loaded.toString(), 'http://lesen.test/api/lesen/public/audio/der-alte-leuchtturm.mp3');
      expect(engine.position, const Duration(seconds: 4));
      expect(engine.playing, isFalse);
      expect(engine.media!.title, 'Der alte Leuchtturm');
    });

    test('lo activo solo notifica al cambiar de palabra', () async {
      var notified = 0;
      c.active.addListener(() => notified++);
      final w = asset.words[10];
      engine.advanceTo(Duration(milliseconds: w.startMs + 5));
      await Future<void>.delayed(Duration.zero);
      engine.advanceTo(Duration(milliseconds: w.startMs + 15));
      await Future<void>.delayed(Duration.zero);
      engine.advanceTo(Duration(milliseconds: w.startMs + 25));
      await Future<void>.delayed(Duration.zero);
      expect(c.active.value?.tokenId, w.id);
      expect(notified, 1);
    });

    test('navegar por oración y párrafo, y los botones del sistema van por párrafo', () async {
      engine.advanceTo(Duration(milliseconds: asset.sentences[0].startMs + 10));
      await c.sentence(1);
      expect(engine.position.inMilliseconds, asset.sentences[1].startMs);
      await c.paragraph(1);
      expect(engine.position.inMilliseconds, asset.paragraphs[1].startMs);
      engine.skip!(1);
      await Future<void>.delayed(Duration.zero);
      expect(engine.position.inMilliseconds, asset.paragraphs[2].startMs);
    });

    test('reproducir desde una palabra y cambiar la velocidad', () async {
      final w = asset.words[30];
      await c.playFromToken(w.id);
      expect(engine.position.inMilliseconds, w.startMs);
      expect(engine.playing, isTrue);
      await c.setSpeed(1.25);
      expect(engine.speed, 1.25);
    });

    test('cerrar guarda la posición y suelta la lectura', () async {
      engine.advanceTo(const Duration(seconds: 30));
      unawaited(c.close());
      await Future<void>.delayed(Duration.zero);
      expect((await local.read('audio', 'der-alte-leuchtturm@1'))!['positionMs'], 30000);
      expect(c.now, isNull);
    });
  });
}
