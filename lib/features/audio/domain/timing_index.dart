/// Un tramo de audio de una palabra, oración o párrafo.
class TimedSpan {
  const TimedSpan(this.id, this.startMs, this.endMs);

  final String id;
  final int startMs;
  final int endMs;
}

/// Tramos ordenados por inicio, con búsqueda binaria: `O(log n)` por cada evento de posición del reproductor.
class TimingIndex {
  TimingIndex(List<TimedSpan> spans) : _spans = [...spans]..sort((a, b) => a.startMs.compareTo(b.startMs)) {
    for (var i = 0; i < _spans.length; i++) {
      _at[_spans[i].id] = i;
    }
  }

  /// Lo que una palabra sigue resaltada tras terminar, para que el resaltado no parpadee en las pausas cortas
  /// (`LINGER_MS` de la web).
  static const lingerMs = 250;

  final List<TimedSpan> _spans;
  final _at = <String, int>{};

  int get length => _spans.length;
  bool get isEmpty => _spans.isEmpty;
  TimedSpan operator [](int i) => _spans[i];

  TimedSpan? byId(String id) {
    final i = _at[id];
    return i == null ? null : _spans[i];
  }

  int? indexOf(String id) => _at[id];

  /// El último tramo que empezó en o antes de `ms`, o -1.
  int lastStartedAt(int ms) {
    var lo = 0;
    var hi = _spans.length - 1;
    var found = -1;
    while (lo <= hi) {
      final mid = (lo + hi) >> 1;
      if (_spans[mid].startMs <= ms) {
        found = mid;
        lo = mid + 1;
      } else {
        hi = mid - 1;
      }
    }
    return found;
  }

  /// El tramo activo en `ms`: el último que empezó, si no terminó hace más de [linger] ms.
  TimedSpan? activeAt(int ms, {int linger = lingerMs}) {
    final i = lastStartedAt(ms);
    if (i < 0) return null;
    final s = _spans[i];
    return ms <= s.endMs + linger ? s : null;
  }

  /// El tramo que contiene `ms` o el último antes; para oraciones y párrafos, que cubren las pausas entre palabras.
  TimedSpan? currentOrPrevious(int ms) {
    final i = lastStartedAt(ms);
    return i < 0 ? null : _spans[i];
  }

  /// El inicio del tramo siguiente o anterior al de `ms` (navegación por oración y párrafo).
  ///
  /// Hacia atrás, como en los reproductores: si ya se oyó más de un segundo del actual, vuelve a su inicio.
  int? neighbourStart(int ms, int step) {
    if (_spans.isEmpty) return null;
    final i = lastStartedAt(ms);
    if (step > 0) {
      final next = i + 1;
      return next < _spans.length ? _spans[next].startMs : null;
    }
    if (i >= 0 && ms - _spans[i].startMs > 1000) return _spans[i].startMs;
    final prev = i - 1;
    return prev >= 0 ? _spans[prev].startMs : 0;
  }
}
