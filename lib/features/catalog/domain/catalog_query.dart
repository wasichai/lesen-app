import 'reading.dart';

enum CatalogSort { RECENT, POPULAR, LEVEL, DURATION, TITLE }

enum CatalogStatus { NOT_STARTED, IN_PROGRESS, COMPLETED, BOOKMARKED }

/// Tramos de duración del catálogo, los mismos que la web.
enum DurationRange {
  short(null, 3),
  medium(4, 6),
  long(7, null);

  const DurationRange(this.min, this.max);

  final int? min;
  final int? max;
}

/// Filtros del catálogo (`GET /api/lesen/readings`).
class CatalogQuery {
  const CatalogQuery({this.language, this.levels = const {}, this.topic, this.duration, this.q = '', this.status, this.sort = CatalogSort.RECENT});

  final String? language;
  final Set<CefrLevel> levels;
  final String? topic;
  final DurationRange? duration;
  final String q;
  final CatalogStatus? status;
  final CatalogSort sort;

  /// Cuántos filtros hay activos (sin contar la búsqueda ni el orden), para el botón «Filtros (n)».
  int get activeFilters =>
      (language != null ? 1 : 0) + (levels.isNotEmpty ? 1 : 0) + (topic != null ? 1 : 0) + (duration != null ? 1 : 0) + (status != null ? 1 : 0);

  Map<String, dynamic> toQuery({required int page, int size = 12}) => {
    'language': ?language,
    if (levels.isNotEmpty) 'level': (levels.toList()..sort((a, b) => a.index - b.index)).map((l) => l.name).toList(),
    'topic': ?topic,
    if (duration?.min != null) 'minMinutes': duration!.min,
    if (duration?.max != null) 'maxMinutes': duration!.max,
    if (q.trim().isNotEmpty) 'q': q.trim().length > 64 ? q.trim().substring(0, 64) : q.trim(),
    if (status != null) 'status': status!.name,
    'sort': sort.name,
    'page': page,
    'size': size,
  };

  CatalogQuery copyWith({
    String? Function()? language,
    Set<CefrLevel>? levels,
    String? Function()? topic,
    DurationRange? Function()? duration,
    String? q,
    CatalogStatus? Function()? status,
    CatalogSort? sort,
  }) => CatalogQuery(
    language: language != null ? language() : this.language,
    levels: levels ?? this.levels,
    topic: topic != null ? topic() : this.topic,
    duration: duration != null ? duration() : this.duration,
    q: q ?? this.q,
    status: status != null ? status() : this.status,
    sort: sort ?? this.sort,
  );

  CatalogQuery cleared() => CatalogQuery(q: q, sort: sort);

  @override
  bool operator ==(Object other) =>
      other is CatalogQuery &&
      other.language == language &&
      other.levels.length == levels.length &&
      other.levels.containsAll(levels) &&
      other.topic == topic &&
      other.duration == duration &&
      other.q == q &&
      other.status == status &&
      other.sort == sort;

  @override
  int get hashCode => Object.hash(language, Object.hashAllUnordered(levels), topic, duration, q, status, sort);
}
