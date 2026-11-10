import 'package:flutter/material.dart';

import '../../../../app/l10n.dart';
import '../../../../app/theme/tokens.dart';
import '../../domain/reading.dart';

/// Insignia del nivel MCER: texto, no solo color.
class LevelBadge extends StatelessWidget {
  const LevelBadge(this.level, {super.key, this.onCover = false});

  final CefrLevel level;
  final bool onCover;

  @override
  Widget build(BuildContext context) {
    final t = LesenTokens.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: onCover ? Colors.white.withValues(alpha: 0.92) : t.brandSoft, borderRadius: BorderRadius.circular(t.radiusSm)),
      child: Text(
        level.name,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(color: onCover ? const Color(0xFF1F2430) : t.brandStrong, letterSpacing: 0.4),
      ),
    );
  }
}

/// «DE · A2 · 3 min», con el progreso si se empezó.
class ReadingMetaLine extends StatelessWidget {
  const ReadingMetaLine(this.reading, {super.key});

  final ReadingCard reading;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final t = LesenTokens.of(context);
    final style = Theme.of(context).textTheme.labelMedium?.copyWith(color: t.inkMuted);
    final progress = reading.progress;
    return Wrap(
      spacing: 8,
      runSpacing: 4,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        LevelBadge(reading.level),
        Text(reading.language.toUpperCase(), style: style),
        Text('·', style: style),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.schedule, size: 14, color: t.inkMuted),
            const SizedBox(width: 3),
            Text(l10n.minutesShort(reading.minutes), style: style),
          ],
        ),
        if (progress != null && progress.completed)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.check_circle, size: 14, color: t.tones[1]),
              const SizedBox(width: 3),
              Text(l10n.cardCompleted, style: style),
            ],
          )
        else if (progress != null)
          Text(l10n.cardProgress(progress.percent), style: style?.copyWith(color: t.brandStrong)),
      ],
    );
  }
}

/// Barra fina de progreso de lectura.
class ReadingProgressBar extends StatelessWidget {
  const ReadingProgressBar({super.key, required this.percent});

  final int percent;

  @override
  Widget build(BuildContext context) {
    final t = LesenTokens.of(context);
    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: LinearProgressIndicator(value: percent.clamp(0, 100) / 100, minHeight: 4, backgroundColor: t.surfaceMuted, color: t.brand),
    );
  }
}
