import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/networking/api_client.dart';
import '../../../core/networking/json.dart';
import '../domain/known_words.dart';

final vocabularyRepositoryProvider = Provider<VocabularyRepository>((ref) => VocabularyRepository(ref.watch(apiProvider)));

class VocabularyRepository {
  VocabularyRepository(this._api);

  final Api _api;

  Future<KnownWords> known(String language) async {
    final j = await _api.getJson('/lesen/vocabulary/known', query: {'language': language});
    return KnownWords(
      saved: {
        for (final s in j.list('saved', (s) => s))
          s.str('key'): WordStatus.values.where((v) => v.name == s.strOrNull('status')).firstOrNull ?? WordStatus.SAVED,
      },
      encountered: j.strings('encountered').toSet(),
    );
  }

  /// Guarda la palabra con la oración donde se encontró. Idempotente: 201 la primera vez, 200 si ya estaba.
  Future<Json?> save({required String entryKey, String? slug, int? version, String? tokenRef}) =>
      _api.send('POST', '/lesen/vocabulary', body: {'entryKey': entryKey, 'reading': ?slug, 'version': ?version, 'tokenRef': ?tokenRef});
}
