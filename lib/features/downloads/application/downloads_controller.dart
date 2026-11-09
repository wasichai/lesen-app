import 'dart:async';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/networking/api_client.dart';
import '../../../core/networking/api_failure.dart';
import '../../../core/storage/files.dart';
import '../../../core/storage/local_store.dart';
import '../../audio/data/audio_repository.dart';
import '../../catalog/application/cover_provider.dart';
import '../../catalog/data/catalog_repository.dart';
import '../../comprehension/data/comprehension_repository.dart';
import '../../reader/data/reader_repository.dart';
import '../domain/download.dart';

/// Preferencias de la app en el dispositivo (no del lector).
final appPrefsProvider = NotifierProvider<AppPrefsController, Map<String, dynamic>>(AppPrefsController.new);

class AppPrefsController extends Notifier<Map<String, dynamic>> {
  @override
  Map<String, dynamic> build() {
    unawaited(ref.read(localStoreProvider).read('prefs', 'app').then((v) => v == null || !ref.mounted ? null : state = v));
    return const {'wifiOnly': true};
  }

  bool get wifiOnly => state['wifiOnly'] as bool? ?? true;

  Future<void> set(String key, Object? value) async {
    state = {...state, key: value};
    await ref.read(localStoreProvider).write('prefs', 'app', state);
  }
}

/// `true` si la red actual no cuesta datos móviles.
typedef WifiCheck = Future<bool> Function();

final wifiCheckProvider = Provider<WifiCheck>(
  (ref) => () async {
    final r = await Connectivity().checkConnectivity();
    return r.contains(ConnectivityResult.wifi) || r.contains(ConnectivityResult.ethernet);
  },
);

final downloadsProvider = NotifierProvider<DownloadsController, Map<String, DownloadInfo>>(DownloadsController.new);

/// Descarga lo que una lectura necesita sin conexión: ficha, contenido, traducciones, preguntas, portada, tiempos y
/// audio. Todo lo de una versión es inmutable, así que se guarda una vez (ADR-0007, ADR-0010).
class DownloadsController extends Notifier<Map<String, DownloadInfo>> {
  static const ns = 'downloads';
  final _cancels = <String, CancelToken>{};

  @override
  Map<String, DownloadInfo> build() {
    unawaited(_load());
    return const {};
  }

  Future<void> _load() async {
    final all = await ref.read(localStoreProvider).all(ns);
    if (!ref.mounted) return;
    state = {
      for (final (slug, j) in all)
        // una descarga cortada al cerrar la app se marca como fallida para poder reintentarla
        slug: (() {
          final d = DownloadInfo.fromJson(j);
          return d.active ? d.copyWith(state: DownloadState.failed, error: () => 'interrumpida') : d;
        })(),
    };
  }

  int get totalBytes => state.values.fold(0, (a, d) => a + d.bytes);

  Future<void> _put(DownloadInfo d) async {
    state = {...state, d.slug: d};
    await ref.read(localStoreProvider).write(ns, d.slug, d.toJson());
  }

  Future<void> download(String slug) async {
    if (state[slug]?.active ?? false) return;
    final cancel = CancelToken();
    _cancels[slug] = cancel;
    final catalog = ref.read(catalogRepositoryProvider);
    try {
      final detail = await catalog.detail(slug);
      final version = detail.reading.version;
      var d = DownloadInfo(slug: slug, version: version, title: detail.reading.title, state: DownloadState.downloading, progress: 0.05);
      await _put(d);
      final reader = ref.read(readerRepositoryProvider);
      await reader.content(slug, version);
      await reader.translations(slug, version, TranslationUnit.SENTENCE);
      await reader.translations(slug, version, TranslationUnit.PARAGRAPH);
      await ref.read(comprehensionRepositoryProvider).assessment(slug, version);
      if (detail.reading.cover != null) await loadCover(ref, detail.reading.cover!);
      await _put(d = d.copyWith(progress: 0.2));
      if (cancel.isCancelled) return;

      final audio = await ref.read(audioRepositoryProvider).audio(slug, version);
      if (audio == null) {
        await _put(d.copyWith(state: DownloadState.done, progress: 1));
        return;
      }
      final wifiOnly = ref.read(appPrefsProvider.notifier).wifiOnly;
      if (wifiOnly && !await ref.read(wifiCheckProvider)()) {
        await _put(d.copyWith(state: DownloadState.waitingWifi));
        return;
      }
      final dir = await ref.read(filesDirProvider.future);
      if (dir == null) throw const UnknownFailure('sin almacenamiento');
      final file = File('${dir.path}/audio/${safeFileName('$slug@$version')}${_extension(audio.format)}');
      await file.parent.create(recursive: true);
      final partial = File('${file.path}.part');
      await ref
          .read(dioProvider)
          .download(
            ref.read(appConfigProvider).resolve(audio.url),
            partial.path,
            cancelToken: cancel,
            onReceiveProgress: (got, total) {
              if (total <= 0) return;
              final p = 0.2 + 0.8 * got / total;
              // como mucho una actualización por cada 2 %
              if (p - (state[slug]?.progress ?? 0) >= 0.02) state = {...state, slug: state[slug]!.copyWith(progress: p, bytes: got)};
            },
          );
      await partial.rename(file.path);
      await _put(d.copyWith(state: DownloadState.done, progress: 1, bytes: await file.length(), audioFile: () => file.path));
    } on DioException catch (e) {
      final current = state[slug];
      if (current == null) return;
      await _put(current.copyWith(state: CancelToken.isCancel(e) ? DownloadState.cancelled : DownloadState.failed, error: () => ApiFailure.from(e).toString()));
    } on ApiFailure catch (e) {
      final current = state[slug];
      if (current != null) await _put(current.copyWith(state: DownloadState.failed, error: () => e.toString()));
    } finally {
      _cancels.remove(slug);
    }
  }

  void cancel(String slug) => _cancels[slug]?.cancel();

  /// Quita la descarga y su audio. El texto cacheado se queda (pesa poco y es inmutable).
  Future<void> remove(String slug) async {
    cancel(slug);
    final d = state[slug];
    if (d?.audioFile != null) {
      final f = File(d!.audioFile!);
      if (f.existsSync()) await f.delete();
    }
    state = {...state}..remove(slug);
    await ref.read(localStoreProvider).delete(ns, slug);
  }

  /// El archivo de audio en el dispositivo, si existe.
  String? localAudio(String slug, int version) {
    final d = state[slug];
    if (d == null || d.version != version || d.audioFile == null) return null;
    return File(d.audioFile!).existsSync() ? d.audioFile : null;
  }

  static String _extension(String format) => switch (format) {
    'audio/ogg' => '.ogg',
    'audio/mp4' || 'audio/m4a' || 'audio/x-m4a' => '.m4a',
    _ => '.mp3',
  };
}
