import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/l10n.dart';
import '../../../app/routing/routes.dart';
import '../../../app/theme/tokens.dart';
import '../../catalog/presentation/widgets/cover_image.dart';
import '../application/playback_controller.dart';
import 'audio_controls.dart';

/// Mini reproductor sobre la navegación: sigue sonando mientras se explora el cuaderno o el catálogo.
class MiniPlayer extends ConsumerWidget {
  const MiniPlayer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final now = ref.watch(playbackProvider.select((s) => s.now));
    if (now == null) return const SizedBox.shrink();
    final t = LesenTokens.of(context);
    final text = Theme.of(context).textTheme;
    final controller = ref.read(playbackProvider.notifier);
    return Material(
      color: t.surfaceRaised,
      elevation: 3,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ValueListenableBuilder<Duration>(
            valueListenable: controller.position,
            builder: (_, p, _) => LinearProgressIndicator(
              value: now.asset.duration.inMilliseconds == 0 ? 0 : p.inMilliseconds / now.asset.duration.inMilliseconds,
              minHeight: 2,
              backgroundColor: t.surfaceMuted,
            ),
          ),
          InkWell(
            onTap: () => context.push(Routes.player),
            child: Semantics(
              button: true,
              label: '${l10n.audioExpand}. ${l10n.audioNowPlaying}: ${now.reading.title}',
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 6, 4, 6),
                child: Row(
                  children: [
                    SizedBox(
                      width: 44,
                      child: CoverImage(reading: now.reading, radius: LesenTokens.radiusSm, aspectRatio: 1),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ExcludeSemantics(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(now.reading.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: text.titleSmall),
                            Text(now.asset.voice.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: text.bodySmall),
                          ],
                        ),
                      ),
                    ),
                    const PlayPauseButton(size: 44),
                    IconButton(tooltip: l10n.audioClose, onPressed: controller.close, icon: const Icon(Icons.close)),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
