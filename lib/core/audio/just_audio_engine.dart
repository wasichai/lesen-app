import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:audio_session/audio_session.dart';
import 'package:just_audio/just_audio.dart';

import 'narration_engine.dart';

/// El motor real: just_audio para reproducir y audio_service para la sesión del sistema. Vive fuera del árbol de
/// widgets (se crea al arrancar), así que reconstruir una pantalla nunca reinicia la narración (ADR-0006).
class LesenAudioHandler extends BaseAudioHandler with SeekHandler implements NarrationEngine {
  LesenAudioHandler() {
    _player.playbackEventStream.listen(_broadcast, onError: (Object _, StackTrace _) => _status.add(EngineStatus.error));
    _player.playerStateStream.listen((s) {
      _status.add(switch (s.processingState) {
        ProcessingState.idle => EngineStatus.idle,
        ProcessingState.loading => EngineStatus.loading,
        ProcessingState.buffering => EngineStatus.buffering,
        ProcessingState.ready => EngineStatus.ready,
        ProcessingState.completed => EngineStatus.completed,
      });
    });
  }

  /// Configura la sesión de audio (voz hablada: se baja ante avisos, se pausa ante llamadas) y registra el servicio.
  static Future<LesenAudioHandler> start() async {
    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration.speech());
    final handler = await AudioService.init(
      builder: LesenAudioHandler.new,
      config: const AudioServiceConfig(
        androidNotificationChannelId: 'com.wasichai.lesen.narration',
        androidNotificationChannelName: 'Narración',
        androidNotificationOngoing: true,
        androidStopForegroundOnPause: true,
        fastForwardInterval: Duration(seconds: 5),
        rewindInterval: Duration(seconds: 5),
      ),
    );
    // al desconectar los auriculares, se pausa (no se pone a sonar por el altavoz)
    session.becomingNoisyEventStream.listen((_) => handler.pause());
    return handler;
  }

  final _player = AudioPlayer();
  final _status = StreamController<EngineStatus>.broadcast();
  void Function(int step)? _skip;

  @override
  Stream<Duration> get positionStream =>
      _player.createPositionStream(steps: 2000, minPeriod: const Duration(milliseconds: 40), maxPeriod: const Duration(milliseconds: 120));
  @override
  Stream<EngineStatus> get statusStream => _status.stream;
  @override
  Stream<bool> get playingStream => _player.playingStream;
  @override
  Duration get position => _player.position;
  @override
  bool get playing => _player.playing;

  @override
  set onSkip(void Function(int step)? handler) => _skip = handler;

  @override
  Future<void> load(Uri source, {required NarrationMedia media, Duration start = Duration.zero, Map<String, String> headers = const {}}) async {
    mediaItem.add(MediaItem(id: media.id, title: media.title, artist: media.subtitle, duration: media.duration, artUri: media.artUri));
    final AudioSource audio = source.isScheme('file') ? AudioSource.file(source.toFilePath()) : AudioSource.uri(source, headers: headers);
    await _player.setAudioSource(audio, initialPosition: start);
  }

  @override
  Future<void> play() => _player.play();
  @override
  Future<void> pause() => _player.pause();
  @override
  Future<void> seek(Duration position) => _player.seek(position);
  @override
  Future<void> setSpeed(double speed) async {
    await _player.setSpeed(speed);
    _broadcast(_player.playbackEvent);
  }

  @override
  Future<void> stop() async {
    await _player.stop();
    await super.stop();
  }

  @override
  Future<void> skipToNext() async => _skip?.call(1);
  @override
  Future<void> skipToPrevious() async => _skip?.call(-1);

  void _broadcast(PlaybackEvent event) {
    final playing = _player.playing;
    playbackState.add(
      playbackState.value.copyWith(
        controls: [
          MediaControl.skipToPrevious,
          MediaControl.rewind,
          if (playing) MediaControl.pause else MediaControl.play,
          MediaControl.fastForward,
          MediaControl.skipToNext,
        ],
        systemActions: const {MediaAction.seek, MediaAction.seekForward, MediaAction.seekBackward},
        androidCompactActionIndices: const [1, 2, 3],
        processingState: switch (_player.processingState) {
          ProcessingState.idle => AudioProcessingState.idle,
          ProcessingState.loading => AudioProcessingState.loading,
          ProcessingState.buffering => AudioProcessingState.buffering,
          ProcessingState.ready => AudioProcessingState.ready,
          ProcessingState.completed => AudioProcessingState.completed,
        },
        playing: playing,
        updatePosition: _player.position,
        bufferedPosition: _player.bufferedPosition,
        speed: _player.speed,
        queueIndex: event.currentIndex,
      ),
    );
  }
}
