/// Progreso de quien lee en una lectura (`GET/PUT readings/{slug}/progress`).
class ReadingProgress {
  const ReadingProgress({
    required this.version,
    required this.position,
    required this.percent,
    required this.secondsRead,
    required this.completed,
    required this.updatedAt,
    this.pending = false,
  });

  final int version;

  /// Id de la oración donde se quedó.
  final String? position;
  final int percent;

  /// Total de segundos leídos (no un incremento).
  final int secondsRead;
  final bool completed;
  final DateTime updatedAt;

  /// Guardado en el dispositivo y aún no confirmado por el servidor.
  final bool pending;

  ReadingProgress copyWith({String? position, int? percent, int? secondsRead, bool? completed, DateTime? updatedAt, bool? pending}) => ReadingProgress(
    version: version,
    position: position ?? this.position,
    percent: percent ?? this.percent,
    secondsRead: secondsRead ?? this.secondsRead,
    completed: completed ?? this.completed,
    updatedAt: updatedAt ?? this.updatedAt,
    pending: pending ?? this.pending,
  );
}

/// Une el progreso local y el del servidor sin pisar lo nuevo con lo viejo (ADR-0007, `offline-strategy.md` §4):
/// la posición del más reciente; porcentaje y segundos, el mayor; terminada si lo está en alguno. Versiones distintas:
/// manda la del servidor salvo que lo local sea posterior.
ReadingProgress? mergeProgress(ReadingProgress? local, ReadingProgress? server) {
  if (local == null) return server;
  if (server == null) return local;
  if (local.version != server.version) return local.updatedAt.isAfter(server.updatedAt) ? local : server;
  final newer = local.updatedAt.isAfter(server.updatedAt) ? local : server;
  return ReadingProgress(
    version: server.version,
    position: newer.position ?? local.position ?? server.position,
    percent: local.percent > server.percent ? local.percent : server.percent,
    secondsRead: local.secondsRead > server.secondsRead ? local.secondsRead : server.secondsRead,
    completed: local.completed || server.completed,
    updatedAt: newer.updatedAt,
    // queda pendiente si lo local aporta algo que el servidor no tiene
    pending: local.pending && (local.percent > server.percent || local.secondsRead > server.secondsRead || newer == local),
  );
}
