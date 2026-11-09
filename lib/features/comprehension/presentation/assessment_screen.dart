import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/l10n.dart';
import '../../../app/routing/routes.dart';
import '../../../core/networking/api_failure.dart';
import '../../../core/widgets/feedback_views.dart';
import '../application/comprehension_providers.dart';
import '../data/comprehension_repository.dart';
import '../domain/assessment.dart';
import 'question_widgets.dart';

/// Las preguntas de comprensión de una lectura, una por pantalla.
class AssessmentScreen extends ConsumerWidget {
  const AssessmentScreen({super.key, required this.slug, required this.version});

  final String slug;
  final int version;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final assessment = ref.watch(assessmentProvider((slug: slug, version: version)));
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(tooltip: l10n.commonClose, icon: const Icon(Icons.close), onPressed: () => context.pop()),
        title: Text(l10n.quizTitle),
      ),
      body: switch (assessment) {
        AsyncData(:final value?) => _Quiz(assessment: value),
        AsyncData() => EmptyState(title: l10n.quizTitle, body: l10n.errorNotFound),
        AsyncError(:final error) => FailureView(error: error, onRetry: () => ref.invalidate(assessmentProvider((slug: slug, version: version)))),
        _ => const LoadingView(),
      },
    );
  }
}

class _Quiz extends ConsumerStatefulWidget {
  const _Quiz({required this.assessment});

  final Assessment assessment;

  @override
  ConsumerState<_Quiz> createState() => _QuizState();
}

class _QuizState extends ConsumerState<_Quiz> {
  final _pages = PageController();
  final _answers = <String, AnswerDraft>{};
  int _index = 0;
  bool _sending = false;
  bool _queued = false;

  List<Question> get _questions => widget.assessment.questions;

  @override
  void dispose() {
    _pages.dispose();
    super.dispose();
  }

  void _go(int i) {
    setState(() => _index = i);
    if (MediaQuery.disableAnimationsOf(context)) {
      _pages.jumpToPage(i);
    } else {
      _pages.animateToPage(i, duration: const Duration(milliseconds: 280), curve: Curves.easeOutCubic);
    }
  }

  Future<void> _submit() async {
    final l10n = context.l10n;
    final unanswered = _questions.where((q) => _answers[q.id]?.isEmpty ?? true).length;
    if (unanswered > 0) {
      final ok = await showDialog<bool>(
        context: context,
        builder: (c) => AlertDialog(
          content: Text(l10n.quizUnanswered(unanswered)),
          actions: [
            TextButton(onPressed: () => Navigator.pop(c, false), child: Text(l10n.commonBack)),
            FilledButton(onPressed: () => Navigator.pop(c, true), child: Text(l10n.quizSubmit)),
          ],
        ),
      );
      if (ok != true) return;
    }
    setState(() => _sending = true);
    try {
      final answered = {
        for (final e in _answers.entries)
          if (!e.value.isEmpty) e.key: e.value,
      };
      final attempt = await ref.read(comprehensionRepositoryProvider).submit(widget.assessment, answered);
      if (!mounted) return;
      if (attempt == null) {
        setState(() => _queued = true);
        return;
      }
      AttemptController.seeds[attempt.summary.id] = attempt;
      context.pushReplacement(Routes.attempt(attempt.summary.id, slug: widget.assessment.slug, version: widget.assessment.version));
    } on ApiFailure catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.failure(e))));
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final text = Theme.of(context).textTheme;
    final last = _index == _questions.length - 1;
    if (_queued) {
      return EmptyState(
        title: l10n.quizQueuedTitle,
        body: '${l10n.quizQueuedBody}\n\n${l10n.quizQueuedPending}',
        icon: Icons.cloud_upload_outlined,
        action: FilledButton(onPressed: () => context.pop(), child: Text(l10n.quizBackToReading)),
      );
    }
    return SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 680),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
                child: Semantics(
                  label: l10n.quizQuestion(_index + 1, _questions.length),
                  child: LinearProgressIndicator(value: (_index + 1) / _questions.length, minHeight: 6, borderRadius: BorderRadius.circular(3)),
                ),
              ),
              Expanded(
                child: PageView.builder(
                  controller: _pages,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _questions.length,
                  itemBuilder: (_, i) {
                    final q = _questions[i];
                    return ListView(
                      padding: const EdgeInsets.all(20),
                      children: [
                        Text(
                          '${l10n.quizQuestion(i + 1, _questions.length)} · ${l10n.skill(q.type)}'.toUpperCase(),
                          style: text.labelMedium?.copyWith(letterSpacing: 1.1, color: Theme.of(context).colorScheme.primary),
                        ),
                        const SizedBox(height: 10),
                        Semantics(header: true, child: Text(q.prompt, style: text.headlineSmall)),
                        const SizedBox(height: 20),
                        QuestionInput(
                          question: q,
                          draft: _answers[q.id] ?? const AnswerDraft(),
                          studyLanguage: widget.assessment.language,
                          onChanged: (d) => setState(() => _answers[q.id] = d),
                        ),
                      ],
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                child: Row(
                  children: [
                    if (_index > 0)
                      Flexible(
                        child: OutlinedButton(onPressed: () => _go(_index - 1), child: Text(l10n.quizPrevious)),
                      ),
                    if (_index > 0) const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton(
                        onPressed: _sending ? null : (last ? _submit : () => _go(_index + 1)),
                        child: Text(_sending ? l10n.quizSubmitting : (last ? l10n.quizSubmit : l10n.quizNext), textAlign: TextAlign.center),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
