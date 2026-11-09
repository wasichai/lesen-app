import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/l10n.dart';
import '../../../app/routing/routes.dart';
import '../../../app/theme/tokens.dart';
import '../../catalog/domain/reading.dart';
import '../../profile/application/profile_providers.dart';

/// El cierre de una lectura: lo logrado, sin cifras que castiguen, y a dónde seguir.
class EndOfReading extends ConsumerWidget {
  const EndOfReading({super.key, required this.reading, required this.minutes, required this.savedWords});

  final ReadingCard reading;
  final int minutes;
  final int savedWords;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final t = LesenTokens.of(context);
    final text = Theme.of(context).textTheme;
    final language = ref.watch(languagesProvider).value?.nameOf(reading.language) ?? reading.language;
    final reduce = MediaQuery.disableAnimationsOf(context);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TweenAnimationBuilder<double>(
              tween: Tween(begin: reduce ? 1 : 0.6, end: 1),
              duration: const Duration(milliseconds: 500),
              curve: Curves.elasticOut,
              builder: (_, v, child) => Transform.scale(scale: v, child: child),
              child: Container(
                width: 88,
                height: 88,
                decoration: BoxDecoration(color: t.brandSoft, shape: BoxShape.circle),
                child: Icon(Icons.auto_awesome, size: 42, color: t.brandStrong),
              ),
            ),
            const SizedBox(height: 16),
            Semantics(liveRegion: true, header: true, child: Text(l10n.endTitle, style: text.headlineMedium)),
            const SizedBox(height: 8),
            Text(l10n.endBody(reading.wordCount, language), textAlign: TextAlign.center, style: text.bodyLarge),
            Text(
              l10n.endTime(minutes.clamp(1, 600)),
              textAlign: TextAlign.center,
              style: text.bodyMedium?.copyWith(color: t.inkMuted),
            ),
            Text(
              l10n.endSaved(savedWords),
              textAlign: TextAlign.center,
              style: text.bodyMedium?.copyWith(color: t.inkMuted),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () {
                  Navigator.pop(context);
                  context.go(Routes.library);
                },
                child: Text(l10n.endLibrary),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  Navigator.pop(context);
                  context.go(Routes.discover);
                },
                child: Text(l10n.endDiscover),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
