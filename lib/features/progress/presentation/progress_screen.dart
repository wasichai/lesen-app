import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/l10n.dart';
import '../../../app/routing/routes.dart';
import '../../../app/theme/tokens.dart';
import '../../../core/widgets/feedback_views.dart';
import '../../comprehension/data/comprehension_repository.dart';
import '../../shell/presentation/app_shell.dart';
import '../application/progress_providers.dart';
import '../domain/progress.dart';
import 'goals_sheet.dart';
import 'progress_widgets.dart';

/// El panel: hoy, la semana, 28 días, lectura, vocabulario, comprensión, nivel y logros. Lo estimado se marca como tal y
/// ninguna cifra castiga un día sin leer.
class ProgressScreen extends ConsumerWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final dashboard = ref.watch(dashboardProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.progressTitle),
        actions: [IconButton(tooltip: l10n.progressGoals, onPressed: () => showGoalsSheet(context), icon: const Icon(Icons.flag_outlined))],
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(dashboardProvider.future),
        child: switch (dashboard) {
          AsyncData(:final value) when value == null => ListView(
            children: [EmptyState(title: l10n.progressEmpty, body: l10n.progressEmptyBody, icon: Icons.insights)],
          ),
          AsyncData(:final value) => _Body(d: value!),
          AsyncError(:final error) => ListView(
            children: [FailureView(error: error, onRetry: () => ref.invalidate(dashboardProvider))],
          ),
          _ => const LoadingView(),
        },
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({required this.d});

  final Dashboard d;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final t = LesenTokens.of(context);
    final text = Theme.of(context).textTheme;
    final wide = MediaQuery.sizeOf(context).width >= tabletBreakpoint;
    Widget section(String title, Widget child, {Widget? action}) => Padding(
      padding: const EdgeInsets.only(top: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Semantics(header: true, child: Text(title, style: text.headlineSmall)),
              ),
              ?action,
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
    Widget tiles(Map<String, Metric> metrics, List<String> keys, Map<String, IconData> icons) => GridView(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: wide ? 4 : 2,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        mainAxisExtent: 140 * MediaQuery.textScalerOf(context).scale(1).clamp(1.0, 2.0),
      ),
      children: [
        for (final k in keys)
          if (metrics[k] != null) MetricTile(label: l10n.metric(k) ?? k, metric: metrics[k]!, icon: icons[k]),
      ],
    );

    final today = Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [t.brandSoft, t.surfaceRaised]),
        borderRadius: BorderRadius.circular(LesenTokens.radiusCard),
      ),
      child: Row(
        children: [
          GoalRing(value: d.todayMinutes.asInt, goal: d.dailyMinutes),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.progressToday.toUpperCase(), style: text.labelMedium?.copyWith(color: t.brand, letterSpacing: 1.2)),
                Text(l10n.progressTodayMinutes(d.todayMinutes.asInt, d.dailyMinutes), style: text.headlineSmall),
                const SizedBox(height: 4),
                Text(d.goalMet ? l10n.progressGoalMet : l10n.progressGoalOpen, style: text.bodyMedium),
              ],
            ),
          ),
        ],
      ),
    );

    final week = Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: t.surfaceRaised, borderRadius: BorderRadius.circular(LesenTokens.radiusCard)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text(l10n.progressWeek, style: text.titleMedium)),
              if (d.streak.metThisWeek) Chip(avatar: const Icon(Icons.check, size: 16), label: Text(l10n.progressWeekMet)),
            ],
          ),
          Text(l10n.progressWeekDays(d.streak.activeThisWeek, d.streak.target), style: text.bodyLarge),
          const SizedBox(height: 4),
          Text(l10n.progressStreak(d.streak.current), style: text.bodyMedium),
          if (d.streak.best > 0) Text(l10n.progressBest(d.streak.best), style: text.bodySmall),
          const SizedBox(height: 12),
          Text(l10n.progressLast28, style: text.labelMedium),
          const SizedBox(height: 8),
          ActivityGrid(days: d.days),
          Align(
            alignment: AlignmentDirectional.centerEnd,
            child: TextButton(onPressed: () => context.push(Routes.weekly), child: Text(l10n.progressWeeklySummary)),
          ),
        ],
      ),
    );

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
      children: [
        if (wide)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: today),
              const SizedBox(width: 16),
              Expanded(child: week),
            ],
          )
        else ...[
          today,
          const SizedBox(height: 16),
          week,
        ],
        section(
          l10n.progressReading,
          tiles(
            d.reading,
            const ['completed', 'minutes', 'minutesThisWeek', 'wordsRead'],
            const {'completed': Icons.auto_stories, 'minutes': Icons.schedule, 'minutesThisWeek': Icons.today, 'wordsRead': Icons.notes},
          ),
        ),
        section(
          l10n.progressVocabulary,
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              tiles(
                d.vocabulary,
                const ['saved', 'learning', 'mastered', 'due'],
                const {'saved': Icons.bookmark, 'learning': Icons.autorenew, 'mastered': Icons.verified, 'due': Icons.style},
              ),
              if (d.growth.length > 1) ...[
                const SizedBox(height: 14),
                Text(l10n.progressGrowth, style: text.labelMedium),
                const SizedBox(height: 6),
                Semantics(
                  label: '${l10n.progressGrowth}: ${d.growth.map((g) => g.$2).join(', ')}',
                  excludeSemantics: true,
                  child: Sparkline(values: [for (final g in d.growth) g.$2]),
                ),
              ],
            ],
          ),
        ),
        section(
          l10n.progressComprehension,
          d.answered.asInt == 0
              ? Text(l10n.progressNoAnswers, style: text.bodyMedium)
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: MetricTile(label: l10n.metricAnswered, metric: d.answered, icon: Icons.quiz),
                        ),
                        const SizedBox(width: 10),
                        if (d.average != null)
                          Expanded(
                            child: MetricTile(label: l10n.metricAverage, metric: d.average!, icon: Icons.percent),
                          ),
                      ],
                    ),
                    if (d.byType.isNotEmpty) ...[
                      const SizedBox(height: 14),
                      Text(l10n.progressByType, style: text.labelMedium),
                      for (final s in d.byType) _ScoreBar(label: l10n.skill(ComprehensionRepository.type(s.key)), score: s),
                    ],
                  ],
                ),
        ),
        section(
          l10n.progressLevel,
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: t.surfaceRaised, borderRadius: BorderRadius.circular(LesenTokens.radiusLg)),
            child: Row(
              children: [
                Text(d.level, style: text.displaySmall?.copyWith(color: t.brandStrong)),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l10n.progressLevelEstimate(d.level), style: text.titleSmall),
                      Text(l10n.levelSignal(d.answeredAtLevel < 8 ? LevelSignal.unknown : d.levelSignal), style: text.bodyMedium),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        section(
          l10n.progressAchievements,
          d.recentAchievements.isEmpty
              ? const SizedBox.shrink()
              : SizedBox(
                  height: 140 * MediaQuery.textScalerOf(context).scale(1).clamp(1.0, 1.5),
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: d.recentAchievements.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 10),
                    itemBuilder: (_, i) => AchievementBadge(achievement: d.recentAchievements[i], compact: true),
                  ),
                ),
          action: TextButton(onPressed: () => context.push(Routes.achievements), child: Text(l10n.progressSeeAll)),
        ),
        const SizedBox(height: 16),
        Text(l10n.metricEstimatedHint, style: text.bodySmall),
      ],
    );
  }
}

class _ScoreBar extends StatelessWidget {
  const _ScoreBar({required this.label, required this.score});

  final String label;
  final Score score;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Semantics(
        label: '$label: ${score.score} %',
        excludeSemantics: true,
        child: Row(
          children: [
            SizedBox(width: 140, child: Text(label, style: text.bodySmall, maxLines: 2)),
            Expanded(
              child: LinearProgressIndicator(value: score.score / 100, minHeight: 8, borderRadius: BorderRadius.circular(4)),
            ),
            SizedBox(
              width: 48,
              child: Text('${score.score} %', textAlign: TextAlign.end, style: text.labelMedium),
            ),
          ],
        ),
      ),
    );
  }
}
