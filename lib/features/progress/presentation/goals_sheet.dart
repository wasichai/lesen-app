import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/l10n.dart';
import '../../../core/networking/api_failure.dart';
import '../../../core/notifications/reminders.dart';
import '../../../core/widgets/feedback_views.dart';
import '../../downloads/application/downloads_controller.dart';
import '../../profile/application/profile_providers.dart';
import '../application/progress_providers.dart';
import '../data/progress_repository.dart';

Future<void> showGoalsSheet(BuildContext context) =>
    showModalBottomSheet<void>(context: context, isScrollControlled: true, useSafeArea: true, builder: (_) => const GoalsSheet());

/// Metas amables (minutos al día, días por semana) y un recordatorio diario opcional, local al dispositivo.
class GoalsSheet extends ConsumerStatefulWidget {
  const GoalsSheet({super.key});

  @override
  ConsumerState<GoalsSheet> createState() => _GoalsSheetState();
}

class _GoalsSheetState extends ConsumerState<GoalsSheet> {
  static const readId = 1;
  static const reviewId = 2;

  Future<void> _save({int? daily, int? weekly, bool? summary}) async {
    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.maybeOf(context);
    try {
      await ref.read(progressRepositoryProvider).saveGoals(dailyMinutes: daily, weeklyDays: weekly, weeklySummary: summary);
      ref
        ..invalidate(goalsProvider)
        ..invalidate(dashboardProvider)
        ..invalidate(profileProvider);
    } on ApiFailure catch (e) {
      messenger?.showSnackBar(SnackBar(content: Text(l10n.failure(e))));
    }
  }

  /// Activa o reprograma los recordatorios. El permiso se pide aquí, al activarlos, y no antes.
  Future<void> _reminder({required bool enabled, TimeOfDay? at, bool? review}) async {
    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.maybeOf(context);
    final prefs = ref.read(appPrefsProvider.notifier);
    final current = ref.read(appPrefsProvider);
    final scheduler = ref.read(reminderSchedulerProvider);
    final time = at ?? TimeOfDay(hour: current['reminderHour'] as int? ?? 19, minute: current['reminderMinute'] as int? ?? 0);
    final withReview = review ?? current['reviewReminder'] as bool? ?? false;
    if (enabled && !await scheduler.requestPermission()) {
      messenger?.showSnackBar(SnackBar(content: Text(l10n.goalsReminderDenied)));
      await prefs.set('reminder', false);
      return;
    }
    await prefs.set('reminder', enabled);
    await prefs.set('reminderHour', time.hour);
    await prefs.set('reminderMinute', time.minute);
    await prefs.set('reviewReminder', withReview);
    await scheduler.cancel(readId);
    await scheduler.cancel(reviewId);
    if (!enabled) return;
    await scheduler.scheduleDaily(Reminder(id: readId, hour: time.hour, minute: time.minute, title: l10n.reminderReadTitle, body: l10n.reminderReadBody));
    if (withReview) {
      await scheduler.scheduleDaily(
        Reminder(id: reviewId, hour: time.hour, minute: (time.minute + 1) % 60, title: l10n.reminderReviewTitle, body: l10n.reminderReviewBody),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final text = Theme.of(context).textTheme;
    final goals = ref.watch(goalsProvider);
    final prefs = ref.watch(appPrefsProvider);
    final reminderOn = prefs['reminder'] as bool? ?? false;
    final time = TimeOfDay(hour: prefs['reminderHour'] as int? ?? 19, minute: prefs['reminderMinute'] as int? ?? 0);
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.75,
      maxChildSize: 0.95,
      builder: (context, scroll) => switch (goals) {
        AsyncData(:final value) => ListView(
          controller: scroll,
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
          children: [
            Semantics(header: true, child: Text(l10n.progressGoals, style: text.headlineSmall)),
            const SizedBox(height: 16),
            Text(l10n.goalsDaily, style: text.titleSmall),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final m in const [5, 10, 15, 20, 30, 45, 60])
                  ChoiceChip(
                    label: Text(l10n.minutesShort(m)),
                    selected: value.dailyMinutes == m,
                    onSelected: (_) => _save(daily: m),
                  ),
              ],
            ),
            const SizedBox(height: 20),
            Text(l10n.goalsWeekly, style: text.titleSmall),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                for (var d = 1; d <= 7; d++)
                  ChoiceChip(
                    label: Text('$d'),
                    selected: value.weeklyDays == d,
                    onSelected: (_) => _save(weekly: d),
                  ),
              ],
            ),
            const SizedBox(height: 6),
            Text(l10n.goalsWeeklyHint, style: text.bodySmall),
            const SizedBox(height: 12),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(l10n.goalsWeeklySummary),
              value: value.weeklySummary,
              onChanged: (v) => _save(summary: v),
            ),
            const Divider(height: 32),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(l10n.goalsReminder),
              subtitle: Text(l10n.goalsReminderHint),
              value: reminderOn,
              onChanged: (v) => _reminder(enabled: v),
            ),
            if (reminderOn) ...[
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.alarm),
                title: Text(l10n.goalsReminderAt(time.format(context))),
                onTap: () async {
                  final picked = await showTimePicker(context: context, initialTime: time);
                  if (picked != null) await _reminder(enabled: true, at: picked);
                },
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(l10n.goalsReviewReminder),
                value: prefs['reviewReminder'] as bool? ?? false,
                onChanged: (v) => _reminder(enabled: true, review: v),
              ),
            ],
          ],
        ),
        AsyncError(:final error) => FailureView(error: error, onRetry: () => ref.invalidate(goalsProvider)),
        _ => const LoadingView(),
      },
    );
  }
}
