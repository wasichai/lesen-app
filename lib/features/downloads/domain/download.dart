enum DownloadState { queued, downloading, waitingWifi, done, failed, cancelled }

/// Una lectura descargada para leerla y escucharla sin conexión.
class DownloadInfo {
  const DownloadInfo({
    required this.slug,
    required this.version,
    required this.title,
    required this.state,
    this.progress = 0,
    this.bytes = 0,
    this.audioFile,
    this.illustrationFiles = const [],
    this.error,
    this.updatedAt,
  });

  factory DownloadInfo.fromJson(Map<String, dynamic> j) => DownloadInfo(
    slug: j['slug'] as String,
    version: (j['version'] as num).toInt(),
    title: j['title'] as String? ?? j['slug'] as String,
    state: DownloadState.values.where((s) => s.name == j['state']).firstOrNull ?? DownloadState.failed,
    progress: (j['progress'] as num?)?.toDouble() ?? 0,
    bytes: (j['bytes'] as num?)?.toInt() ?? 0,
    audioFile: j['audioFile'] as String?,
    illustrationFiles: (j['illustrationFiles'] as List?)?.whereType<String>().toList(growable: false) ?? const [],
    error: j['error'] as String?,
    updatedAt: j['updatedAt'] == null ? null : DateTime.tryParse(j['updatedAt'] as String),
  );

  final String slug;
  final int version;
  final String title;
  final DownloadState state;

  /// De 0 a 1.
  final double progress;
  final int bytes;

  /// Ruta del audio en el dispositivo, si la lectura tiene narración y ya se descargó.
  final String? audioFile;

  /// Rutas de las ilustraciones entre párrafos guardadas en el dispositivo (ADR-0018 del backend); sus bytes cuentan en
  /// [bytes] y se borran con la descarga.
  final List<String> illustrationFiles;
  final String? error;
  final DateTime? updatedAt;

  bool get active => state == DownloadState.queued || state == DownloadState.downloading;

  /// El texto ya está en el dispositivo (aunque el audio espere al Wi-Fi).
  bool get readableOffline => state == DownloadState.done || state == DownloadState.waitingWifi;

  DownloadInfo copyWith({
    DownloadState? state,
    double? progress,
    int? bytes,
    String? Function()? audioFile,
    List<String>? illustrationFiles,
    String? Function()? error,
  }) => DownloadInfo(
    slug: slug,
    version: version,
    title: title,
    state: state ?? this.state,
    progress: progress ?? this.progress,
    bytes: bytes ?? this.bytes,
    audioFile: audioFile != null ? audioFile() : this.audioFile,
    illustrationFiles: illustrationFiles ?? this.illustrationFiles,
    error: error != null ? error() : this.error,
    updatedAt: DateTime.now().toUtc(),
  );

  Map<String, dynamic> toJson() => {
    'slug': slug,
    'version': version,
    'title': title,
    'state': state.name,
    'progress': progress,
    'bytes': bytes,
    'audioFile': audioFile,
    'illustrationFiles': illustrationFiles,
    'error': error,
    'updatedAt': updatedAt?.toIso8601String(),
  };
}

String formatBytes(int bytes) {
  if (bytes < 1024) return '$bytes B';
  if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(0)} KB';
  return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
}
