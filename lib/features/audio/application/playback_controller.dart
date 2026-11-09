import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/audio/narration_engine.dart';
import '../../../core/networking/api_client.dart';
import '../../../core/storage/local_store.dart';
import '../../catalog/domain/reading.dart';
import '../../reader/domain/reading_content.dart';
import '../domain/audio_asset.dart';
import '../domain/timing_index.dart';

/// El motor de la narración. `main` lo sustituye por el real; las pruebas, por [FakeNarrationEngine].
final narrationEngineProvider = Provider<NarrationEngine>((ref) => throw StateError('narrationEngineProvider se configura en main'));

/// Lo que suena: qué palabra, qué oración y qué párrafo (índice en el contenido).
@immutable
class ActiveSpan {
  const ActiveSpan({required this.paragraph, required this.sentenceId, required this.tokenId});

  final int? paragraph;
  final String? sentenceId;
  final String? tokenId;

  @override
  bool operator ==(Object other) => other is ActiveSpan && other.paragraph == paragraph && other.sentenceId == sentenceId && other.tokenId == tokenId;

  @override
  int get hashCode => Object.hash(paragraph, sentenceId, tokenId);
}

/// Calcula lo activo en `ms` con los tiempos reales (búsqueda binaria; nunca aproximaciones por caracteres).
ActiveSpan? activeSpanAt(AudioAsset asset, ReadingContent content, int ms) {
  final word = asset.words.activeAt(ms);
  final sentence = asset.sentences.activeAt(ms, linger: 1500);
  final sentenceId = sentence?.id ?? (word == null ? null : content.index.sentenceOfToken[word.id]);
  if (word == null && sentenceId == null) return null;
  return ActiveSpan(paragraph: sentenceId == null ? null : content.index.paragraphOfSentence[sentenceId], sentenceId: sentenceId, tokenId: word?.id);
}

class NowPlaying {
  const NowPlaying({required this.reading, required this.content, required this.asset});

  final ReadingCard reading;
  final ReadingContent content;
  final AudioAsset asset;

  String get key => '${content.slug}@${content.version}';
}

@immutable
class PlaybackState {
  const PlaybackState({this.now, this.status = EngineStatus.idle, this.playing = false, this.speed = 1, this.follow = true, this.failed = false});

  final NowPlaying? now;
  final EngineStatus status;
  final bool playing;
  final double speed;

  /// Seguir la lectura: desplazar el texto hasta lo que suena.
  final bool follow;
  final bool failed;

  bool get buffering => status == EngineStatus.loading || status == EngineStatus.buffering;

  PlaybackState copyWith({NowPlaying? Function()? now, EngineStatus? status, bool? playing, double? speed, bool? follow, bool? failed}) => PlaybackState(
    now: now != null ? now() : this.now,
    status: status ?? this.status,
    playing: playing ?? this.playing,
    speed: speed ?? this.speed,
    follow: follow ?? this.follow,
    failed: failed ?? this.failed,
  );
}

final playbackProvider = NotifierProvider<PlaybackController, PlaybackState>(PlaybackController.new);

/// Controla la narración de una lectura. El estado de [PlaybackState] cambia poco (cargar, reproducir, pausar); la
/// posición va por [position] y lo activo por [active], que solo notifica cuando cambia de palabra.
class PlaybackController extends Notifier<PlaybackState> {
  static const speeds = <double>[0.75, 1, 1.25, 1.5];
  static const _ns = 'audio';

  final position = ValueNotifier<Duration>(Duration.zero);
  final active = ValueNotifier<ActiveSpan?>(null);
  late NarrationEngine _engine;
  final _subs = <StreamSubscription<Object?>>[];
  DateTime _lastSaved = DateTime.fromMillisecondsSinceEpoch(0);

  @override
  PlaybackState build() {
    _engine = ref.watch(narrationEngineProvider);
    _engine.onSkip = (step) => paragraph(step);
    _subs
      ..add(_engine.positionStream.listen(_onPosition))
      ..add(_engine.playingStream.listen((p) => state = state.copyWith(playing: p)))
      ..add(
        _engine.statusStream.listen((s) {
          state = state.copyWith(status: s, failed: s == EngineStatus.error);
          if (s == EngineStatus.completed) unawaited(_engine.pause());
        }),
      );
    ref.onDispose(() {
      for (final s in _subs) {
        unawaited(s.cancel());
      }
      position.dispose();
      active.dispose();
    });
    return const PlaybackState();
  }

