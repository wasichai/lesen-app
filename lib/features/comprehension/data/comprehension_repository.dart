import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/networking/api_client.dart';
import '../../../core/networking/api_failure.dart';
import '../../../core/networking/json.dart';
import '../../../core/storage/cache.dart';
import '../../../core/storage/local_store.dart';
import '../../../core/sync/outbox.dart';
import '../../../core/sync/sync.dart';
import '../domain/assessment.dart';

final comprehensionRepositoryProvider = Provider<ComprehensionRepository>(
  (ref) => ComprehensionRepository(ref.watch(apiProvider), ref.watch(localStoreProvider), ref.watch(outboxProvider)),
);

class ComprehensionRepository {
  ComprehensionRepository(this._api, this._local, this._outbox);

  final Api _api;
  final LocalStore _local;
  final Outbox _outbox;

  /// Las preguntas de una versión, sin respuestas; `null` si no tiene (404).
  Future<Assessment?> assessment(String slug, int version) async {
    final j = await _local.networkFirst(
      'assessment:$slug@$version',
      () async => await _api.getJsonOrNull('/lesen/readings/${Uri.encodeComponent(slug)}/versions/$version/assessment') ?? const {'none': true},
    );
    if (j['none'] == true) return null;
    final last = j.objOrNull('lastAttempt');
    return Assessment(
      id: j['id'].toString(),
      slug: j.str('slug'),
      version: j.integer('version'),
      language: j.str('language'),
      questions: j.list('questions', question),
      lastAttempt: last == null ? null : summary(last),
    );
  }

  /// Envía las respuestas; el backend corrige lo cerrado al momento y lo abierto queda pendiente o para autoevaluar.
  /// Sin red, el intento queda en la cola y devuelve `null`: se envía y se corrige al volver la conexión (el cliente
  /// nunca corrige, ADR-0009 del backend).
  Future<Attempt?> submit(Assessment assessment, Map<String, AnswerDraft> answers) async {
    final body = {
      'answers': [for (final e in answers.entries) e.value.toJson(e.key)],
    };
    try {
      final j = await _api.send('POST', '/lesen/assessments/${Uri.encodeComponent(assessment.id)}/attempts', body: body);
      return attempt(j!);
    } on ApiFailure catch (e) {
      if (e is! OfflineFailure && e is! TimeoutFailure) rethrow;
      await _outbox.enqueue(Ops.attempt, {'assessmentId': assessment.id, 'slug': assessment.slug, 'version': assessment.version, 'body': body});
      return null;
    }
  }

  Future<Attempt> fetch(String attemptId) async => attempt(await _api.getJson('/lesen/attempts/${Uri.encodeComponent(attemptId)}'));

  Future<Attempt> selfAssess(String attemptId, String questionId, AnswerResult result) async => attempt(
    (await _api.send(
      'POST',
      '/lesen/attempts/${Uri.encodeComponent(attemptId)}/answers/${Uri.encodeComponent(questionId)}/self-assessment',
      body: {'result': result.name},
    ))!,
  );

  static QuestionType type(String? name) => QuestionType.values.where((t) => t.name == name).firstOrNull ?? QuestionType.unknown;

  static Choice choice(Json c) => Choice(id: c['id'].toString(), text: c.str('text'), lang: c.strOrNull('lang'));

  static Question question(Json q) {
    final word = q.objOrNull('word');
    final completion = q.objOrNull('completion');
    return Question(
      id: q.str('id'),
      type: type(q.strOrNull('type')),
      difficulty: q.integerOrNull('difficulty') ?? 1,
      prompt: q.str('prompt'),
      refs: q.strings('refs'),
      multiple: q.boolean('multiple'),
      options: q.list('options', choice),
      word: word?.strOrNull('text'),
      wordSentence: word?.strOrNull('sentence'),
      parts: completion == null ? const [] : completion.list('parts', (p) => CompletionPart(text: p.strOrNull('text'), blank: p.strOrNull('blank'))),
      bank: completion?.strings('bank') ?? const [],
      left: q.list('left', choice),
      right: q.list('right', choice),
      items: q.list('items', choice),
    );
  }

  static AttemptSummary summary(Json s) => AttemptSummary(
    id: s['id'].toString(),
    submittedAt: s.dateOrNull('submittedAt'),
    total: s.integerOrNull('total') ?? 0,
    correct: s.integerOrNull('correct') ?? 0,
    partial: s.integerOrNull('partial') ?? 0,
    incorrect: s.integerOrNull('incorrect') ?? 0,
    pending: s.integerOrNull('pending') ?? 0,
    ungraded: s.integerOrNull('ungraded') ?? 0,
  );

  static AnswerDraft draft(Json? d) => d == null
      ? const AnswerDraft()
      : AnswerDraft(
          options: d['options'] == null ? null : d.strings('options'),
          value: d.opt<bool>('value'),
          blanks: d['blanks'] == null ? null : d.stringMap('blanks'),
          pairs: d['pairs'] == null ? null : d.stringMap('pairs'),
          order: d['order'] == null ? null : d.strings('order'),
          text: d.strOrNull('text'),
        );

  static Attempt attempt(Json j) => Attempt(
    summary: summary(j.obj('summary')),
    questions: j.list('questions', question),
    answers: j.list(
      'answers',
      (a) => AnswerOutcome(
        questionId: a.str('questionId'),
        type: type(a.strOrNull('type')),
        result: AnswerResult.values.where((r) => r.name == a.strOrNull('result')).firstOrNull ?? AnswerResult.unknown,
        evaluator: a.strOrNull('evaluator') == null
            ? null
            : (Evaluator.values.where((e) => e.name == a.strOrNull('evaluator')).firstOrNull ?? Evaluator.unknown),
        response: draft(a.objOrNull('response')),
        solution: draft(a.objOrNull('solution')),
        explanation: a.strOrNull('explanation'),
        refs: a.strings('refs'),
        justification: a.strOrNull('justification'),
        citations: a.strings('citations'),
      ),
    ),
  );
}
