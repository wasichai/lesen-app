import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/l10n.dart';
import '../../../app/routing/routes.dart';
import '../../../app/theme/tokens.dart';
import '../../../core/networking/api_failure.dart';
import '../../../core/widgets/feedback_views.dart';
import '../../reader/data/reader_repository.dart';
import '../../reader/domain/reading_content.dart';
import '../application/comprehension_providers.dart';
import '../domain/assessment.dart';

final _contentProvider = FutureProvider.autoDispose.family<ReadingContent, ({String slug, int version})>(
  (ref, k) => ref.watch(readerRepositoryProvider).content(k.slug, k.version),
);

/// El resultado de un intento: cada respuesta explicada con las oraciones del texto en que se apoya.
class AttemptScreen extends ConsumerWidget {
  const AttemptScreen({super.key, required this.attemptId, required this.slug, required this.version});

  final String attemptId;
  final String slug;
  final int version;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final attempt = ref.watch(attemptProvider(attemptId));
    final content = ref.watch(_contentProvider((slug: slug, version: version))).value;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(tooltip: l10n.commonClose, icon: const Icon(Icons.close), onPressed: () => context.pop()),
        title: Text(l10n.quizResultTitle),
      ),
      body: switch (attempt) {
        AsyncData(:final value) => _Result(attempt: value, content: content, attemptId: attemptId, slug: slug, version: version),
        AsyncError(:final error) => FailureView(error: error, onRetry: () => ref.invalidate(attemptProvider(attemptId))),
        _ => const LoadingView(),
      },
    );
  }
}

class _Result extends ConsumerWidget {
  const _Result({required this.attempt, required this.content, required this.attemptId, required this.slug, required this.version});

  final Attempt attempt;
  final ReadingContent? content;
  final String attemptId;
  final String slug;
  final int version;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final t = LesenTokens.of(context);
    final text = Theme.of(context).textTheme;
    final s = attempt.summary;
    final skills = skillsOf(attempt);
    final reduce = MediaQuery.disableAnimationsOf(context);
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [t.brandSoft, t.surfaceRaised]),
            borderRadius: BorderRadius.circular(t.radiusCard),
          ),
          child: Row(
            children: [
              TweenAnimationBuilder<double>(
                tween: Tween(begin: reduce ? s.correct / s.total.clamp(1, 999) : 0, end: s.correct / s.total.clamp(1, 999)),
                duration: const Duration(milliseconds: 700),
                curve: Curves.easeOutCubic,
                builder: (_, v, _) => SizedBox.square(
                  dimension: 72,
                  child: CircularProgressIndicator(value: v, strokeWidth: 8, backgroundColor: t.surfaceMuted, strokeCap: StrokeCap.round),
                ),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Semantics(
                  liveRegion: true,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l10n.quizScore(s.correct, s.total), style: text.headlineSmall),
                      if (s.partial > 0) Text(l10n.quizPartial(s.partial), style: text.bodyMedium),
                      if (s.pending > 0) Text(l10n.quizPending(s.pending), style: text.bodyMedium),
                      if (s.ungraded > 0) Text(l10n.quizUngraded(s.ungraded), style: text.bodyMedium),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        if (skills.strong.isNotEmpty || skills.weak.isNotEmpty) ...[
          const SizedBox(height: 16),
          if (skills.strong.isNotEmpty) _Skills(title: l10n.quizStrengths, icon: Icons.thumb_up_alt_outlined, types: skills.strong),
          if (skills.weak.isNotEmpty) _Skills(title: l10n.quizImprove, icon: Icons.fitness_center, types: skills.weak),
        ],
        const SizedBox(height: 12),
        for (final a in attempt.answers) _AnswerCard(outcome: a, question: attempt.question(a.questionId), content: content, attemptId: attemptId),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(onPressed: () => context.pushReplacement(Routes.quiz(slug, version)), child: Text(l10n.quizRetry)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FilledButton(onPressed: () => context.pop(), child: Text(l10n.quizBackToReading)),
            ),
          ],
        ),
      ],
    );
  }
}

class _Skills extends StatelessWidget {
  const _Skills({required this.title, required this.icon, required this.types});

  final String title;
  final IconData icon;
  final List<QuestionType> types;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 8),
          Expanded(child: Text('$title: ${types.map(l10n.skill).join(', ')}', style: Theme.of(context).textTheme.bodyMedium)),
        ],
      ),
    );
  }
}

class _AnswerCard extends ConsumerWidget {
  const _AnswerCard({required this.outcome, required this.question, required this.content, required this.attemptId});

