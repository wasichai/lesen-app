class Example {
  const Example(this.text, this.translation);

  final String text;
  final String? translation;
}

class RelatedWord {
  const RelatedWord(this.key, this.lemma);

  final String key;
  final String lemma;
}

class Sense {
  const Sense({
    required this.translations,
    required this.definition,
    required this.examples,
    required this.synonyms,
    required this.antonyms,
    required this.related,
    required this.note,
  });

  final List<String> translations;
  final String? definition;
  final List<Example> examples;
  final List<String> synonyms;
  final List<String> antonyms;
  final List<RelatedWord> related;
  final String? note;
}

class EntryReading {
  const EntryReading({required this.slug, required this.title, required this.level, required this.occurrences});

  final String slug;
  final String title;
  final String level;
  final int occurrences;
}

/// Una entrada del diccionario bilingüe, en el idioma de traducción pedido. Sin entrada, no se inventa nada.
class Entry {
  const Entry({
    required this.key,
    required this.language,
    required this.lemma,
    required this.pos,
    required this.ipa,
    required this.grammar,
    required this.forms,
    required this.senses,
    required this.favorite,
    required this.saved,
    required this.readings,
  });

  final String key;
  final String language;
  final String lemma;

  /// Categoría gramatical tal como la da el backend (`noun`, `verb`, `proper-noun`…).
  final String? pos;
  final String? ipa;

  /// Rasgos propios del idioma (género, plural, auxiliar…): un mapa, porque no todas las lenguas tienen los mismos.
  final Map<String, String> grammar;
  final List<String> forms;
  final List<Sense> senses;
  final bool favorite;
  final bool saved;
  final List<EntryReading> readings;

  List<String> get translations => senses.expand((s) => s.translations).toSet().toList();
}

class EntrySummary {
  const EntrySummary({required this.key, required this.language, required this.lemma, required this.pos, required this.translations});

  final String key;
  final String language;
  final String lemma;
  final String? pos;
  final List<String> translations;
}

/// Lo que devuelve tocar una palabra en una lectura (`dictionary/lookup`).
class Lookup {
  const Lookup({
    required this.token,
    required this.tokenRef,
    required this.sentenceRef,
    required this.sentence,
    required this.translationLanguage,
    required this.entry,
    required this.inflected,
    required this.alternatives,
  });

  final String token;
  final String tokenRef;
  final String sentenceRef;
  final String sentence;
  final String translationLanguage;
  final Entry? entry;

  /// Si la palabra del texto es una forma flexionada del lema.
  final bool inflected;
  final List<EntrySummary> alternatives;
}
