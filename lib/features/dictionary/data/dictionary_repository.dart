import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/networking/api_client.dart';
import '../domain/entry.dart';
import 'dictionary_dto.dart';

final dictionaryRepositoryProvider = Provider<DictionaryRepository>((ref) => DictionaryRepository(ref.watch(apiProvider)));

class DictionaryRepository {
  DictionaryRepository(this._api);

  final Api _api;

  /// La palabra tocada en su contexto: la entrada (o `null`), si es una forma flexionada y la oración.
  Future<Lookup> lookup({required String slug, required int version, required String tokenId}) async =>
      DictionaryDto.lookup(await _api.getJson('/lesen/dictionary/lookup', query: {'reading': slug, 'version': version, 'token': tokenId}));

  Future<Entry> entry(String key) async => DictionaryDto.entry(await _api.getJson('/lesen/dictionary/entries/${Uri.encodeComponent(key)}'));
}