  final AnswerOutcome outcome;
  final Question? question;
  final ReadingContent? content;
  final String attemptId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final t = LesenTokens.of(context);
    final text = Theme.of(context).textTheme;
    final (icon, color) = switch (outcome.result) {
      AnswerResult.CORRECT => (Icons.check_circle, t.tones[1]),
      AnswerResult.PARTIAL => (Icons.timelapse, t.tones[2]),
      AnswerResult.INCORRECT => (Icons.cancel_outlined, t.brand),
      AnswerResult.PENDING => (Icons.hourglass_top, t.inkMuted),
      _ => (Icons.rate_review_outlined, t.tones[0]),
    };
    final evaluator = switch (outcome.evaluator) {
      Evaluator.AI => l10n.quizAssisted,
      Evaluator.SELF => l10n.quizSelf,
      Evaluator.RULE => l10n.quizRule,
      _ => null,
    };
    // las oraciones del texto: las de la pregunta y, si corrigió el asistente, las que cita
    final quoted = {...outcome.refs, ...outcome.citations}.map((id) => content?.index.sentence(id)?.text).whereType<String>().toList();
    final ungraded = outcome.result == AnswerResult.UNGRADED;
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      color: t.surfaceRaised,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(t.radiusLg),
        side: BorderSide(color: color.withValues(alpha: 0.4)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 8,
              runSpacing: 4,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Icon(icon, color: color),
                Text(l10n.result(outcome.result), style: text.labelLarge?.copyWith(color: color)),
                Text('· ${l10n.skill(outcome.type)}', style: text.labelSmall),
              ],
            ),
            const SizedBox(height: 8),
            if (question != null) Text(question!.prompt, style: text.titleMedium),
            const SizedBox(height: 8),
            _Line(label: l10n.quizYourAnswer, value: describe(context, outcome.response, question) ?? l10n.quizNoAnswer),
            _Line(label: ungraded ? l10n.quizModelAnswer : l10n.quizSolution, value: describe(context, outcome.solution, question) ?? '—'),
            if (outcome.explanation != null) _Line(label: l10n.quizExplanation, value: outcome.explanation!),
            if (outcome.evaluator == Evaluator.AI && outcome.justification != null) _Line(label: l10n.quizAssisted, value: outcome.justification!),
            if (quoted.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(l10n.quizInText, style: text.labelMedium),
              for (final q in quoted)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Container(
                    padding: const EdgeInsets.only(left: 10),
                    decoration: BoxDecoration(
                      border: Border(left: BorderSide(color: t.brand.withValues(alpha: 0.5), width: 3)),
                    ),
                    child: Text(
                      q,
                      style: text.bodyMedium?.copyWith(fontFamily: t.readingFont, fontStyle: FontStyle.italic),
                      locale: content == null ? null : Locale(content!.language),
                    ),
                  ),
                ),
            ],
            if (evaluator != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(evaluator, style: text.labelSmall),
              ),
            if (ungraded) ...[
              const SizedBox(height: 10),
              Text(l10n.quizSelfPrompt, style: text.bodyMedium),
              const SizedBox(height: 6),
              Wrap(
                spacing: 8,
                children: [
                  for (final r in const [AnswerResult.CORRECT, AnswerResult.PARTIAL, AnswerResult.INCORRECT])
                    OutlinedButton(
                      onPressed: () async {
                        try {
                          await ref.read(attemptProvider(attemptId).notifier).selfAssess(outcome.questionId, r);
                        } on ApiFailure catch (e) {
                          if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.failure(e))));
                        }
                      },
                      child: Text(l10n.result(r)),
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Una respuesta en palabras, según su tipo.
  static String? describe(BuildContext context, AnswerDraft d, Question? q) {
    final l10n = context.l10n;
    String label(List<Choice> from, String id) => from.where((c) => c.id == id).map((c) => c.text).firstOrNull ?? id;
    if (d.options != null && d.options!.isNotEmpty) return d.options!.map((o) => label(q?.options ?? const [], o)).join(', ');
    if (d.value != null) return d.value! ? l10n.quizTrue : l10n.quizFalse;
    if (d.blanks != null && d.blanks!.isNotEmpty) {
      final order = [for (final p in q?.parts ?? const <CompletionPart>[]) ?p.blank];
      return [for (final b in order.isEmpty ? d.blanks!.keys : order) d.blanks![b] ?? '…'].join(' · ');
    }
    if (d.pairs != null && d.pairs!.isNotEmpty) {
      return d.pairs!.entries.map((e) => '${label(q?.left ?? const [], e.key)} → ${label(q?.right ?? const [], e.value)}').join('; ');
    }
    if (d.order != null && d.order!.isNotEmpty) return [for (final (i, id) in d.order!.indexed) '${i + 1}. ${label(q?.items ?? const [], id)}'].join('\n');
    if (d.text != null && d.text!.trim().isNotEmpty) return d.text;
    return null;
  }
}

class _Line extends StatelessWidget {
  const _Line({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: text.labelMedium),
          Text(value, style: text.bodyMedium),
        ],
      ),
    );
  }
}
