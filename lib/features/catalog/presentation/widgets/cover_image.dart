import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../app/theme/tokens.dart';
import '../../application/cover_provider.dart';
import '../../domain/reading.dart';

/// Portada de una lectura. Mientras carga (o si no hay), una composición con su color de acento y su título: nunca un
/// rectángulo gris.
class CoverImage extends ConsumerWidget {
  const CoverImage({super.key, required this.reading, this.radius = LesenTokens.radiusCard, this.aspectRatio = 4 / 3});

  final ReadingCard reading;
  final double radius;
  final double aspectRatio;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accent = accentFor(reading.slug, reading.accent);
    final fallback = _CoverFallback(reading: reading, accent: accent);
    final cover = reading.cover;
    return ExcludeSemantics(
      child: AspectRatio(
        aspectRatio: aspectRatio,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(radius),
          child: cover == null
              ? fallback
              : switch (ref.watch(coverBytesProvider(cover))) {
                  AsyncData(:final value?) => SvgPicture.memory(value, fit: BoxFit.cover, errorBuilder: (_, _, _) => fallback),
                  _ => fallback,
                },
        ),
      ),
    );
  }
}

class _CoverFallback extends StatelessWidget {
  const _CoverFallback({required this.reading, required this.accent});

  final ReadingCard reading;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final hsl = HSLColor.fromColor(accent);
    final deep = hsl.withLightness((hsl.lightness * 0.55).clamp(0.12, 0.4)).toColor();
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [accent, deep]),
      ),
      child: Stack(
        children: [
          Positioned(right: -24, top: -24, child: _Disc(color: Colors.white.withValues(alpha: 0.14), size: 120)),
          Positioned(left: -30, bottom: -40, child: _Disc(color: Colors.black.withValues(alpha: 0.10), size: 140)),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Align(
              alignment: Alignment.bottomLeft,
              child: Text(
                reading.title,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontFamily: 'Newsreader', fontSize: 22, fontWeight: FontWeight.w600, color: Colors.white, height: 1.1),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Disc extends StatelessWidget {
  const _Disc({required this.color, required this.size});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(color: color, shape: BoxShape.circle),
  );
}
