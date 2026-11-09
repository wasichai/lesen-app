import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/networking/api_client.dart';
import '../../../core/networking/api_failure.dart';
import '../../../core/networking/json.dart';
import '../../../core/storage/cache.dart';
import '../../../core/storage/local_store.dart';
import '../domain/audio_asset.dart';
import '../domain/timing_index.dart';

final audioRepositoryProvider = Provider<AudioRepository>((ref) => AudioRepository(ref.watch(apiProvider), ref.watch(localStoreProvider)));

/// La narración de una versión; `null` si no tiene (404): el lector funciona igual sin audio.
final readingAudioProvider = FutureProvider.autoDispose.family<AudioAsset?, ({String slug, int version})>((ref, k) async {
  ref.keepAlive();
  return ref.watch(audioRepositoryProvider).audio(k.slug, k.version);
});

class AudioRepository {
  AudioRepository(this._api, this._local);

  final Api _api;
  final LocalStore _local;

  Future<AudioAsset?> audio(String slug, int version) async {
    // los tiempos de una versión son inmutables: una vez pedidos, se leen del dispositivo
    final key = 'audio:$slug@$version';
    var j = await _local.read(CachedReads.ns, key);
    if (j == null) {
      j = await _api.getJsonOrNull('/lesen/readings/${Uri.encodeComponent(slug)}/versions/$version/audio');
      if (j == null) return null;
      await _local.write(CachedReads.ns, key, j);
    }
    final assets = j.list('assets', parseAsset);
    return assets.firstOrNull;
  }

  static AudioAsset parseAsset(Json a) {
    final v = a.obj('voice');
    TimedSpan range(Json r) => TimedSpan(r.str('id'), r.integer('startMs'), r.integer('endMs'));
    final timings = <TimedSpan>[];
    for (final t in a.opt<List<dynamic>>('timings') ?? const []) {
      // `[tokenId, inicio, fin]`, compacto
      if (t is List && t.length >= 3 && t[0] is String && t[1] is num && t[2] is num) {
        timings.add(TimedSpan(t[0] as String, (t[1] as num).toInt(), (t[2] as num).toInt()));
      } else {
        throw const ContractException('timings: se esperaba [tokenId, inicio, fin]');
      }
    }
    return AudioAsset(
      id: a.str('id'),
      voice: Voice(id: v.str('id'), name: v.str('name'), language: v.str('language'), license: v.strOrNull('license') ?? ''),
      url: a.str('url'),
      format: a.strOrNull('format') ?? 'audio/mpeg',
      duration: Duration(milliseconds: a.integer('durationMs')),
      origin: a.strOrNull('origin') ?? 'GENERATED',
      words: timings,
      sentences: a.list('sentences', range),
      paragraphs: a.list('paragraphs', range),
    );
  }
}
