import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/networking/api_client.dart';
import '../../../core/networking/json.dart';
import '../domain/known_words.dart';
import '../domain/vocabulary.dart';

final vocabularyRepositoryProvider = Provider<VocabularyRepository>((ref) => VocabularyRepository(ref.watch(apiProvider)));

class VocabularyRepository {
  VocabularyRepository(this._api);

  final Api _api;
  static const _base = '/lesen/vocabulary';

  Future<KnownWords> known(String language) async {
    final j = await _api.getJson('$_base/known', query: {'language': language});
    return KnownWords(
      saved: {for (final s in j.list('saved', (s) => s)) s.str('key'): status(s.strOrNull('status'))},
      encountered: j.strings('encountered').toSet(),
    );
  }

  /// Guarda la palabra con la oración donde se encontró. Idempotente: 201 la primera vez, 200 si ya estaba.
  Future<Json?> save({required String entryKey, String? slug, int? version, String? tokenRef}) =>
      _api.send('POST', _base, body: {'entryKey': entryKey, 'reading': ?slug, 'version': ?version, 'tokenRef': ?tokenRef});

  Future<PageOf<VocabularyItem>> list({int page = 0, int size = 24, String q = '', WordStatus? status, String? reading}) async => PageOf.fromJson(
    await _api.getJson(
      _base,
      query: {'page': page, 'size': size, if (q.trim().isNotEmpty) 'q': q.trim(), if (status != null) 'status': status.name, 'reading': ?reading},
    ),
    item,
  );

  Future<VocabularyItem> setNote(String id, String? note) async {
    final j = await _api.send('PATCH', '$_base/${Uri.encodeComponent(id)}', body: {'note': (note?.trim().isEmpty ?? true) ? null : note!.trim()});
    return item(j!);
  }

  Future<void> remove(String id) => _api.send('DELETE', '$_base/${Uri.encodeComponent(id)}');

  Future<VocabularyStats> stats(String language) async {
    final j = await _api.getJson('$_base/stats', query: {'language': language});
    final by = j.objOrNull('byStatus') ?? const {};
    return VocabularyStats(
      total: j.integerOrNull('total') ?? 0,
      byStatus: {for (final s in WordStatus.values) s: (by[s.name] as num?)?.toInt() ?? 0},
      dueNow: j.integerOrNull('dueNow') ?? 0,
      reviewedToday: j.integerOrNull('reviewedToday') ?? 0,
      encountered: j.integerOrNull('encountered') ?? 0,
    );
  }

  Future<ReviewQueue> nextReviews(String language, {int limit = 20, String? reading}) async {
    final j = await _api.getJson('$_base/reviews/next', query: {'language': language, 'limit': limit, 'reading': ?reading});
    return ReviewQueue(
      cards: j.list(
        'cards',
        (c) => ReviewCard(
          item: item(c.obj('item')),
          state: CardState.values.where((s) => s.name == c.strOrNull('state')).firstOrNull ?? CardState.unknown,
          preview: {
            for (final r in ReviewRating.values)
              if (c.objOrNull('preview')?[r.name] is String) r: DateTime.parse(c.obj('preview')[r.name] as String),
          },
        ),
      ),
      due: j.integerOrNull('due') ?? 0,
      nextDueAt: j.dateOrNull('nextDueAt'),
    );
  }

  /// Un repaso. `clientId` lo hace idempotente: repetirlo (un reintento) no repasa dos veces.
  Future<VocabularyItem> review({required String vocabularyId, required ReviewRating rating, required String clientId}) async {
    final j = await _api.send('POST', '$_base/reviews', body: {'vocabularyId': vocabularyId, 'rating': rating.name, 'clientId': clientId});
    return item(j!.obj('item'));
  }

  static WordStatus status(String? name) => WordStatus.values.where((v) => v.name == name).firstOrNull ?? WordStatus.SAVED;

  static VocabularyItem item(Json j) {
    final s = j.objOrNull('source');
    return VocabularyItem(
      id: j['id'].toString(),
      entryKey: j.str('entryKey'),
      lemma: j.str('lemma'),
      pos: j.strOrNull('pos'),
      language: j.str('language'),
      translations: j.strings('translations'),
      surface: j.strOrNull('surface') ?? j.str('lemma'),
      context: j.strOrNull('context'),
      tokenRef: j.strOrNull('tokenRef'),
      source: s == null ? null : VocabularySource(slug: s.str('slug'), title: s.str('title'), version: s.integerOrNull('version') ?? 1),
      status: status(j.strOrNull('status')),
      note: j.strOrNull('note'),
      savedAt: j.dateOrNull('savedAt'),
      dueAt: j.dateOrNull('dueAt'),
      reviews: j.integerOrNull('reviews') ?? 0,
    );
  }
}
