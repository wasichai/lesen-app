import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../app/l10n.dart';
import '../../../core/widgets/feedback_views.dart';
import '../application/progress_providers.dart';
import 'progress_widgets.dart';

/// El resumen de una semana (de lunes a domingo), con navegación a las anteriores.
class WeeklyScreen extends ConsumerStatefulWidget {
  const WeeklyScreen({super.key});

  @override
  ConsumerState<WeeklyScreen> createState() => _WeeklyScreenState();
}

class _WeeklyScreenState extends ConsumerState<WeeklyScreen> {
  DateTime? _week;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final text = Theme.of(context).textTheme;
    final summary = ref.watch(weeklyProvider(_week));
    final fmt = DateFormat.MMMd(Localizations.localeOf(context).toLanguageTag());
    return Scaffold(
      appBar: AppBar(title: Text(l10n.progressWeeklySummary)),
      body: switch (summary) {
        AsyncData(:final value) => ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Row(
              children: [
                IconButton(
                  tooltip: l10n.weeklyPrevious,
                  onPressed: () => setState(() => _week = value.weekStart.subtract(const Duration(days: 7))),
                  icon: const Icon(Icons.chevron_left),
                ),
                Expanded(
                  child: Text(l10n.weeklyRange(fmt.format(value.weekStart), fmt.format(value.weekEnd)), textAlign: TextAlign.center, style: text.titleMedium),
                ),
                IconButton(
                  tooltip: l10n.weeklyNext,
                  onPressed: value.current ? null : () => setState(() => _week = value.weekStart.add(const Duration(days: 7))),
                  icon: const Icon(Icons.chevron_right),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Semantics(
              liveRegion: true,
              child: Text(
                value.met
                    ? l10n.weeklyMet(value.activeDays, value.target)
                    : (value.activeDays == 0 ? l10n.weeklyQuiet : l10n.weeklyProgress(value.activeDays, value.target)),
                style: text.headlineSmall,
              ),
            ),
            const SizedBox(height: 16),
            ActivityGrid(days: value.days),
            const SizedBox(height: 20),
            GridView(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: MediaQuery.sizeOf(context).width >= 600 ? 3 : 2,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                mainAxisExtent: 140 * MediaQuery.textScalerOf(context).scale(1).clamp(1.0, 2.0),
              ),
              children: [
                for (final k in const ['minutes', 'readingsCompleted', 'wordsRead', 'wordsSaved', 'wordsReviewed', 'assessments'])
                  if (value.metrics[k] != null) MetricTile(label: l10n.metric(k) ?? k, metric: value.metrics[k]!),
              ],
            ),
            if (value.achievements.isNotEmpty) ...[
              const SizedBox(height: 20),
              Text(l10n.progressAchievements, style: text.titleMedium),
              const SizedBox(height: 8),
              Wrap(spacing: 10, runSpacing: 10, children: [for (final a in value.achievements) AchievementBadge(achievement: a, compact: true)]),
            ],
          ],
        ),
        AsyncError(:final error) => FailureView(error: error, onRetry: () => ref.invalidate(weeklyProvider(_week))),
        _ => const LoadingView(),
      },
    );
  }
}
