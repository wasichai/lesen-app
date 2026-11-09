import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/l10n.dart';
import '../../../app/routing/routes.dart';
import '../../../app/theme/tokens.dart';
import '../../catalog/presentation/widgets/cover_image.dart';
import '../application/playback_controller.dart';
import 'audio_controls.dart';

/// El reproductor a pantalla completa: portada, la oración que suena y todos los controles.
class FullPlayerScreen extends ConsumerWidget {
  const FullPlayerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final now = ref.watch(playbackProvider.select((s) => s.now));
    final text = Theme.of(context).textTheme;
    final t = LesenTokens.of(context);
    if (now == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted && context.canPop()) context.pop();
      });
      return const Scaffold();
    }
    final controller = ref.read(playbackProvider.notifier);
    final wide = MediaQuery.sizeOf(context).width >= 720;
    final cover = ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 360),
      child: CoverImage(reading: now.reading, aspectRatio: 1),
    );
    final info = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(now.reading.title, textAlign: TextAlign.center, style: text.headlineMedium, locale: Locale(now.content.language)),
        Text(l10n.audioVoice(now.asset.voice.name), style: text.bodySmall),
        const SizedBox(height: 20),
        // la oración que suena, con su texto escrito
        ValueListenableBuilder<ActiveSpan?>(
          valueListenable: controller.active,
          builder: (_, a, _) {
            final s = a?.sentenceId == null ? null : now.content.index.sentence(a!.sentenceId!);
            return AnimatedSwitcher(
              duration: MediaQuery.disableAnimationsOf(context) ? Duration.zero : const Duration(milliseconds: 200),
              child: Container(
                key: ValueKey(s?.id),
                constraints: const BoxConstraints(minHeight: 96),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: t.surfaceMuted, borderRadius: BorderRadius.circular(LesenTokens.radiusLg)),
                child: Text(
                  s?.text ?? '',
                  textAlign: TextAlign.center,
                  style: text.titleLarge?.copyWith(fontWeight: FontWeight.w400, height: 1.4),
                  locale: Locale(now.content.language),
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 16),
        const PositionSlider(),
        const TransportRow(),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SpeedButton(),
            const SizedBox(width: 12),
            TextButton.icon(
              onPressed: () => context.push(Routes.reader(now.content.slug)),
              icon: const Icon(Icons.menu_book_outlined),
              label: Text(l10n.audioOpenReading),
            ),
          ],
        ),
      ],
    );
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(tooltip: l10n.commonClose, icon: const Icon(Icons.keyboard_arrow_down), onPressed: () => context.pop()),
        title: Text(l10n.audioNowPlaying),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 960),
              child: wide
                  ? Row(
                      children: [
                        Expanded(child: cover),
                        const SizedBox(width: 32),
                        Expanded(child: info),
                      ],
                    )
                  : Column(children: [cover, const SizedBox(height: 24), info]),
            ),
          ),
        ),
      ),
    );
  }
}
