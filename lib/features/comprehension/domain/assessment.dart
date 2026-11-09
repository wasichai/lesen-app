/// Los diez tipos de pregunta del backend (`QuestionType`).
enum QuestionType { MULTIPLE_CHOICE, TRUE_FALSE, COMPLETION, MATCHING, ORDERING, SHORT_ANSWER, VOCABULARY_IN_CONTEXT, MAIN_IDEA, INFERENCE, DETAIL, unknown }

extension QuestionTypeX on QuestionType {
  /// Se responden eligiendo opciones.
  bool get isChoice =>
      {QuestionType.MULTIPLE_CHOICE, QuestionType.VOCABULARY_IN_CONTEXT, QuestionType.MAIN_IDEA, QuestionType.INFERENCE, QuestionType.DETAIL}.contains(this);
}

class Choice {
  const Choice({required this.id, required this.text, required this.lang});

  final String id;
  final String text;
  final String? lang;
}

class CompletionPart {
  const CompletionPart({this.text, this.blank});

  final String? text;

  /// Id del hueco (el token del texto que falta).
  final String? blank;
}

class Question {
  const Question({
    required this.id,
    required this.type,
    required this.difficulty,
    required this.prompt,
    required this.refs,
    this.multiple = false,
    this.options = const [],
    this.word,
    this.wordSentence,
    this.parts = const [],
    this.bank = const [],
    this.left = const [],
    this.right = const [],
    this.items = const [],
  });

  final String id;
  final QuestionType type;
  final int difficulty;
  final String prompt;

  /// Oraciones del texto en las que se apoya.
  final List<String> refs;
  final bool multiple;
  final List<Choice> options;

  /// Para VOCABULARY_IN_CONTEXT: la palabra y su oración.
  final String? word;
  final String? wordSentence;
  final List<CompletionPart> parts;
  final List<String> bank;
  final List<Choice> left;
  final List<Choice> right;
  final List<Choice> items;
}

class AttemptSummary {
  const AttemptSummary({
    required this.id,
    required this.submittedAt,
    required this.total,
    required this.correct,
    required this.partial,
    required this.incorrect,
    required this.pending,
    required this.ungraded,
  });

  final String id;
  final DateTime? submittedAt;
  final int total;
  final int correct;
  final int partial;
  final int incorrect;
  final int pending;
  final int ungraded;

  bool get evaluating => pending > 0;
}

class Assessment {
  const Assessment({required this.id, required this.slug, required this.version, required this.language, required this.questions, required this.lastAttempt});

  final String id;

  /// El idioma de la lectura (el de estudio).
  final String language;
  final String slug;
  final int version;
  final List<Question> questions;
  final AttemptSummary? lastAttempt;
}

/// Una respuesta con los campos que pide su tipo (`{questionId, options?, value?, blanks?, pairs?, order?, text?}`).
class AnswerDraft {
  const AnswerDraft({this.options, this.value, this.blanks, this.pairs, this.order, this.text});

  final List<String>? options;
  final bool? value;
  final Map<String, String>? blanks;
  final Map<String, String>? pairs;
  final List<String>? order;
  final String? text;

  bool get isEmpty =>
      (options?.isEmpty ?? true) &&
      value == null &&
      (blanks?.isEmpty ?? true) &&
      (pairs?.isEmpty ?? true) &&
      (order?.isEmpty ?? true) &&
      (text?.trim().isEmpty ?? true);

  Map<String, dynamic> toJson(String questionId) => {
    'questionId': questionId,
    if (options != null) 'options': options,
    'value': ?value,
    if (blanks != null) 'blanks': blanks,
    if (pairs != null) 'pairs': pairs,
    if (order != null) 'order': order,
    if (text != null && text!.trim().isNotEmpty) 'text': text!.trim(),
  };
}

enum AnswerResult { CORRECT, PARTIAL, INCORRECT, PENDING, UNGRADED, unknown }

enum Evaluator { RULE, AI, SELF, unknown }

class AnswerOutcome {
  const AnswerOutcome({
    required this.questionId,
    required this.type,
    required this.result,
    required this.evaluator,
    required this.response,
    required this.solution,
    required this.explanation,
    required this.refs,
    required this.justification,
    required this.citations,
  });

  final String questionId;
  final QuestionType type;
  final AnswerResult result;
  final Evaluator? evaluator;
  final AnswerDraft response;
  final AnswerDraft solution;
  final String? explanation;
  final List<String> refs;

  /// La razón del asistente, si corrigió él; nunca sin las oraciones del texto que cita.
  final String? justification;
  final List<String> citations;
}

class Attempt {
  const Attempt({required this.summary, required this.questions, required this.answers});

  final AttemptSummary summary;
  final List<Question> questions;
  final List<AnswerOutcome> answers;

  Question? question(String id) => questions.where((q) => q.id == id).firstOrNull;
}

/// Fortalezas y puntos a mejorar por tipo de pregunta: lo que salió bien y lo que no, sin inventar una nota.
({List<QuestionType> strong, List<QuestionType> weak}) skillsOf(Attempt attempt) {
  final good = <QuestionType, int>{};
  final bad = <QuestionType, int>{};
  for (final a in attempt.answers) {
    if (a.result == AnswerResult.CORRECT) good[a.type] = (good[a.type] ?? 0) + 1;
    if (a.result == AnswerResult.INCORRECT || a.result == AnswerResult.PARTIAL) bad[a.type] = (bad[a.type] ?? 0) + 1;
  }
  return (
    strong: [
      for (final t in good.keys)
        if ((bad[t] ?? 0) == 0) t,
    ],
    weak: [for (final t in bad.keys) t],
  );
}
