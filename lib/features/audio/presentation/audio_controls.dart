import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/l10n.dart';
import '../application/playback_controller.dart';

String formatDuration(Duration d) {
  final m = d.inMinutes;
  final s = d.inSeconds % 60;
  return '$m:${s.toString().padLeft(2, '0')}';
}

String formatRate(double r) => r == r.roundToDouble() ? r.toStringAsFixed(0) : r.toString();

/// Barra de posición: solo ella escucha la posición (decenas de veces por segundo); nada más se reconstruye.
class PositionSlider extends ConsumerWidget {
  const PositionSlider({super.key, this.showTimes = true});

  final bool showTimes;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final controller = ref.read(playbackProvider.notifier);
    final total = ref.watch(playbackProvider.select((s) => s.now?.asset.duration)) ?? Duration.zero;
    final style = Theme.of(context).textTheme.labelSmall;
    return ValueListenableBuilder<Duration>(
      valueListenable: controller.position,
      builder: (context, position, _) {
        final max = total.inMilliseconds.toDouble().clamp(1.0, double.infinity);
        final value = position.inMilliseconds.toDouble().clamp(0.0, max);
        return Row(
          children: [
            if (showTimes) SizedBox(width: 40, child: Text(formatDuration(position), style: style)),
            Expanded(
              child: Semantics(
                label: l10n.audioPosition,
                value: l10n.audioPositionValue(formatDuration(position), formatDuration(total)),
                child: Slider(value: value, max: max, onChanged: (v) => controller.seekMs(v.round())),
              ),
            ),
            if (showTimes)
              SizedBox(
                width: 40,
                child: Text(formatDuration(total), style: style, textAlign: TextAlign.end),
              ),
          ],
        );
      },
    );
  }
}

class PlayPauseButton extends ConsumerWidget {
  const PlayPauseButton({super.key, this.size = 56});

  final double size;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final playing = ref.watch(playbackProvider.select((s) => s.playing));
    final buffering = ref.watch(playbackProvider.select((s) => s.buffering));
    final scheme = Theme.of(context).colorScheme;
    return SizedBox.square(
      dimension: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          IconButton.filled(
            tooltip: playing ? l10n.audioPause : l10n.audioPlay,
            iconSize: size * 0.5,
            style: IconButton.styleFrom(minimumSize: Size.square(size), backgroundColor: scheme.primary, foregroundColor: scheme.onPrimary),
            onPressed: () => ref.read(playbackProvider.notifier).toggle(),
            icon: Icon(playing ? Icons.pause_rounded : Icons.play_arrow_rounded),
          ),
          if (buffering)
            IgnorePointer(
              child: SizedBox.square(
                dimension: size,
                child: CircularProgressIndicator(strokeWidth: 2, color: scheme.primary.withValues(alpha: 0.5)),
              ),
            ),
        ],
      ),
    );
  }
}

class SpeedButton extends ConsumerWidget {
  const SpeedButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final speed = ref.watch(playbackProvider.select((s) => s.speed));
    return PopupMenuButton<double>(
      tooltip: l10n.audioRate,
      initialValue: speed,
      onSelected: (v) => ref.read(playbackProvider.notifier).setSpeed(v),
      itemBuilder: (_) => [for (final r in PlaybackController.speeds) PopupMenuItem(value: r, child: Text('${formatRate(r)}×'))],
      child: Semantics(
        button: true,
        label: l10n.audioRateValue(formatRate(speed)),
        excludeSemantics: true,
        child: SizedBox(
          height: 44,
          width: 56,
          child: Center(child: Text('${formatRate(speed)}×', style: Theme.of(context).textTheme.labelLarge)),
        ),
      ),
    );
  }
}

/// Los controles de navegación de la narración en una fila.
class TransportRow extends ConsumerWidget {
  const TransportRow({super.key, this.compact = false});

  final bool compact;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final c = ref.read(playbackProvider.notifier);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (!compact) IconButton(tooltip: l10n.audioPreviousParagraph, onPressed: () => c.paragraph(-1), icon: const Icon(Icons.keyboard_double_arrow_left)),
        IconButton(tooltip: l10n.audioPreviousSentence, onPressed: () => c.sentence(-1), icon: const Icon(Icons.skip_previous_rounded)),
        IconButton(tooltip: l10n.audioBack, onPressed: () => c.skipSeconds(-5), icon: const Icon(Icons.replay_5)),
        const SizedBox(width: 4),
        PlayPauseButton(size: compact ? 48 : 64),
        const SizedBox(width: 4),
        IconButton(tooltip: l10n.audioForward, onPressed: () => c.skipSeconds(5), icon: const Icon(Icons.forward_5)),
        IconButton(tooltip: l10n.audioNextSentence, onPressed: () => c.sentence(1), icon: const Icon(Icons.skip_next_rounded)),
        if (!compact) IconButton(tooltip: l10n.audioNextParagraph, onPressed: () => c.paragraph(1), icon: const Icon(Icons.keyboard_double_arrow_right)),
      ],
    );
  }
}
