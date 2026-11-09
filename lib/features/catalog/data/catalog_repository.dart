import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/networking/api_client.dart';
import '../../../core/networking/json.dart';
import '../../../core/storage/cache.dart';
import '../../../core/storage/local_store.dart';
import '../domain/catalog_query.dart';
import '../domain/reading.dart';
import 'catalog_dto.dart';

final catalogRepositoryProvider = Provider<CatalogRepository>((ref) => CatalogRepository(ref.watch(apiProvider), ref.watch(localStoreProvider)));

class CatalogRepository {
  CatalogRepository(this._api, this._local);

  final Api _api;
  final LocalStore _local;

  static const _base = '/lesen';

  Future<LanguageCatalog> languages() async => CatalogDto.languages(await _local.networkFirst('languages', () => _api.getJson('$_base/public/languages')));

  Future<List<Topic>> topics() async => (await _api.getList('$_base/public/topics')).map((e) => CatalogDto.topic((e as Map).cast<String, dynamic>())).toList();

  /// `null` si quien lee aún no tiene perfil (404).
  Future<Discover?> discover() async {
    final json = await _local.networkFirst('discover', () async => await _api.getJsonOrNull('$_base/discover') ?? const {'none': true});
    return json['none'] == true ? null : CatalogDto.discover(json);
  }

  Future<PageOf<ReadingCard>> readings(CatalogQuery query, {int page = 0, int size = 12}) async => PageOf.fromJson(
    await _api.getJson(
      '$_base/readings',
      query: query.toQuery(page: page, size: size),
    ),
    CatalogDto.card,
  );

  Future<ReadingDetail> detail(String slug) async =>
      CatalogDto.detail(await _local.networkFirst('detail:$slug', () => _api.getJson('$_base/readings/${Uri.encodeComponent(slug)}')));
}
