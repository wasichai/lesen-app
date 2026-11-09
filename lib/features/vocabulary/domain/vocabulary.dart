import 'known_words.dart';

class VocabularySource {
  const VocabularySource({required this.slug, required this.title, required this.version});

  final String slug;
  final String title;
  final int version;
}

/// Una palabra del cuaderno, con la oración donde se encontró.
class VocabularyItem {
  const VocabularyItem({
    required this.id,
    required this.entryKey,
    required this.lemma,
    required this.pos,
    required this.language,
    required this.translations,
    required this.surface,
    required this.context,
    required this.tokenRef,
    required this.source,
    required this.status,
    required this.note,
    required this.savedAt,
    required this.dueAt,
    required this.reviews,
  });

  final String id;
  final String entryKey;
  final String lemma;
  final String? pos;
  final String language;
  final List<String> translations;

  /// La forma en que apareció en el texto (`verbringt`).
  final String surface;
  final String? context;
  final String? tokenRef;
  final VocabularySource? source;
  final WordStatus status;
  final String? note;
  final DateTime? savedAt;
  final DateTime? dueAt;
  final int reviews;

  bool isDue(DateTime now) => dueAt != null && !dueAt!.isAfter(now);

  VocabularyItem withNote(String? value) => VocabularyItem(
    id: id,
    entryKey: entryKey,
    lemma: lemma,
    pos: pos,
    language: language,
    translations: translations,
    surface: surface,
    context: context,
    tokenRef: tokenRef,
    source: source,
    status: status,
    note: value,
    savedAt: savedAt,
    dueAt: dueAt,
    reviews: reviews,
  );
}

enum ReviewRating { AGAIN, HARD, GOOD, EASY }

enum CardState { LEARNING, REVIEW, RELEARNING, unknown }

/// Una tarjeta del repaso: la palabra, su fase FSRS y la próxima fecha que daría cada respuesta (la calcula el backend,
/// ADR-0010 del backend; el cliente no decide intervalos).
class ReviewCard {
  const ReviewCard({required this.item, required this.state, required this.preview});

  final VocabularyItem item;
  final CardState state;
  final Map<ReviewRating, DateTime> preview;
}

class ReviewQueue {
  const ReviewQueue({required this.cards, required this.due, required this.nextDueAt});

  final List<ReviewCard> cards;
  final int due;
  final DateTime? nextDueAt;
}

class VocabularyStats {
  const VocabularyStats({required this.total, required this.byStatus, required this.dueNow, required this.reviewedToday, required this.encountered});

  final int total;
  final Map<WordStatus, int> byStatus;
  final int dueNow;
  final int reviewedToday;
  final int encountered;
}