  NowPlaying? get now => state.now;

  /// Prepara la narración de una lectura (sin reproducir). Si ya es la que suena, no la reinicia.
  Future<void> open({required ReadingCard reading, required ReadingContent content, required AudioAsset asset}) async {
    final next = NowPlaying(reading: reading, content: content, asset: asset);
    if (state.now?.key == next.key) return;
    await _savePosition();
    state = state.copyWith(now: () => next, status: EngineStatus.loading, failed: false);
    active.value = null;
    final config = ref.read(appConfigProvider);
    final saved = await ref.read(localStoreProvider).read(_ns, next.key);
    final start = Duration(milliseconds: (saved?['positionMs'] as num?)?.toInt() ?? 0);
    try {
      await _engine.load(
        Uri.parse(config.resolve(asset.url)),
        media: NarrationMedia(
          id: next.key,
          title: reading.title,
          subtitle: asset.voice.name,
          duration: asset.duration,
          artUri: reading.cover == null ? null : Uri.parse(config.resolve(reading.cover!)),
        ),
        start: start < asset.duration ? start : Duration.zero,
      );
      await _engine.setSpeed(state.speed);
      _onPosition(start);
    } catch (_) {
      state = state.copyWith(status: EngineStatus.error, failed: true);
    }
  }

  Future<void> toggle() => state.playing ? pause() : play();

  Future<void> play() async {
    if (state.now == null) return;
    await _engine.play();
  }

  Future<void> pause() async {
    await _engine.pause();
    await _savePosition();
  }

  Future<void> seekMs(int ms) async {
    final now = state.now;
    if (now == null) return;
    final clamped = ms.clamp(0, now.asset.duration.inMilliseconds);
    await _engine.seek(Duration(milliseconds: clamped));
    _onPosition(Duration(milliseconds: clamped));
  }

  Future<void> skipSeconds(int seconds) => seekMs(_engine.position.inMilliseconds + seconds * 1000);

  Future<void> sentence(int step) => _neighbour((a) => a.sentences, step);

  Future<void> paragraph(int step) => _neighbour((a) => a.paragraphs, step);

  Future<void> _neighbour(TimingIndex Function(AudioAsset) pick, int step) async {
    final now = state.now;
    if (now == null) return;
    final target = pick(now.asset).neighbourStart(_engine.position.inMilliseconds, step);
    if (target != null) await seekMs(target);
  }

  /// Reproduce desde una palabra; si no tiene tiempo (lo dicho y lo escrito no casan), desde su oración.
  Future<void> playFromToken(String tokenId) async {
    final now = state.now;
    if (now == null) return;
    final start = now.asset.words.byId(tokenId)?.startMs ?? now.asset.sentences.byId(now.content.index.sentenceOfToken[tokenId] ?? '')?.startMs;
    if (start == null) return;
    await seekMs(start);
    await play();
  }

  Future<void> playFromSentence(String sentenceId) async {
    final start = state.now?.asset.sentences.byId(sentenceId)?.startMs;
    if (start == null) return;
    await seekMs(start);
    await play();
  }

  Future<void> playParagraph(String paragraphId) async {
    final start = state.now?.asset.paragraphs.byId(paragraphId)?.startMs;
    if (start == null) return;
    await seekMs(start);
    await play();
  }

  Future<void> setSpeed(double speed) async {
    await _engine.setSpeed(speed);
    state = state.copyWith(speed: speed);
  }

  void setFollow(bool value) => state = state.copyWith(follow: value);

  /// Deja de sonar y suelta la lectura (cierra el mini reproductor).
  Future<void> close() async {
    await _savePosition();
    await _engine.stop();
    active.value = null;
    state = state.copyWith(now: () => null, playing: false, status: EngineStatus.idle);
  }

  void _onPosition(Duration d) {
    position.value = d;
    final now = state.now;
    if (now == null) return;
    final next = activeSpanAt(now.asset, now.content, d.inMilliseconds);
    if (next != active.value) active.value = next;
    if (state.playing && DateTime.now().difference(_lastSaved) > const Duration(seconds: 5)) unawaited(_savePosition());
  }

  Future<void> _savePosition() async {
    final now = state.now;
    if (now == null) return;
    _lastSaved = DateTime.now();
    await ref.read(localStoreProvider).write(_ns, now.key, {'positionMs': _engine.position.inMilliseconds});
  }
}
