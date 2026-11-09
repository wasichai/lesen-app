/// Niveles MCER, en orden.
enum CefrLevel { A1, A2, B1, B2, C1, C2 }

CefrLevel? cefrOf(String? code) {
  for (final l in CefrLevel.values) {
    if (l.name == code) return l;
  }
  return null;
}

class ReadingProgressSummary {
  const ReadingProgressSummary({required this.percent, required this.version, required this.completed, required this.updatedAt});

  final int percent;
  final int version;
  final bool completed;
  final DateTime? updatedAt;
}

/// Tarjeta de una lectura publicada, tal como la ve quien pregunta.
class ReadingCard {
  const ReadingCard({
    required this.slug,
    required this.language,
    required this.level,
    required this.topics,
    required this.featured,
    required this.version,
    required this.title,
    required this.subtitle,
    required this.summary,
    required this.cover,
    required this.accent,
    required this.wordCount,
    required this.minutes,
    required this.publishedAt,
    required this.bookmarked,
    required this.progress,
    required this.readers,
  });

  final String slug;
  final String language;
  final CefrLevel level;
  final List<String> topics;
  final bool featured;
  final int version;
  final String title;
  final String? subtitle;
  final String summary;

  /// URL relativa al origen del backend (`/api/lesen/public/covers/…`); se resuelve con `AppConfig.resolve`.
  final String? cover;
  final String? accent;
  final int wordCount;
  final int minutes;
  final DateTime? publishedAt;
  final bool bookmarked;
  final ReadingProgressSummary? progress;
  final int readers;

  bool get started => progress != null && !progress!.completed;
  bool get completed => progress?.completed ?? false;
}

class ReadingDetail {
  const ReadingDetail({required this.reading, required this.paragraphs, required this.related, required this.collections});

  final ReadingCard reading;
  final int paragraphs;
  final List<ReadingCard> related;
  final List<String> collections;
}

enum RecommendationReason { LEVEL, COMPREHENSION, TOPIC, HISTORY, NEW, TRENDING, unknown }

class Recommendation {
  const Recommendation(this.reading, this.reasons);

  final ReadingCard reading;
  final List<RecommendationReason> reasons;
}

class Collection {
  const Collection({required this.slug, required this.labels, required this.descriptions, required this.readings});

  final String slug;
  final Map<String, String> labels;
  final Map<String, String> descriptions;
  final List<ReadingCard> readings;
}

class TopicCount {
  const TopicCount(this.slug, this.readings);

  final String slug;
  final int readings;
}

class Discover {
  const Discover({
    required this.continueReading,
    required this.featured,
    required this.recommended,
    required this.thisWeek,
    required this.fresh,
    required this.collections,
    required this.topics,
  });

  final List<ReadingCard> continueReading;
  final List<ReadingCard> featured;
  final List<Recommendation> recommended;
  final List<(ReadingCard, int)> thisWeek;
  final List<ReadingCard> fresh;
  final List<Collection> collections;
  final List<TopicCount> topics;

  bool get isEmpty => featured.isEmpty && recommended.isEmpty && fresh.isEmpty && continueReading.isEmpty && collections.isEmpty;
}

/// Un tema del árbol, con su nombre en cada idioma de interfaz.
class Topic {
  const Topic({required this.slug, required this.labels, required this.children});

  final String slug;
  final Map<String, String> labels;
  final List<Topic> children;

  String label(String locale) => labels[locale] ?? labels['en'] ?? slug;
}

class Language {
  const Language({required this.code, required this.nativeName, required this.interfaceLanguage, required this.study});

  final String code;
  final String nativeName;
  final bool interfaceLanguage;
  final bool study;
}

class LanguageCatalog {
  const LanguageCatalog({required this.languages, required this.wordsPerMinute});

  final List<Language> languages;
  final Map<CefrLevel, int> wordsPerMinute;

  Iterable<Language> get interfaceLanguages => languages.where((l) => l.interfaceLanguage);
  Iterable<Language> get studyLanguages => languages.where((l) => l.study);

  String nameOf(String code) => languages.where((l) => l.code == code).map((l) => l.nativeName).firstOrNull ?? code.toUpperCase();
}
