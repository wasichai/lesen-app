import 'package:flutter_test/flutter_test.dart';
import 'package:lesen/core/networking/json.dart';
import 'package:lesen/core/utilities/ids.dart';
import 'package:lesen/features/comprehension/data/comprehension_repository.dart';
import 'package:lesen/features/comprehension/domain/assessment.dart';
import 'package:lesen/features/dictionary/data/dictionary_dto.dart';
import 'package:lesen/features/vocabulary/data/vocabulary_repository.dart';
import 'package:lesen/features/vocabulary/domain/known_words.dart';
import 'package:lesen/features/vocabulary/domain/vocabulary.dart';
import 'package:lesen/features/vocabulary/presentation/review_screen.dart';

import '../support/notebook_routes.dart';

void main() {
  test('una palabra del cuaderno real se lee con su contexto y su fuente', () {
    final item = VocabularyRepository.item(((notebook['vocabulary'] as Map)['content'] as List).first as Json);
    expect(item.lemma, 'verbringen');
    expect(item.surface, 'verbringt');
    expect(item.status, WordStatus.SAVED);
    expect(item.source!.slug, 'der-alte-leuchtturm');
    expect(item.context, contains('verbringt'));
  });

  test('el repaso trae la fecha que daría cada respuesta', () {
    final card = (notebook['reviewsNext']['cards'] as List).first as Json;
    final preview = card['preview'] as Map;
    expect(preview.keys, containsAll(ReviewRating.values.map((r) => r.name)));
    final easy = DateTime.parse(preview['EASY'] as String);
    final again = DateTime.parse(preview['AGAIN'] as String);
    expect(easy.isAfter(again), isTrue);
  });

  test('búsqueda y entrada del diccionario reales', () {
    final s = DictionaryDto.summary((notebook['search'] as List).first as Json);
    expect(s.translations, ['luz']);
    final e = DictionaryDto.entry(notebook['entry'] as Json);
    expect(e.grammar['gender'], 'n');
  });

  test('las preguntas reales se leen todas, de siete tipos', () {
    final a = ComprehensionRepository.question;
    final qs = (assessmentFixture['questions'] as List).map((q) => a(q as Json)).toList();
    expect(qs.map((q) => q.type).toSet(), hasLength(7));
    expect(qs.every((q) => q.type != QuestionType.unknown), isTrue);
    final completion = qs.firstWhere((q) => q.type == QuestionType.COMPLETION);
    expect(completion.parts.where((p) => p.blank != null), hasLength(2));
    expect(completion.bank, contains('zählt'));
    final matching = qs.firstWhere((q) => q.type == QuestionType.MATCHING);
    expect(matching.left, hasLength(4));
    expect(matching.right.length, greaterThan(4));
  });

  test('un intento real: resumen, corrección por reglas y abierta para autoevaluar', () {
    final attempt = ComprehensionRepository.attempt(attemptFixture);
    expect(attempt.summary.total, 7);
    expect(attempt.summary.correct, 2);
    expect(attempt.summary.ungraded, 1);
    final q1 = attempt.answers.firstWhere((a) => a.questionId == 'q1');
    expect(q1.result, AnswerResult.CORRECT);
    expect(q1.evaluator, Evaluator.RULE);
    expect(q1.refs, ['p2s1']);
    final open = attempt.answers.firstWhere((a) => a.type == QuestionType.SHORT_ANSWER);
    expect(open.result, AnswerResult.UNGRADED);
    expect(open.evaluator, isNull);
    final skills = skillsOf(attempt);
    expect(skills.strong, containsAll([QuestionType.DETAIL, QuestionType.COMPLETION]));
    expect(skills.weak, contains(QuestionType.TRUE_FALSE));
  });

  test('cada tipo de respuesta va con su campo', () {
    expect(const AnswerDraft(options: ['b']).toJson('q1'), {
      'questionId': 'q1',
      'options': ['b'],
    });
    expect(const AnswerDraft(value: false).toJson('q2'), {'questionId': 'q2', 'value': false});
    expect(const AnswerDraft(blanks: {'p2s4t2': 'zählt'}).toJson('q4'), {
      'questionId': 'q4',
      'blanks': {'p2s4t2': 'zählt'},
    });
    expect(const AnswerDraft(text: '  sí  ').toJson('q7'), {'questionId': 'q7', 'text': 'sí'});
    expect(const AnswerDraft(text: '   ').isEmpty, isTrue);
    expect(const AnswerDraft(order: ['a', 'b']).isEmpty, isFalse);
  });

  test('las tres formas de repasar se alternan; sin oración, por significado', () {
    final item = VocabularyRepository.item(((notebook['vocabulary'] as Map)['content'] as List).first as Json);
    final card = ReviewCard(item: item, state: CardState.LEARNING, preview: const {});
    expect(modeFor(card, 0), ReviewMode.meaning);
    expect(modeFor(card, 1), ReviewMode.word);
    expect(modeFor(card, 2), ReviewMode.context);
    final bare = ReviewCard(item: item.withNote(null), state: CardState.LEARNING, preview: const {});
    expect(modeFor(bare, 2), ReviewMode.context);
  });

  test('uuid v4', () {
    final id = uuidV4();
    expect(RegExp(r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$').hasMatch(id), isTrue);
    expect(uuidV4(), isNot(id));
  });
}
