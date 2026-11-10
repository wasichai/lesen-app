import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../app/l10n.dart';
import '../../../app/theme/tokens.dart';
import '../domain/progress.dart';

/// Una cifra con su nombre; si es estimada, lo dice con «≈» y en palabras (no solo con estilo).
class MetricTile extends StatelessWidget {
  const MetricTile({super.key, required this.label, required this.metric, this.icon});

  final String label;
  final Metric metric;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final t = LesenTokens.of(context);
    final text = Theme.of(context).textTheme;
    final value = NumberFormat.decimalPattern(Localizations.localeOf(context).toLanguageTag()).format(metric.asInt);
    return Semantics(
      label: '$label: ${metric.estimated ? '${l10n.metricEstimated} ' : ''}$value',
      excludeSemantics: true,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: t.surfaceRaised, borderRadius: BorderRadius.circular(t.radiusLg)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (icon != null) Icon(icon, size: 20, color: t.brand),
            const SizedBox(height: 6),
            Text(
              metric.estimated ? '≈ $value' : value,
              style: text.headlineSmall?.copyWith(fontFamily: t.interfaceFont, fontWeight: FontWeight.w700),
            ),
            Text(label, style: text.bodySmall),
            if (metric.estimated) Text(l10n.metricEstimated, style: text.labelSmall?.copyWith(fontStyle: FontStyle.italic)),
          ],
        ),
      ),
    );
  }
}

/// Un anillo de avance hacia la meta de hoy, animado salvo con movimiento reducido.
class GoalRing extends StatelessWidget {
  const GoalRing({super.key, required this.value, required this.goal, this.size = 108});

  final int value;
  final int goal;
  final double size;

  @override
  Widget build(BuildContext context) {
    final t = LesenTokens.of(context);
    final fraction = goal == 0 ? 0.0 : (value / goal).clamp(0.0, 1.0);
    final reduce = MediaQuery.disableAnimationsOf(context);
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: reduce ? fraction : 0, end: fraction),
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeOutCubic,
      builder: (context, v, _) => SizedBox.square(
        dimension: size,
        child: Stack(
          alignment: Alignment.center,
          children: [
            SizedBox.square(
              dimension: size,
              child: CircularProgressIndicator(value: v, strokeWidth: 10, backgroundColor: t.surfaceMuted, strokeCap: StrokeCap.round),
            ),
            if (fraction >= 1)
              Icon(Icons.check_rounded, size: size * 0.4, color: t.brand)
            else
              Text('$value', style: Theme.of(context).textTheme.headlineMedium),
          ],
        ),
      ),
    );
  }
}

/// Los últimos 28 días como una cuadrícula: los días con lectura se llenan, los de meta llevan marca. Un día sin leer es
/// solo un hueco claro, nunca rojo.
class ActivityGrid extends StatelessWidget {
  const ActivityGrid({super.key, required this.days});

  final List<DayActivity> days;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final t = LesenTokens.of(context);
    final fmt = DateFormat.MMMd(Localizations.localeOf(context).toLanguageTag());
    final maxMinutes = days.fold<int>(1, (a, d) => math.max(a, d.minutes));
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: [
        for (final d in days)
          Semantics(
            label: d.goalMet ? l10n.progressDayGoal(fmt.format(d.date), d.minutes) : l10n.progressDayLabel(fmt.format(d.date), d.minutes),
            excludeSemantics: true,
            child: Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: d.active ? Color.lerp(t.brandSoft, t.brand, 0.25 + 0.75 * d.minutes / maxMinutes) : t.surfaceMuted,
                borderRadius: BorderRadius.circular(8),
              ),
              child: d.goalMet ? Icon(Icons.check, size: 16, color: t.surfaceRaised) : null,
            ),
          ),
      ],
    );
  }
}

/// Una línea pequeña de crecimiento semanal.
class Sparkline extends StatelessWidget {
  const Sparkline({super.key, required this.values, this.height = 56});

  final List<int> values;
  final double height;

  @override
  Widget build(BuildContext context) {
    final t = LesenTokens.of(context);
    return SizedBox(
      height: height,
      width: double.infinity,
      child: CustomPaint(painter: _SparkPainter(values, t.brand, t.brandSoft)),
    );
  }
}

class _SparkPainter extends CustomPainter {
  _SparkPainter(this.values, this.line, this.fill);

  final List<int> values;
  final Color line;
  final Color fill;

  @override
  void paint(Canvas canvas, Size size) {
    if (values.length < 2) return;
    final maxV = values.reduce(math.max).clamp(1, 1 << 30);
    final dx = size.width / (values.length - 1);
    final points = [for (var i = 0; i < values.length; i++) Offset(i * dx, size.height - 4 - (size.height - 8) * values[i] / maxV)];
    final path = Path()..moveTo(points.first.dx, points.first.dy);
    for (final p in points.skip(1)) {
      path.lineTo(p.dx, p.dy);
    }
    final area = Path.from(path)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(area, Paint()..color = fill);
    canvas.drawPath(
      path,
      Paint()
        ..color = line
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawCircle(points.last, 4, Paint()..color = line);
  }

  @override
  bool shouldRepaint(covariant _SparkPainter old) => old.values != values;
}

class AchievementBadge extends StatelessWidget {
  const AchievementBadge({super.key, required this.achievement, this.compact = false});

  final Achievement achievement;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final t = LesenTokens.of(context);
    final text = Theme.of(context).textTheme;
    final earned = achievement.earned;
    final icon = switch (achievement.kind) {
      'READINGS_COMPLETED' => Icons.auto_stories,
      'MINUTES' => Icons.schedule,
      'WORDS_SAVED' => Icons.bookmark,
      'WORDS_REVIEWED' => Icons.style,
      'ASSESSMENTS' => Icons.quiz,
      'ACTIVE_DAYS' => Icons.calendar_month,
      _ => Icons.emoji_events,
    };
    final date = achievement.earnedAt == null
        ? null
        : DateFormat.yMMMd(Localizations.localeOf(context).toLanguageTag()).format(achievement.earnedAt!.toLocal());
    return Container(
      width: compact ? 150 : null,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: earned ? t.brandSoft : t.surfaceRaised,
        borderRadius: BorderRadius.circular(t.radiusLg),
        border: Border.all(color: earned ? t.brand.withValues(alpha: 0.4) : t.surfaceMuted),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(earned ? icon : Icons.lock_open_outlined, color: earned ? t.brandStrong : t.inkMuted),
          const SizedBox(height: 6),
          Text(l10n.achievement(achievement.code), style: text.titleSmall, maxLines: 2, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 4),
          if (earned)
            Text(l10n.achievementEarned(date!), style: text.labelSmall)
          else ...[
            LinearProgressIndicator(value: achievement.fraction, minHeight: 4, borderRadius: BorderRadius.circular(2)),
            const SizedBox(height: 2),
            Text(l10n.achievementProgress(achievement.value, achievement.threshold), style: text.labelSmall),
          ],
        ],
      ),
    );
  }
}
