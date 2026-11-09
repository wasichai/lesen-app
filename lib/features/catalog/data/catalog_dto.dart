import '../../../core/networking/api_failure.dart';
import '../../../core/networking/json.dart';
import '../domain/reading.dart';

/// Conversión de las respuestas del catálogo a modelos de dominio (ADR-0004).
abstract final class CatalogDto {
  static ReadingCard card(Json j) {
    final level = cefrOf(j.strOrNull('level'));
    if (level == null) throw ContractException('level: "${j['level']}" no es un nivel MCER');
    final p = j.objOrNull('progress');
    return ReadingCard(
      slug: j.str('slug'),
      language: j.str('language'),
      level: level,
      topics: j.strings('topics'),
      featured: j.boolean('featured'),
      version: j.integer('version'),
      title: j.str('title'),
      subtitle: j.strOrNull('subtitle'),
      summary: j.strOrNull('summary') ?? '',
      cover: j.strOrNull('cover'),
      accent: j.strOrNull('accent'),
      wordCount: j.integerOrNull('wordCount') ?? 0,
      minutes: j.integerOrNull('minutes') ?? 1,
      publishedAt: j.dateOrNull('publishedAt'),
      bookmarked: j.boolean('bookmarked'),
      progress: p == null
          ? null
          : ReadingProgressSummary(
              percent: p.integerOrNull('percent') ?? 0,
              version: p.integerOrNull('version') ?? j.integer('version'),
              completed: p.boolean('completed'),
              updatedAt: p.dateOrNull('updatedAt'),
            ),
      readers: j.integerOrNull('readers') ?? 0,
    );
  }

  static ReadingDetail detail(Json j) => ReadingDetail(
    reading: card(j.obj('reading')),
    paragraphs: j.integerOrNull('paragraphs') ?? 0,
    related: j.list('related', card),
    collections: j.strings('collections'),
  );

  static Discover discover(Json j) => Discover(
    continueReading: j.list('continueReading', card),
    featured: j.list('featured', card),
    recommended: j.list(
      'recommended',
      (r) => Recommendation(
        card(r.obj('reading')),
        r.strings('reasons').map((e) => enumByName(RecommendationReason.values, e, RecommendationReason.unknown)).toList(),
      ),
    ),
    thisWeek: j.list('thisWeek', (r) => (card(r.obj('reading')), r.integerOrNull('readers') ?? 0)),
    fresh: j.list('fresh', card),
    collections: j.list(
      'collections',
      (c) => Collection(slug: c.str('slug'), labels: c.stringMap('labels'), descriptions: c.stringMap('descriptions'), readings: c.list('readings', card)),
    ),
    topics: j.list('topics', (t) => TopicCount(t.str('slug'), t.integerOrNull('readings') ?? 0)),
  );

  static Topic topic(Json j) => Topic(slug: j.str('slug'), labels: j.stringMap('labels'), children: j.list('children', topic));

  static LanguageCatalog languages(Json j) => LanguageCatalog(
    languages: j.list(
      'languages',
      (l) => Language(code: l.str('code'), nativeName: l.str('nativeName'), interfaceLanguage: l.boolean('interfaceLanguage'), study: l.boolean('study')),
    ),
    wordsPerMinute: {
      for (final l in j.list('levels', (l) => l))
        if (cefrOf(l.strOrNull('code')) != null) cefrOf(l.str('code'))!: l.integerOrNull('wordsPerMinute') ?? 100,
    },
  );
}
