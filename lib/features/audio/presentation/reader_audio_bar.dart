import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/l10n.dart';
import '../application/playback_controller.dart';
import 'audio_controls.dart';

/// La barra de audio del lector: compacta, abajo, con el texto siempre a la vista.
class ReaderAudioBar extends ConsumerWidget {
  const ReaderAudioBar({super.key, required this.paper, required this.onFollow});

  final Color paper;
  final VoidCallback onFollow;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final failed = ref.watch(playbackProvider.select((s) => s.failed));
    final follow = ref.watch(playbackProvider.select((s) => s.follow));
    final voice = ref.watch(playbackProvider.select((s) => s.now?.asset.voice.name));
    final text = Theme.of(context).textTheme;
    return Semantics(
      container: true,
      label: l10n.audioLabel,
      child: Material(
        color: paper,
        elevation: 6,
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(8, 4, 8, 4),
            child: failed
                ? Padding(
                    padding: const EdgeInsets.all(12),
                    child: Text(l10n.audioError, style: text.bodyMedium),
                  )
                : Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const PositionSlider(),
                      Row(
                        children: [
                          const SpeedButton(),
                          const Expanded(child: TransportRow(compact: true)),
                          IconButton(
                            tooltip: l10n.audioFollow,
                            isSelected: follow,
                            onPressed: () {
                              ref.read(playbackProvider.notifier).setFollow(!follow);
                              if (!follow) onFollow();
                            },
                            icon: const Icon(Icons.subtitles_off_outlined),
                            selectedIcon: const Icon(Icons.subtitles_outlined),
                          ),
                        ],
                      ),
                      if (voice != null) Text(l10n.audioVoice(voice), style: text.labelSmall),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
