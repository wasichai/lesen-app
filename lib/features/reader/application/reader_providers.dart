import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/networking/api_failure.dart';
import '../../../core/storage/local_store.dart';
import '../../catalog/data/catalog_repository.dart';
import '../../catalog/domain/reading.dart';
import '../../dictionary/data/dictionary_repository.dart';
import '../../dictionary/domain/entry.dart';
import '../../vocabulary/data/vocabulary_repository.dart';
import '../../vocabulary/domain/known_words.dart';
import '../data/reader_repository.dart';
import '../domain/note.dart';
import '../domain/reader_preferences.dart';
import '../domain/reading_content.dart';
import '../domain/reading_progress.dart';

/// Preferencias del lector, guardadas en el dispositivo.
final readerPreferencesProvider = NotifierProvider<ReaderPreferencesController, ReaderPreferences>(ReaderPreferencesController.new);

class ReaderPreferencesController extends Notifier<ReaderPreferences> {
  static const _ns = 'prefs';
  static const _key = 'reader';

  @override
  ReaderPreferences build() {
    _load();
    return const ReaderPreferences();
  }

  Future<void> _load() async {
    final j = await ref.read(localStoreProvider).read(_ns, _key);
    if (j != null && ref.mounted) state = ReaderPreferences.fromJson(j);
  }

  Future<void> update(ReaderPreferences next) async {
    state = next;
    await ref.read(localStoreProvider).write(_ns, _key, next.toJson());
  }
}

/// Todo lo que hace falta para abrir una lectura: la ficha, la versión que se lee, su contenido y el progreso.
class ReaderSession {
  const ReaderSession({required this.reading, required this.content, required this.progress});

  final ReadingCard reading;
  final ReadingContent content;
  final ReadingProgress? progress;
}

final readerSessionProvider = FutureProvider.autoDispose.family<ReaderSession, String>((ref, slug) async {
  final repo = ref.watch(readerRepositoryProvider);
  final detail = await ref.watch(catalogRepositoryProvider).detail(slug);
  final local = await repo.localProgress(slug);
  ReadingProgress? server;
  try {
    server = await repo.serverProgress(slug);
  } on ApiFailure catch (e) {
    // sin red se sigue con lo local; otros fallos se muestran
    if (!e.isTransient) rethrow;
  }
  final progress = mergeProgress(local, server);
  // quien empezó una versión la termina en esa (ADR-0003 del backend); terminada, se abre la vigente
  final version = (progress != null && !progress.completed) ? progress.version : detail.reading.version;
  final content = await repo.content(slug, version);
  return ReaderSession(reading: detail.reading, content: content, progress: progress?.version == version ? progress : null);
});

typedef VersionUnit = ({String slug, int version, TranslationUnit unit});

final translationsProvider = FutureProvider.autoDispose.family<Map<String, String>, VersionUnit>((ref, k) {
  ref.keepAlive();
  return ref.watch(readerRepositoryProvider).translations(k.slug, k.version, k.unit);
});

typedef TokenRef = ({String slug, int version, String tokenId});

final lookupProvider = FutureProvider.autoDispose.family<Lookup, TokenRef>(
  (ref, k) => ref.watch(dictionaryRepositoryProvider).lookup(slug: k.slug, version: k.version, tokenId: k.tokenId),
);

/// Palabras conocidas en un idioma, para resaltar; vacío si falla (resaltar es una ayuda, no bloquea la lectura).
final knownWordsProvider = NotifierProvider.autoDispose.family<KnownWordsController, KnownWords, String>(KnownWordsController.new);

class KnownWordsController extends Notifier<KnownWords> {
  KnownWordsController(this.language);

  final String language;

  @override
  KnownWords build() {
    _load();
    return KnownWords.empty;
  }

  Future<void> _load() async {
    try {
      final known = await ref.read(vocabularyRepositoryProvider).known(language);
      if (ref.mounted) state = known;
    } on ApiFailure {
      // se queda vacío
    }
  }

  /// Guarda una palabra en el cuaderno. Lanza [ApiFailure] si el servidor no la acepta.
  Future<void> save({required String entryKey, required String slug, required int version, required String tokenRef}) async {
    await ref.read(vocabularyRepositoryProvider).save(entryKey: entryKey, slug: slug, version: version, tokenRef: tokenRef);
    if (ref.mounted) state = state.withSaved(entryKey);
  }
}

final notesProvider = AsyncNotifierProvider.autoDispose.family<NotesController, List<Note>, String>(NotesController.new);

class NotesController extends AsyncNotifier<List<Note>> {
  NotesController(this.slug);

  final String slug;

  @override
  Future<List<Note>> build() => ref.watch(readerRepositoryProvider).notes(slug);

  Future<void> add({required int version, required String sentenceRef, String? note}) async {
    final created = await ref.read(readerRepositoryProvider).addNote(slug, version: version, sentenceRef: sentenceRef, note: note);
    state = AsyncData([...?state.value, created]);
  }

  Future<void> remove(String id) async {
    await ref.read(readerRepositoryProvider).deleteNote(id);
    state = AsyncData([...?state.value?.where((n) => n.id != id)]);
  }
}
