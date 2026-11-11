import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../app/theme/tokens.dart';
import '../../../../core/storage/public_files.dart';
import '../../../../l10n/app_localizations.dart';
import '../../application/illustration_provider.dart';
import '../../domain/reading_content.dart';
import '../reader_theme.dart';

/// Una ilustración entre párrafos. Reserva su hueco con sus medidas antes de que llegue el archivo (el texto no salta al
/// cargarla), se anuncia como imagen con su texto alternativo en el idioma de la lectura y, si no se puede cargar, lo
/// dice en lugar de dejar un hueco mudo.
class IllustrationView extends ConsumerWidget {
  const IllustrationView({super.key, required this.illustration, required this.language, required this.palette});

  final Illustration illustration;
  final String language;
  final ReaderPalette palette;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final locale = Locale(language);
    final missing = _Missing(message: l10n.readerIllustrationMissing, palette: palette);
    final picture = switch (ref.watch(illustrationBytesProvider(illustration.url))) {
      AsyncData(:final value?) =>
        isSvg(value)
            ? SvgPicture.memory(value, fit: BoxFit.contain, errorBuilder: (_, _, _) => missing)
            : Image.memory(value, fit: BoxFit.contain, gaplessPlayback: true, errorBuilder: (_, _, _) => missing),
      AsyncLoading() => ColoredBox(color: palette.sentence),
      _ => missing,
    };
    final caption = illustration.caption;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Semantics(
          container: true,
          image: true,
          attributedLabel: AttributedString(
            illustration.alt,
            attributes: [
              LocaleStringAttribute(
                range: TextRange(start: 0, end: illustration.alt.length),
                locale: locale,
              ),
            ],
          ),
          child: ExcludeSemantics(
            child: AspectRatio(
              aspectRatio: illustration.aspectRatio,
              child: ClipRRect(borderRadius: BorderRadius.circular(LesenTokens.of(context).radiusLg), child: picture),
            ),
          ),
        ),
        if (caption != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              caption,
              locale: locale,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: palette.inkMuted, fontStyle: FontStyle.italic),
            ),
          ),
      ],
    );
  }
}

class _Missing extends StatelessWidget {
  const _Missing({required this.message, required this.palette});

  final String message;
  final ReaderPalette palette;

  @override
  Widget build(BuildContext context) => ColoredBox(
    color: palette.sentence,
    child: Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.image_not_supported_outlined, color: palette.inkMuted, size: 20),
            const SizedBox(width: 8),
            Flexible(
              child: Text(message, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: palette.inkMuted)),
            ),
          ],
        ),
      ),
    ),
  );
}
