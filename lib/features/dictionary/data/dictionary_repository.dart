import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/networking/api_client.dart';
import '../domain/entry.dart';
import 'dictionary_dto.dart';

final dictionaryRepositoryProvider = Provider<DictionaryRepository>((ref) => DictionaryRepository(ref.watch(apiProvider)));

class HistoryItem {
  const HistoryItem(this.query, this.entryKey);

  final String query;
  final String? entryKey;
}

class DictionaryRepository {
  DictionaryRepository(this._api);

  final Api _api;
  static const _base = '/lesen/dictionary';

  /// La palabra tocada en su contexto: la entrada (o `null`), si es una forma flexionada y la oración.
  Future<Lookup> lookup({required String slug, required int version, required String tokenId}) async =>
      DictionaryDto.lookup(await _api.getJson('$_base/lookup', query: {'reading': slug, 'version': version, 'token': tokenId}));

  Future<Entry> entry(String key) async => DictionaryDto.entry(await _api.getJson('$_base/entries/${Uri.encodeComponent(key)}'));

  /// Busca en los dos sentidos (lema, forma o traducción). Con `record`, queda en el historial.
  Future<List<EntrySummary>> search(String q, {int limit = 20, bool record = false}) async => (await _api.getList(
    '$_base/search',
    query: {'q': q, 'limit': limit, if (record) 'record': true},
  )).map((e) => DictionaryDto.summary((e as Map).cast<String, dynamic>())).toList();

  Future<List<HistoryItem>> history() async =>
      (await _api.getList('$_base/history'))
          .whereType<Map<String, dynamic>>()
          .map((h) => HistoryItem(h['query'].toString(), h['entryKey'] as String?))
          .toList();

  Future<void> clearHistory() => _api.send('DELETE', '$_base/history');

  Future<List<EntrySummary>> favorites() async =>
      (await _api.getList('$_base/favorites')).map((e) => DictionaryDto.summary((e as Map).cast<String, dynamic>())).toList();

  Future<void> setFavorite(String key, bool value) => _api.send(value ? 'PUT' : 'DELETE', '$_base/favorites/${Uri.encodeComponent(key)}');
}
