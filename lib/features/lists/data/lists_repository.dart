import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/networking/api_client.dart';
import '../../../core/networking/json.dart';
import '../../catalog/data/catalog_dto.dart';
import '../../catalog/domain/reading.dart';

class ReadingList {
  const ReadingList({required this.id, required this.name, required this.count, required this.contains, this.readings = const []});

  final String id;
  final String name;
  final int count;

  /// Con `?reading=slug`: si esa lectura está en la lista.
  final bool contains;
  final List<ReadingCard> readings;
}

final listsRepositoryProvider = Provider<ListsRepository>((ref) => ListsRepository(ref.watch(apiProvider)));

/// Listas propias de lecturas (`/api/lesen/lists`).
class ListsRepository {
  ListsRepository(this._api);

  final Api _api;
  static const _base = '/lesen/lists';

  Future<List<ReadingList>> all({String? reading}) async =>
      (await _api.getList(_base, query: {'reading': ?reading})).map((l) => parse((l as Map).cast<String, dynamic>())).toList();

  Future<ReadingList> get(String id) async => parse(await _api.getJson('$_base/${Uri.encodeComponent(id)}'));

  Future<ReadingList> create(String name) async => parse((await _api.send('POST', _base, body: {'name': name.trim()}))!);

  Future<void> rename(String id, String name) => _api.send('PATCH', '$_base/${Uri.encodeComponent(id)}', body: {'name': name.trim()});

  Future<void> delete(String id) => _api.send('DELETE', '$_base/${Uri.encodeComponent(id)}');

  Future<void> setMembership(String id, String slug, bool member) =>
      _api.send(member ? 'PUT' : 'DELETE', '$_base/${Uri.encodeComponent(id)}/readings/${Uri.encodeComponent(slug)}');

  static ReadingList parse(Json j) {
    final readings = j.list('readings', CatalogDto.card);
    return ReadingList(
      id: j['id'].toString(),
      name: j.str('name'),
      count: j.integerOrNull('count') ?? readings.length,
      contains: j.boolean('contains'),
      readings: readings,
    );
  }
}
