import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../app/l10n.dart';
import '../../../app/theme/tokens.dart';
import '../../../core/widgets/feedback_views.dart';
import '../../profile/application/profile_providers.dart';
import '../application/vocabulary_providers.dart';
import '../domain/vocabulary.dart';

/// Tres formas de preguntar por una palabra, alternadas para no memorizar solo en un sentido.
enum ReviewMode { meaning, word, context }

ReviewMode modeFor(ReviewCard card, int index) {
  final mode = ReviewMode.values[index % ReviewMode.values.length];
  // en contexto solo si la oración contiene la forma tal como apareció
  if (mode == ReviewMode.context && !(card.item.context?.contains(card.item.surface) ?? false)) return ReviewMode.meaning;
  return mode;
}

class ReviewScreen extends ConsumerWidget {
  const ReviewScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final session = ref.watch(reviewSessionProvider);
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(tooltip: l10n.commonClose, icon: const Icon(Icons.close), onPressed: () => context.pop()),
        title: Text(l10n.reviewTitle),
      ),
      body: switch (session) {
        AsyncData(:final value) when value.cards.isEmpty => _Nothing(next: value.nextDueAt),
        AsyncData(:final value) when value.finished => _Done(session: value),
        AsyncData(:final value) => _CardView(session: value),
        AsyncError(:final error) => FailureView(error: error, onRetry: () => ref.invalidate(reviewSessionProvider)),
        _ => const LoadingView(),
      },
    );
  }
}

class _CardView extends ConsumerWidget {
  const _CardView({required this.session});

  final ReviewSession session;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final t = LesenTokens.of(context);
    final text = Theme.of(context).textTheme;
    final card = session.current!;
    final item = card.item;
    final mode = modeFor(card, session.index);
    final language = ref.watch(languagesProvider).value?.nameOf(item.language) ?? item.language;
    final locale = Locale(item.language);
    final reduce = MediaQuery.disableAnimationsOf(context);

    final (prompt, front) = switch (mode) {
      ReviewMode.meaning => (l10n.reviewPromptMeaning, Text(item.lemma, textAlign: TextAlign.center, style: text.displaySmall, locale: locale)),
      ReviewMode.word => (l10n.reviewPromptWord(language), Text(item.translations.join(', '), textAlign: TextAlign.center, style: text.headlineMedium)),
      ReviewMode.context => (
        l10n.reviewPromptContext,
        Text(
          session.revealed ? item.context! : item.context!.replaceFirst(item.surface, '_' * item.surface.length.clamp(3, 12)),
          textAlign: TextAlign.center,
          style: text.headlineSmall?.copyWith(fontWeight: FontWeight.w400, height: 1.4),
          locale: locale,
        ),
      ),
    };
    final answer = Column(
      children: [
        if (mode != ReviewMode.meaning) Text(item.lemma, style: text.headlineMedium, locale: locale),
        if (mode != ReviewMode.word) Text(item.translations.join(', '), textAlign: TextAlign.center, style: text.titleLarge),
        if (mode != ReviewMode.context && item.context != null) ...[
          const SizedBox(height: 12),
          Text(
            item.context!,
            textAlign: TextAlign.center,
            style: text.bodyLarge?.copyWith(fontFamily: t.readingFont, fontStyle: FontStyle.italic),
            locale: locale,
          ),
        ],
        if (item.note != null) ...[const SizedBox(height: 8), Text(item.note!, style: text.bodySmall)],
      ],
    );

    final now = DateTime.now();
    return SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Semantics(
                  label: l10n.reviewProgress(session.index + 1, session.cards.length),
                  child: LinearProgressIndicator(value: session.index / session.cards.length, minHeight: 6, borderRadius: BorderRadius.circular(3)),
                ),
                const SizedBox(height: 6),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(l10n.reviewProgress(session.index + 1, session.cards.length), style: text.labelSmall),
                ),
                Expanded(
                  child: AnimatedSwitcher(
                    duration: reduce ? Duration.zero : const Duration(milliseconds: 250),
                    child: Container(
                      key: ValueKey('${item.id}-${session.revealed}'),
                      width: double.infinity,
                      margin: const EdgeInsets.symmetric(vertical: 16),
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: t.surfaceRaised,
                        borderRadius: BorderRadius.circular(t.radiusXl),
                        boxShadow: [BoxShadow(color: t.ink.withValues(alpha: 0.06), blurRadius: 24, offset: const Offset(0, 8))],
                      ),
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            Text(prompt.toUpperCase(), style: text.labelMedium?.copyWith(color: t.brand, letterSpacing: 1.2)),
                            const SizedBox(height: 24),
                            front,
                            if (session.revealed) ...[
                              const SizedBox(height: 20),
                              const Divider(),
                              const SizedBox(height: 16),
                              Semantics(liveRegion: true, child: answer),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                if (!session.revealed)
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(onPressed: () => ref.read(reviewSessionProvider.notifier).reveal(), child: Text(l10n.reviewShow)),
                  )
                else ...[
                  Text(l10n.reviewHowWell, style: text.titleSmall),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      for (final r in ReviewRating.values) ...[
                        if (r != ReviewRating.AGAIN) const SizedBox(width: 8),
                        Expanded(
                          child: _RateButton(rating: r, when: card.preview[r] == null ? null : l10n.reviewIn(l10n.until(card.preview[r]!, now))),
                        ),
                      ],
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RateButton extends ConsumerWidget {
  const _RateButton({required this.rating, required this.when});

  final ReviewRating rating;
  final String? when;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final text = Theme.of(context).textTheme;
    final primary = rating == ReviewRating.GOOD;
    final child = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(l10n.rating(rating), style: text.labelLarge?.copyWith(color: primary ? Theme.of(context).colorScheme.onPrimary : null)),
        if (when != null) Text(when!, style: text.labelSmall?.copyWith(color: primary ? Theme.of(context).colorScheme.onPrimary : null)),
      ],
    );
    void rate() => ref.read(reviewSessionProvider.notifier).rate(rating);
    final style = ButtonStyle(
      padding: const WidgetStatePropertyAll(EdgeInsets.symmetric(vertical: 10, horizontal: 4)),
      minimumSize: const WidgetStatePropertyAll(Size(44, 60)),
    );
    return primary ? FilledButton(style: style, onPressed: rate, child: child) : OutlinedButton(style: style, onPressed: rate, child: child);
  }
}

class _Done extends StatelessWidget {
  const _Done({required this.session});

  final ReviewSession session;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return EmptyState(
      title: l10n.reviewDoneTitle,
      body: [l10n.reviewDoneBody(session.done), if (session.failed > 0) l10n.reviewFailed].join('\n\n'),
      icon: Icons.celebration_outlined,
      action: FilledButton(onPressed: () => context.pop(), child: Text(l10n.commonClose)),
    );
  }
}

class _Nothing extends StatelessWidget {
  const _Nothing({required this.next});

  final DateTime? next;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final date = next == null ? null : DateFormat.yMMMd(Localizations.localeOf(context).toLanguageTag()).add_Hm().format(next!.toLocal());
    return EmptyState(
      title: l10n.reviewNothing,
      body: [l10n.reviewNothingBody, if (date != null) l10n.reviewNext(date)].join('\n\n'),
      icon: Icons.self_improvement,
      action: OutlinedButton(onPressed: () => context.pop(), child: Text(l10n.commonClose)),
    );
  }
}
