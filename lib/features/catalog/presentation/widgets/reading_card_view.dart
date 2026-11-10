import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/l10n.dart';
import '../../../../app/theme/tokens.dart';
import '../../../profile/application/profile_providers.dart';
import '../../domain/reading.dart';
import 'cover_image.dart';
import 'reading_meta.dart';

/// Tarjeta vertical (carruseles y rejillas): portada, título, resumen y metadatos.
class ReadingCardView extends ConsumerWidget {
  const ReadingCardView({super.key, required this.reading, required this.onTap, this.badge, this.showSummary = true});

  final ReadingCard reading;
  final VoidCallback onTap;
  final String? badge;
  final bool showSummary;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = LesenTokens.of(context);
    final text = Theme.of(context).textTheme;
    final languageName = ref.watch(languagesProvider).value?.nameOf(reading.language) ?? reading.language.toUpperCase();
    return Semantics(
      button: true,
      label: context.l10n.cardSemantics(reading.title, languageName, reading.level.name, reading.minutes),
      excludeSemantics: true,
      child: Material(
        color: t.surfaceRaised,
        borderRadius: BorderRadius.circular(t.radiusCard),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  CoverImage(reading: reading, radius: 0),
                  if (badge != null)
                    Positioned(
                      left: 10,
                      top: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(color: t.ink.withValues(alpha: 0.78), borderRadius: BorderRadius.circular(t.radiusSm)),
                        child: Text(badge!, style: text.labelSmall?.copyWith(color: t.surface)),
                      ),
                    ),
                  if (reading.bookmarked) Positioned(right: 10, top: 10, child: Icon(Icons.bookmark, color: Colors.white.withValues(alpha: 0.95), size: 22)),
                ],
              ),
              if (reading.started) ReadingProgressBar(percent: reading.progress!.percent),
              // siempre va en un hueco de altura fija (carrusel o rejilla): el resumen cede si el texto es grande
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Flexible(
                        flex: 2,
                        child: Text(reading.title, maxLines: 2, overflow: TextOverflow.ellipsis, style: text.titleLarge, locale: Locale(reading.language)),
                      ),
                      if (showSummary) ...[
                        const SizedBox(height: 4),
                        Flexible(
                          child: Text(
                            reading.subtitle ?? reading.summary,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: text.bodyMedium?.copyWith(color: t.inkMuted),
                            locale: Locale(reading.language),
                          ),
                        ),
                      ],
                      const Spacer(),
                      ReadingMetaLine(reading),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Fila horizontal (listas del catálogo en teléfono): miniatura a la izquierda.
class ReadingListTile extends ConsumerWidget {
  const ReadingListTile({super.key, required this.reading, required this.onTap});

  final ReadingCard reading;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = LesenTokens.of(context);
    final text = Theme.of(context).textTheme;
    final languageName = ref.watch(languagesProvider).value?.nameOf(reading.language) ?? reading.language.toUpperCase();
    return Semantics(
      button: true,
      label: context.l10n.cardSemantics(reading.title, languageName, reading.level.name, reading.minutes),
      excludeSemantics: true,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(t.radiusLg),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 104,
                child: CoverImage(reading: reading, radius: t.radiusLg, aspectRatio: 1),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(reading.title, maxLines: 2, overflow: TextOverflow.ellipsis, style: text.titleLarge, locale: Locale(reading.language)),
                    const SizedBox(height: 4),
                    Text(
                      reading.summary,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: text.bodyMedium?.copyWith(color: t.inkMuted),
                      locale: Locale(reading.language),
                    ),
                    const SizedBox(height: 8),
                    ReadingMetaLine(reading),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
