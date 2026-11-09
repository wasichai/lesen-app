import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/networking/api_client.dart';
import '../../../core/networking/api_failure.dart';
import '../../../core/networking/json.dart';
import '../../../core/storage/local_store.dart';
import '../domain/note.dart';
import '../domain/reading_content.dart';
import '../domain/reading_progress.dart';

final readerRepositoryProvider = Provider<ReaderRepository>((ref) => ReaderRepository(ref.watch(apiProvider), ref.watch(localStoreProvider)));

enum TranslationUnit { SENTENCE, PARAGRAPH }

class ReaderRepository {
  ReaderRepository(this._api, this._local);

  final Api _api;
  final LocalStore _local;

  static const contentNs = 'content';
  static const progressNs = 'progress';

  String _r(String slug) => '/lesen/readings/${Uri.encodeComponent(slug)}';

  /// El contenido de una versión. Es inmutable: lo que ya se descargó se lee del dispositivo, con o sin red.
  Future<ReadingContent> content(String slug, int version) async {
    final key = '$slug@$version';
    final cached = await _local.read(contentNs, key);
    if (cached != null) return parseContent(cached);
    final json = await _api.getJson('${_r(slug)}/versions/$version/content');
    await _local.write(contentNs, key, json);
    return parseContent(json);
  }

  /// Traducciones humanas de la versión, por oración o párrafo, en el idioma de la interfaz. Lista vacía si no hay.
  Future<Map<String, String>> translations(String slug, int version, TranslationUnit unit) async {
    try {
      final list = await _api.getList('${_r(slug)}/versions/$version/translations', query: {'unit': unit.name});
      return {
        for (final t in list.whereType<Map<String, dynamic>>())
          if (t['ref'] is String && t['text'] is String) t['ref'] as String: t['text'] as String,
      };
    } on NotFoundFailure {
      return const {};
    }
  }

  Future<ReadingProgress?> serverProgress(String slug) async {
    final j = await _api.getJsonOrNull('${_r(slug)}/progress');
    return j == null ? null : parseProgress(j);
  }

  Future<ReadingProgress?> localProgress(String slug) async {
    final j = await _local.read(progressNs, slug);
    return j == null ? null : parseProgress(j, pending: j['pending'] == true);
  }

  /// Guarda en el dispositivo primero (nada se pierde sin red) y después en el servidor.
  Future<ReadingProgress> saveProgress(String slug, ReadingProgress p) async {
    await _local.write(progressNs, slug, {...progressJson(p), 'pending': true, 'updatedAt': p.updatedAt.toIso8601String(), 'completed': p.completed});
    final j = await _api.send('PUT', '${_r(slug)}/progress', body: progressJson(p));
    final saved = j == null ? p.copyWith(pending: false) : parseProgress(j);
    await _local.write(progressNs, slug, {
      ...progressJson(saved),
      'pending': false,
      'updatedAt': saved.updatedAt.toIso8601String(),
      'completed': saved.completed,
    });
    return saved;
  }

  Future<ReadingProgress> complete(String slug, int version, int secondsRead) async {
    final j = await _api.send('POST', '${_r(slug)}/completion', body: {'version': version, 'secondsRead': secondsRead});
    final saved = parseProgress(j!);
    await _local.write(progressNs, slug, {...progressJson(saved), 'pending': false, 'updatedAt': saved.updatedAt.toIso8601String(), 'completed': true});
    return saved;
  }

  Future<void> setBookmark(String slug, bool value) => _api.send(value ? 'PUT' : 'DELETE', '${_r(slug)}/bookmark');

  Future<List<Note>> notes(String slug) async => (await _api.getList('${_r(slug)}/notes')).map((n) => parseNote((n as Map).cast<String, dynamic>())).toList();

  Future<Note> addNote(String slug, {required int version, required String sentenceRef, String? note}) async => parseNote(
    (await _api.send(
      'POST',
      '${_r(slug)}/notes',
      body: {'version': version, 'sentenceRef': sentenceRef, if (note != null && note.trim().isNotEmpty) 'note': note.trim()},
    ))!,
  );

  Future<void> deleteNote(String id) => _api.send('DELETE', '/lesen/notes/${Uri.encodeComponent(id)}');

  static Json progressJson(ReadingProgress p) => {'version': p.version, 'position': p.position, 'percent': p.percent, 'secondsRead': p.secondsRead};

  static ReadingProgress parseProgress(Json j, {bool pending = false}) => ReadingProgress(
    version: j.integer('version'),
    position: j.strOrNull('position'),
    percent: j.integerOrNull('percent') ?? 0,
    secondsRead: j.integerOrNull('secondsRead') ?? 0,
    completed: j.boolean('completed'),
    updatedAt: j.dateOrNull('updatedAt') ?? DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
    pending: pending,
  );

  static Note parseNote(Json j) => Note(
    id: j['id'].toString(),
    version: j.integer('version'),
    sentenceRef: j.str('sentenceRef'),
    quote: j.str('quote'),
    note: j.strOrNull('note'),
    createdAt: j.dateOrNull('createdAt'),
  );

  static ReadingContent parseContent(Json j) => ReadingContent(
    slug: j.str('slug'),
    version: j.integer('version'),
    language: j.str('language'),
    current: j.boolean('current', fallback: true),
    paragraphs: j.list(
      'paragraphs',
      (p) => Paragraph(
        id: p.str('id'),
        sentences: p.list(
          'sentences',
          (s) => Sentence(
            id: s.str('id'),
            tokens: s.list(
              'tokens',
              (t) => Token(
                id: t.str('id'),
                text: t.str('text'),
                kind: t.strOrNull('kind') == 'WORD' ? TokenKind.WORD : TokenKind.PUNCT,
                space: t.boolean('space'),
                entry: t.strOrNull('entry'),
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
