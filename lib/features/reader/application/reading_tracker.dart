import 'dart:async';

import '../data/reader_repository.dart';
import '../domain/reading_content.dart';
import '../domain/reading_progress.dart';

/// Lleva la posición y el tiempo de una sesión de lectura y los guarda: siempre en el dispositivo, y en el servidor con
/// una pausa de [debounce] tras cada cambio, al salir y al pasar la app a segundo plano. Sin red no se pierde nada: queda
/// en el dispositivo y en la cola de operaciones (ADR-0007).
class ReadingTracker {
  ReadingTracker({
    required this.repository,
    required this.content,
    required ReadingProgress? initial,
    this.debounce = const Duration(milliseconds: 1500),
    DateTime Function()? clock,
  }) : _clock = clock ?? DateTime.now,
       _position = initial?.position,
       _storedSeconds = initial?.secondsRead ?? 0,
       _percent = initial?.percent ?? 0,
       _completed = initial?.completed ?? false;

  final ReaderRepository repository;
  final ReadingContent content;
  final Duration debounce;
  final DateTime Function() _clock;

  String? _position;
  int _percent;
  bool _completed;
  final int _storedSeconds;
  final _watch = Stopwatch();
  Timer? _timer;
  bool _dirty = false;
  Future<void>? _saving;

  String? get position => _position;
  int get percent => _percent;
  bool get completed => _completed;
  int get secondsRead => _storedSeconds + _watch.elapsed.inSeconds;

  /// El tiempo cuenta solo mientras la lectura está en pantalla y la app en primer plano.
  void resume() => _watch.start();

  void pause() {
    _watch.stop();
    unawaited(flush());
  }

  /// Quien lee está ahora en esta oración. El porcentaje nunca baja (como en el backend).
  void moveTo(String sentenceId) {
    if (sentenceId == _position || content.index.sentenceAt[sentenceId] == null) return;
    _position = sentenceId;
    final p = content.index.percentAt(sentenceId);
    if (p > _percent) _percent = p;
    _dirty = true;
    _timer?.cancel();
    _timer = Timer(debounce, () => unawaited(flush()));
  }

  ReadingProgress snapshot() => ReadingProgress(
    version: content.version,
    position: _position,
    percent: _percent,
    secondsRead: secondsRead,
    completed: _completed,
    updatedAt: _clock().toUtc(),
  );

  /// Guarda ya en el dispositivo y encola el envío (la cola lo manda cuando hay red).
  Future<void> flush() async {
    _timer?.cancel();
    if (!_dirty && _watch.elapsed.inSeconds == 0) return;
    await _saving;
    _dirty = false;
    final save = repository.saveProgress(content.slug, snapshot());
    _saving = save.then((_) {}, onError: (_) {});
    await save;
  }

  /// Termina la lectura: al momento en el dispositivo y, por la cola, en el servidor.
  Future<ReadingProgress> complete() async {
    _timer?.cancel();
    await _saving;
    _completed = true;
    _percent = 100;
    return repository.complete(content.slug, snapshot());
  }

  void dispose() {
    _watch.stop();
    _timer?.cancel();
    if (_dirty || _watch.elapsed.inSeconds > 0) unawaited(flush());
  }
}
