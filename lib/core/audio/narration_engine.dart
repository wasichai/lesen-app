import 'dart:async';

enum EngineStatus { idle, loading, buffering, ready, completed, error }

/// Lo que la sesión del sistema muestra (pantalla de bloqueo, notificación, centro de control).
class NarrationMedia {
  const NarrationMedia({required this.id, required this.title, required this.subtitle, required this.duration, this.artUri});

  final String id;
  final String title;
  final String subtitle;
  final Duration duration;
  final Uri? artUri;
}

/// El reproductor de la narración, detrás de una interfaz con dos usos: just_audio dentro de audio_service en la app
/// (ADR-0006) y uno simulado en las pruebas.
abstract interface class NarrationEngine {
  Stream<Duration> get positionStream;
  Stream<EngineStatus> get statusStream;
  Stream<bool> get playingStream;
  Duration get position;
  bool get playing;

  /// Carga una URL (streaming con rangos) o un archivo local, en la posición `start`, sin reproducir.
  Future<void> load(Uri source, {required NarrationMedia media, Duration start = Duration.zero, Map<String, String> headers = const {}});
  Future<void> play();
  Future<void> pause();
  Future<void> seek(Duration position);
  Future<void> setSpeed(double speed);
  Future<void> stop();

  /// Lo que hacen los botones «siguiente» y «anterior» del sistema y de los auriculares.
  set onSkip(void Function(int step)? handler);
}

/// Un motor simulado para pruebas: el tiempo avanza solo cuando la prueba lo dice.
class FakeNarrationEngine implements NarrationEngine {
  final _position = StreamController<Duration>.broadcast();
  final _status = StreamController<EngineStatus>.broadcast();
  final _playing = StreamController<bool>.broadcast();
  Duration _at = Duration.zero;
  bool _isPlaying = false;
  double speed = 1;
  Uri? loaded;
  NarrationMedia? media;
  void Function(int step)? skip;

  @override
  Stream<Duration> get positionStream => _position.stream;
  @override
  Stream<EngineStatus> get statusStream => _status.stream;
  @override
  Stream<bool> get playingStream => _playing.stream;
  @override
  Duration get position => _at;
  @override
  bool get playing => _isPlaying;

  /// Simula que la narración llega a `to`.
  void advanceTo(Duration to) {
    _at = to;
    _position.add(to);
  }

  @override
  Future<void> load(Uri source, {required NarrationMedia media, Duration start = Duration.zero, Map<String, String> headers = const {}}) async {
    loaded = source;
    this.media = media;
    _at = start;
    _status.add(EngineStatus.ready);
  }

  @override
  Future<void> play() async {
    _isPlaying = true;
    _playing.add(true);
  }

  @override
  Future<void> pause() async {
    _isPlaying = false;
    _playing.add(false);
  }

  @override
  Future<void> seek(Duration position) async => advanceTo(position);

  @override
  Future<void> setSpeed(double speed) async => this.speed = speed;

  @override
  Future<void> stop() async {
    await pause();
    loaded = null;
    _status.add(EngineStatus.idle);
  }

  @override
  set onSkip(void Function(int step)? handler) => skip = handler;
}
