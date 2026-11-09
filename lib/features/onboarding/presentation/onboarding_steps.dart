import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/l10n.dart';
import '../../../app/theme/tokens.dart';
import '../../../core/widgets/feedback_views.dart';
import '../../catalog/domain/reading.dart';
import '../../profile/application/profile_providers.dart';
import '../../profile/domain/learner_profile.dart';

typedef ProfileChanged = void Function(LearnerProfile);

class _StepScaffold extends StatelessWidget {
  const _StepScaffold({this.eyebrow, required this.heading, required this.body, required this.children});

  final String? eyebrow;
  final String heading;
  final String body;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final t = LesenTokens.of(context);
    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
      children: [
        if (eyebrow != null) Text(eyebrow!.toUpperCase(), style: text.labelMedium?.copyWith(color: t.brand, letterSpacing: 1.2)),
        if (eyebrow != null) const SizedBox(height: 8),
        Semantics(header: true, child: Text(heading, style: text.headlineLarge)),
        const SizedBox(height: 10),
        Text(body, style: text.bodyLarge?.copyWith(color: t.inkMuted)),
        const SizedBox(height: 28),
        ...children,
      ],
    );
  }
}

/// Una opción grande, seleccionable, con título y descripción.
class ChoiceTile extends StatelessWidget {
  const ChoiceTile({super.key, required this.title, this.subtitle, this.leading, required this.selected, required this.onTap, this.locale});

  final String title;
  final String? subtitle;
  final Widget? leading;
  final bool selected;
  final VoidCallback onTap;
  final Locale? locale;

  @override
  Widget build(BuildContext context) {
    final t = LesenTokens.of(context);
    final text = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Semantics(
        selected: selected,
        inMutuallyExclusiveGroup: true,
        child: Material(
          color: selected ? t.brandSoft : t.surfaceRaised,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(LesenTokens.radiusLg),
            side: BorderSide(color: selected ? t.brand : t.inkMuted.withValues(alpha: 0.2), width: selected ? 2 : 1),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(LesenTokens.radiusLg),
            onTap: onTap,
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 60),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    if (leading != null) ...[leading!, const SizedBox(width: 14)],
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(title, style: text.titleMedium, locale: locale),
                          if (subtitle != null) ...[const SizedBox(height: 2), Text(subtitle!, style: text.bodyMedium?.copyWith(color: t.inkMuted))],
                        ],
                      ),
                    ),
                    // la selección se ve también por el icono, no solo por el color
                    Icon(selected ? Icons.check_circle : Icons.circle_outlined, color: selected ? t.brand : t.inkMuted.withValues(alpha: 0.5)),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _LanguageAvatar extends StatelessWidget {
  const _LanguageAvatar(this.code);

  final String code;

  @override
  Widget build(BuildContext context) {
    final color = accentFor(code, null);
    return CircleAvatar(
      radius: 20,
      backgroundColor: color,
      child: Text(
        code.toUpperCase(),
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13),
      ),
    );
  }
}

class InterfaceStep extends StatelessWidget {
  const InterfaceStep({super.key, required this.catalog, required this.draft, required this.onChanged});

  final LanguageCatalog catalog;
  final LearnerProfile draft;
  final ProfileChanged onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return _StepScaffold(
      eyebrow: l10n.onboardingWelcomeEyebrow,
      heading: l10n.onboardingWelcomeHeading,
      body: l10n.onboardingWelcomeBody,
      children: [
        for (final lang in catalog.interfaceLanguages)
          ChoiceTile(
            title: lang.nativeName,
            locale: Locale(lang.code),
            leading: _LanguageAvatar(lang.code),
            selected: draft.interfaceLanguage == lang.code,
            onTap: () {
              var next = draft.copyWith(interfaceLanguage: lang.code);
              if (next.targetLanguage == lang.code) {
                final other = catalog.studyLanguages.where((l) => l.code != lang.code).firstOrNull;
                if (other != null) next = next.copyWith(targetLanguage: other.code);
              }
              onChanged(next);
            },
          ),
      ],
    );
  }
}

class TargetStep extends StatelessWidget {
  const TargetStep({super.key, required this.catalog, required this.draft, required this.onChanged});

