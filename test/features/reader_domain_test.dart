import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lesen/core/networking/json.dart';
import 'package:lesen/core/storage/local_database.dart';
import 'package:lesen/core/storage/local_store.dart';
import 'package:lesen/features/dictionary/data/dictionary_dto.dart';
import 'package:lesen/features/reader/data/reader_repository.dart';
import 'package:lesen/features/reader/domain/reader_preferences.dart';
import 'package:lesen/features/reader/domain/reading_content.dart';
import 'package:lesen/features/reader/domain/reading_progress.dart';
import 'package:lesen/features/vocabulary/domain/known_words.dart';

import '../support/fake_backend.dart';

Json reading(String slug) => ((fixtures['readings'] as Map)[slug] as Map).cast<String, dynamic>();

void main() {
  final content = ReaderRepository.parseContent(reading('der-alte-leuchtturm')['content'] as Json);

  group('ReaderIndex', () {
    test('ordena oraciones y palabras del contenido real', () {
      final idx = content.index;
      expect(idx.sentences.first.id, 'p1s1');
      expect(idx.sentences.first.text, 'Mia verbringt den Sommer bei ihrem Großvater an der Nordsee.');
      expect(idx.words.every((w) => w.isWord), isTrue);
      expect(idx.paragraphOfSentence['p2s1'], 1);
      expect(idx.sentenceOfToken['p1s1t2'], 'p1s1');
    });

    test('el avance cuenta hasta la oración incluida; la última es el 100 %', () {
      final idx = content.index;
      expect(idx.percentAt(null), 0);
      expect(idx.percentAt('nope'), 0);
      expect(idx.percentAt(idx.sentences.last.id), 100);
      expect(idx.percentAt(idx.sentences.first.id), (100 / idx.sentences.length).round());
    });

    test('de las visibles, la primera en el texto', () {
      expect(content.index.topmost(['p2s1', 'p1s3', 'p3s1']), 'p1s3');
      expect(content.index.topmost(const []), isNull);
    });

    test('minutos restantes', () {
      expect(remainingMinutes(4, 0), 4);
      expect(remainingMinutes(4, 60), 2);
      expect(remainingMinutes(4, 100), 0);
    });
  });

  group('mergeProgress', () {
    ReadingProgress p({int version = 1, String? pos, int percent = 0, int secs = 0, bool done = false, required int minute, bool pending = false}) =>
        ReadingProgress(
          version: version,
          position: pos,
          percent: percent,
          secondsRead: secs,
          completed: done,
          updatedAt: DateTime.utc(2026, 11, 9, 10, minute),
          pending: pending,
        );

    test('sin uno de los dos, el otro', () {
      final a = p(minute: 1);
      expect(mergeProgress(null, a), a);
      expect(mergeProgress(a, null), a);
    });

    test('la posición del más reciente; porcentaje y segundos, el mayor', () {
      // leyó en el móvil sin red (más reciente), pero en la web había avanzado más antes
      final local = p(pos: 'p2s1', percent: 30, secs: 120, minute: 30, pending: true);
      final server = p(pos: 'p4s2', percent: 60, secs: 90, minute: 10);
      final m = mergeProgress(local, server)!;
      expect(m.position, 'p2s1');
      expect(m.percent, 60);
      expect(m.secondsRead, 120);
      expect(m.pending, isTrue);
    });

    test('lo viejo del dispositivo no pisa lo nuevo del servidor', () {
      final local = p(pos: 'p1s1', percent: 10, secs: 20, minute: 1);
      final server = p(pos: 'p5s1', percent: 80, secs: 300, minute: 50, done: true);
      final m = mergeProgress(local, server)!;
      expect(m.position, 'p5s1');
      expect(m.completed, isTrue);
      expect(m.pending, isFalse);
    });

    test('versiones distintas: gana la más reciente entera', () {
      final local = p(version: 1, pos: 'p1s1', minute: 1);
      final server = p(version: 2, pos: 'p2s1', minute: 5);
      expect(mergeProgress(local, server), server);
    });
  });

  test('preferencias del lector: ida y vuelta, y tamaños solo de la escala', () {
    const prefs = ReaderPreferences(fontSize: 26, theme: ReaderTheme.sepia, leading: ReaderLeading.airy, highlightNew: true);
    final back = ReaderPreferences.fromJson(prefs.toJson());
    expect(back.fontSize, 26);
    expect(back.theme, ReaderTheme.sepia);
    expect(back.highlightNew, isTrue);
    expect(ReaderPreferences.fromJson({'fontSize': 99, 'theme': 'neon'}).fontSize, 21);
    expect(const ReaderPreferences(fontSize: 29).canGrow, isFalse);
    expect(const ReaderPreferences(fontSize: 21).step(1).fontSize, 23);
    expect(const ReaderPreferences(fontSize: 18).step(-1).fontSize, 18);
  });

  test('palabras conocidas: guardada, aprendida, nueva', () {
    const known = KnownWords(saved: {'de:meer': WordStatus.MASTERED, 'de:licht': WordStatus.SAVED}, encountered: {'de:und'});
    expect(known.isLearned('de:meer'), isTrue);
    expect(known.isLearned('de:licht'), isFalse);
    expect(known.isNew('de:und'), isFalse);
    expect(known.isNew('de:wind'), isTrue);
    expect(known.withSaved('de:wind').isSaved('de:wind'), isTrue);
  });

  test('una entrada real del diccionario se lee entera', () {
    final entries = ((reading('der-alte-leuchtturm')['entries'] as Map)['es'] as Map).cast<String, dynamic>();
    final e = DictionaryDto.entry(entries['de:verbringen'] as Json);
    expect(e.lemma, 'verbringen');
    expect(e.grammar['auxiliary'], 'haben');
    expect(e.translations, ['pasar (tiempo)']);
    expect(e.senses.first.examples.first.translation, 'Pasamos las vacaciones junto al mar.');
  });

  test('la base local guarda y lee documentos y borra por espacio', () async {
    final store = SqlLocalStore(LocalDatabase(NativeDatabase.memory()));
    await store.write('progress', 'a', {'percent': 10});
    await store.write('progress', 'a', {'percent': 20});
    await store.write('content', 'a@1', {'x': 1});
    expect(await store.read('progress', 'a'), {'percent': 20});
    expect((await store.all('progress')).length, 1);
    await store.clearNamespaces(['progress']);
    expect(await store.read('progress', 'a'), isNull);
    expect(await store.read('content', 'a@1'), {'x': 1});
  });
}
