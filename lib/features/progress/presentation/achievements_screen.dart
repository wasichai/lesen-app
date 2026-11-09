import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/l10n.dart';
import '../../../core/widgets/feedback_views.dart';
import '../application/progress_providers.dart';
import 'progress_widgets.dart';

class AchievementsScreen extends ConsumerWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final all = ref.watch(achievementsProvider);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.progressAchievements)),
      body: switch (all) {
        AsyncData(:final value) => GridView(
          padding: const EdgeInsets.all(20),
          // la altura crece con el tamaño de letra: nada se corta con texto grande
          gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 220,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            mainAxisExtent: 170 * MediaQuery.textScalerOf(context).scale(1).clamp(1.0, 2.0),
          ),
          // primero lo conseguido, después lo que está más cerca
          children: [
            for (final a in [...value]..sort((x, y) => x.earned != y.earned ? (x.earned ? -1 : 1) : y.fraction.compareTo(x.fraction)))
              AchievementBadge(achievement: a),
          ],
        ),
        AsyncError(:final error) => FailureView(error: error, onRetry: () => ref.invalidate(achievementsProvider)),
        _ => const LoadingView(),
      },
    );
  }
}