  final LanguageCatalog catalog;
  final LearnerProfile draft;
  final ProfileChanged onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return _StepScaffold(
      heading: l10n.onboardingTargetHeading,
      body: l10n.onboardingTargetBody,
      children: [
        for (final lang in catalog.studyLanguages.where((l) => l.code != draft.interfaceLanguage))
          ChoiceTile(
            title: lang.nativeName,
            locale: Locale(lang.code),
            leading: _LanguageAvatar(lang.code),
            selected: draft.targetLanguage == lang.code,
            onTap: () => onChanged(draft.copyWith(targetLanguage: lang.code)),
          ),
      ],
    );
  }
}

class LevelStep extends StatelessWidget {
  const LevelStep({super.key, required this.catalog, required this.draft, required this.onChanged});

  final LanguageCatalog catalog;
  final LearnerProfile draft;
  final ProfileChanged onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final t = LesenTokens.of(context);
    return _StepScaffold(
      heading: l10n.onboardingLevelHeading(catalog.nameOf(draft.targetLanguage)),
      body: l10n.onboardingLevelBody,
      children: [
        for (final level in CefrLevel.values)
          ChoiceTile(
            title: level.name,
            subtitle: l10n.levelDescription(level),
            selected: draft.level == level && !draft.levelEstimated,
            onTap: () => onChanged(draft.copyWith(level: level, levelEstimated: false)),
          ),
        ChoiceTile(
          title: l10n.onboardingLevelUnsure,
          subtitle: l10n.onboardingLevelUnsureBody,
          leading: Icon(Icons.help_outline, color: t.inkMuted),
          selected: draft.levelEstimated,
          onTap: () => onChanged(draft.copyWith(level: CefrLevel.A2, levelEstimated: true)),
        ),
      ],
    );
  }
}

class InterestsStep extends ConsumerWidget {
  const InterestsStep({super.key, required this.draft, required this.onChanged});

  final LearnerProfile draft;
  final ProfileChanged onChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final text = Theme.of(context).textTheme;
    final topics = ref.watch(topicsProvider);
    return _StepScaffold(
      heading: l10n.onboardingInterestsHeading,
      body: l10n.onboardingInterestsBody,
      children: [
        Text(l10n.onboardingGoals, style: text.titleMedium),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final g in LearningGoal.values)
              FilterChip(
                label: Text(l10n.goal(g)),
                selected: draft.goals.contains(g),
                onSelected: (on) => onChanged(draft.copyWith(goals: on ? {...draft.goals, g} : ({...draft.goals}..remove(g)))),
              ),
          ],
        ),
        const SizedBox(height: 28),
        Text(l10n.onboardingTopics, style: text.titleMedium),
        const SizedBox(height: 12),
        topics.when(
          loading: () => const Padding(padding: EdgeInsets.all(24), child: LoadingView()),
          error: (e, _) => FailureView(error: e, compact: true, onRetry: () => ref.invalidate(topicsProvider)),
          data: (tree) => Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final topic in tree)
                FilterChip(
                  label: Text(topic.label(draft.interfaceLanguage)),
                  selected: draft.topics.contains(topic.slug),
                  onSelected: (on) {
                    final next = [...draft.topics]..remove(topic.slug);
                    if (on && next.length < LearnerProfile.maxTopics) next.add(topic.slug);
                    onChanged(draft.copyWith(topics: next));
                  },
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class HabitStep extends StatelessWidget {
  const HabitStep({super.key, required this.draft, required this.onChanged});

  final LearnerProfile draft;
  final ProfileChanged onChanged;

  static const choices = [5, 10, 15, 20, 30, 45, 60];

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final text = Theme.of(context).textTheme;
    return _StepScaffold(
      heading: l10n.onboardingHabitHeading,
      body: l10n.onboardingHabitBody,
      children: [
        Text(l10n.onboardingDaily, style: text.titleMedium),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final m in choices)
              ChoiceChip(
                label: Text(l10n.minutesShort(m)),
                selected: draft.dailyMinutes == m,
                onSelected: (_) => onChanged(draft.copyWith(dailyMinutes: m)),
              ),
          ],
        ),
        const SizedBox(height: 28),
        Text(l10n.onboardingDifficulty, style: text.titleMedium),
        const SizedBox(height: 12),
        for (final d in ReadingDifficulty.values)
          ChoiceTile(
            title: l10n.difficulty(d),
            subtitle: l10n.difficultyBody(d),
            selected: draft.difficulty == d,
            onTap: () => onChanged(draft.copyWith(difficulty: d)),
          ),
      ],
    );
  }
}
