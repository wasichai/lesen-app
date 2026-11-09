import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/networking/api_client.dart';
import '../../../core/networking/json.dart';
import '../domain/catalog_query.dart';
import '../domain/reading.dart';
import 'catalog_dto.dart';

final catalogRepositoryProvider = Provider<CatalogRepository>((ref) => CatalogRepository(ref.watch(apiProvider)));

class CatalogRepository {
  CatalogRepository(this._api);

  final Api _api;

  static const _base = '/lesen';

  Future<LanguageCatalog> languages() async => CatalogDto.languages(await _api.getJson('$_base/public/languages'));

  Future<List<Topic>> topics() async => (await _api.getList('$_base/public/topics')).map((e) => CatalogDto.topic((e as Map).cast<String, dynamic>())).toList();

  /// `null` si quien lee aún no tiene perfil (404).
  Future<Discover?> discover() async {
    final json = await _api.getJsonOrNull('$_base/discover');
    return json == null ? null : CatalogDto.discover(json);
  }

  Future<PageOf<ReadingCard>> readings(CatalogQuery query, {int page = 0, int size = 12}) async => PageOf.fromJson(
    await _api.getJson(
      '$_base/readings',
      query: query.toQuery(page: page, size: size),
    ),
    CatalogDto.card,
  );

  Future<ReadingDetail> detail(String slug) async => CatalogDto.detail(await _api.getJson('$_base/readings/${Uri.encodeComponent(slug)}'));

  Future<void> setBookmark(String slug, bool value) async {
    await _api.send(value ? 'PUT' : 'DELETE', '$_base/readings/${Uri.encodeComponent(slug)}/bookmark');
  }
}
