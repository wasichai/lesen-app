import '../../../core/networking/json.dart';
import '../domain/entry.dart';

abstract final class DictionaryDto {
  static Entry entry(Json j) => Entry(
    key: j.str('key'),
    language: j.str('language'),
    lemma: j.str('lemma'),
    pos: j.strOrNull('pos'),
    ipa: j.strOrNull('ipa'),
    grammar: j.stringMap('grammar'),
    forms: j.strings('forms'),
    senses: j.list(
      'senses',
      (s) => Sense(
        translations: s.strings('translations'),
        definition: s.strOrNull('definition'),
        examples: s.list('examples', (e) => Example(e.str('text'), e.strOrNull('translation'))),
        synonyms: s.strings('synonyms'),
        antonyms: s.strings('antonyms'),
        related: s.list('related', (r) => RelatedWord(r.str('key'), r.str('lemma'))),
        note: s.strOrNull('note'),
      ),
    ),
    favorite: j.boolean('favorite'),
    saved: j.boolean('saved'),
    readings: j.list(
      'readings',
      (r) => EntryReading(slug: r.str('slug'), title: r.str('title'), level: r.strOrNull('level') ?? '', occurrences: r.integerOrNull('occurrences') ?? 0),
    ),
  );

  static EntrySummary summary(Json j) =>
      EntrySummary(key: j.str('key'), language: j.str('language'), lemma: j.str('lemma'), pos: j.strOrNull('pos'), translations: j.strings('translations'));

  static Lookup lookup(Json j) {
    final e = j.objOrNull('entry');
    return Lookup(
      token: j.str('token'),
      tokenRef: j.str('tokenRef'),
      sentenceRef: j.str('sentenceRef'),
      sentence: j.str('sentence'),
      translationLanguage: j.str('translationLanguage'),
      entry: e == null ? null : entry(e),
      inflected: j.boolean('inflected'),
      alternatives: j.list('alternatives', summary),
    );
  }
}
