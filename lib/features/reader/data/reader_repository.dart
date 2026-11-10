import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/networking/api_client.dart';
import '../../../core/networking/api_failure.dart';
import '../../../core/networking/json.dart';
import '../../../core/storage/cache.dart';
import '../../../core/storage/local_store.dart';
import '../../../core/sync/outbox.dart';
import '../../../core/sync/sync.dart';
import '../domain/note.dart';
import '../domain/reading_content.dart';
import '../domain/reading_progress.dart';

final readerRepositoryProvider = Provider<ReaderRepository>(
  (ref) => ReaderRepository(ref.watch(apiProvider), ref.watch(localStoreProvider), ref.watch(outboxProvider)),
);

enum TranslationUnit { SENTENCE, PARAGRAPH }

class ReaderRepository {
  ReaderRepository(this._api, this._local, this._outbox);

  final Api _api;
  final LocalStore _local;
  final Outbox _outbox;

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

  /// Traducciones humanas de la versión, por oración o párrafo, en el idioma de la interfaz. Vacío si no hay. Son de
  /// una versión inmutable: una vez pedidas, se leen del dispositivo.
  Future<Map<String, String>> translations(String slug, int version, TranslationUnit unit) async {
    final j = await _local.cacheFirst('translations:$slug@$version:${unit.name}', () async {
      try {
        final list = await _api.getList('${_r(slug)}/versions/$version/translations', query: {'unit': unit.name});
        return {
          for (final t in list.whereType<Map<String, dynamic>>())
            if (t['ref'] is String && t['text'] is String) t['ref'] as String: t['text'] as String,
        };
      } on NotFoundFailure {
        return <String, dynamic>{};
      }
    });
    return j.map((k, v) => MapEntry(k, v.toString()));
  }

  Future<ReadingProgress?> serverProgress(String slug) async {
    final j = await _api.getJsonOrNull('${_r(slug)}/progress');
    return j == null ? null : parseProgress(j);
  }

  Future<ReadingProgress?> localProgress(String slug) async {
    final j = await _local.read(progressNs, slug);
    return j == null ? null : parseProgress(j, pending: j['pending'] == true);
  }

  /// Guarda en el dispositivo y encola el envío (ADR-0007): sin red no se pierde nada. Solo cuenta el último progreso
  /// de cada lectura; queda `pending` hasta que el servidor lo confirma.
  Future<ReadingProgress> saveProgress(String slug, ReadingProgress p) async {
    await _writeLocal(slug, p.copyWith(pending: true));
    await _outbox.enqueue(Ops.progress, {'slug': slug, 'body': progressJson(p)}, collapseKey: 'progress:$slug');
    unawaited(_outbox.flush());
    return p.copyWith(pending: true);
  }

  /// Terminar la lectura: en el dispositivo al momento y en el servidor cuando haya red (allí es idempotente).
  Future<ReadingProgress> complete(String slug, ReadingProgress p) async {
    final done = p.copyWith(completed: true, percent: 100, pending: true);
    await _writeLocal(slug, done);
    await _outbox.enqueue(Ops.progress, {'slug': slug, 'body': progressJson(done)}, collapseKey: 'progress:$slug');
    await _outbox.enqueue(Ops.completion, {
      'slug': slug,
      'body': {'version': p.version, 'secondsRead': p.secondsRead},
    }, collapseKey: 'completion:$slug');
    unawaited(_outbox.flush());
    return done;
  }

  Future<void> _writeLocal(String slug, ReadingProgress p) =>
      _local.write(progressNs, slug, {...progressJson(p), 'pending': p.pending, 'updatedAt': p.updatedAt.toIso8601String(), 'completed': p.completed});

  /// El marcador va por la cola: el último toque es el que vale.
  Future<void> setBookmark(String slug, bool value) async {
    await _outbox.enqueue(Ops.bookmark, {'slug': slug, 'value': value}, collapseKey: 'bookmark:$slug');
    unawaited(_outbox.flush());
  }

  Future<List<Note>> notes(String slug) async => (await _api.getList('${_r(slug)}/notes')).map((n) => parseNote((n as Map).cast<String, dynamic>())).toList();

  /// Una nota va por la cola; mientras no llega, se muestra con un id provisional.
  Future<Note> addNote(String slug, {required int version, required String sentenceRef, required String quote, String? note}) async {
    final text = note?.trim();
    final body = {'version': version, 'sentenceRef': sentenceRef, if (text != null && text.isNotEmpty) 'note': text};
    final op = await _outbox.enqueue(Ops.note, {'slug': slug, 'body': body});
    unawaited(_outbox.flush());
    return Note(id: 'pending:${op.id}', version: version, sentenceRef: sentenceRef, quote: quote, note: body['note'] as String?, createdAt: op.createdAt);
  }

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

  static ReadingContent parseContent(Json j) {
    final paragraphs = _paragraphs(j);
    return ReadingContent(
      slug: j.str('slug'),
      version: j.integer('version'),
      language: j.str('language'),
      current: j.boolean('current', fallback: true),
      paragraphs: paragraphs,
      blocks: _blocks(j, paragraphs),
    );
  }

  /// `blocks` (ADR-0018): el orden de lectura cuando la versión tiene ilustraciones; `null` sin ellas. Cada párrafo
  /// aparece una vez; un tipo de bloque desconocido se ignora, para que uno nuevo no rompa el lector.
  static List<ContentBlock>? _blocks(Json j, List<Paragraph> paragraphs) {
    final raw = j.opt<List>('blocks');
    if (raw == null) return null;
    final at = {for (var i = 0; i < paragraphs.length; i++) paragraphs[i].id: i};
    final seen = <int>{};
    final blocks = <ContentBlock>[];
    for (final item in raw) {
      final b = (item as Map).cast<String, dynamic>();
      switch (b.strOrNull('type')) {
        case 'paragraph':
          final id = b.str('id');
          final i = at[id];
          if (i == null || !seen.add(i)) throw ContractException('blocks: el párrafo "$id" no existe o se repite');
          blocks.add(ParagraphBlock(i));
        case 'image':
          blocks.add(IllustrationBlock(parseIllustration(b)));
      }
    }
    if (seen.length != paragraphs.length) throw ContractException('blocks: faltan párrafos del texto');
    return blocks;
  }

  static Illustration parseIllustration(Json b) {
    final id = b.str('id');
    final alt = b.str('alt').trim();
    if (alt.isEmpty) throw ContractException('ilustración "$id": sin texto alternativo');
    final width = b.integer('width');
    final height = b.integer('height');
    if (width <= 0 || height <= 0) throw ContractException('ilustración "$id": medidas no válidas');
    final caption = b.strOrNull('caption')?.trim();
    return Illustration(id: id, url: b.str('url'), width: width, height: height, alt: alt, caption: caption == null || caption.isEmpty ? null : caption);
  }

  static List<Paragraph> _paragraphs(Json j) => j.list(
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
  );
}
