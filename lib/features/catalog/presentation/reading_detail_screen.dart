import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/l10n.dart';
import '../../../app/routing/routes.dart';
import '../../../app/theme/tokens.dart';
import '../../../core/widgets/feedback_views.dart';
import '../../downloads/presentation/download_button.dart';
import '../../lists/presentation/lists_widgets.dart';
import '../../profile/application/profile_providers.dart';
import '../application/catalog_providers.dart';
import '../../reader/data/reader_repository.dart';
import '../domain/reading.dart';
import 'widgets/cover_image.dart';
import 'widgets/reading_card_view.dart';
import 'widgets/reading_meta.dart';

class ReadingDetailScreen extends ConsumerWidget {
  const ReadingDetailScreen({super.key, required this.slug});

  final String slug;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detail = ref.watch(readingDetailProvider(slug));
    return Scaffold(
      body: detail.when(
        loading: () => const LoadingView(),
        error: (e, _) => SafeArea(
          child: Column(
            children: [
              const Align(alignment: Alignment.centerLeft, child: BackButton()),
              Expanded(
                child: FailureView(error: e, onRetry: () => ref.invalidate(readingDetailProvider(slug))),
              ),
            ],
          ),
        ),
        data: (d) => _DetailBody(detail: d),
      ),
    );
  }
}

class _DetailBody extends ConsumerStatefulWidget {
  const _DetailBody({required this.detail});

  final ReadingDetail detail;

  @override
  ConsumerState<_DetailBody> createState() => _DetailBodyState();
}

class _DetailBodyState extends ConsumerState<_DetailBody> {
  late bool _bookmarked = widget.detail.reading.bookmarked;
  bool _saving = false;

  Future<void> _toggleBookmark() async {
    final next = !_bookmarked;
    setState(() {
      _bookmarked = next;
      _saving = true;
    });
    await ref.read(readerRepositoryProvider).setBookmark(widget.detail.reading.slug, next);
    if (mounted) setState(() => _saving = false);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final t = LesenTokens.of(context);
    final text = Theme.of(context).textTheme;
    final r = widget.detail.reading;
    final locale = Locale(r.language);
    final languageName = ref.watch(languagesProvider).value?.nameOf(r.language) ?? r.language.toUpperCase();
    final wide = MediaQuery.sizeOf(context).width >= 720;
    final primaryLabel = r.completed ? l10n.detailReadAgain : (r.started ? l10n.detailContinue : l10n.detailStart);

    final info = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(languageName.toUpperCase(), style: text.labelMedium?.copyWith(color: t.brand, letterSpacing: 1.2)),
        const SizedBox(height: 8),
        Semantics(
          header: true,
          child: Text(r.title, style: text.displaySmall, locale: locale),
        ),
        if (r.subtitle != null) ...[
          const SizedBox(height: 6),
          Text(
            r.subtitle!,
            style: text.titleLarge?.copyWith(color: t.inkMuted, fontWeight: FontWeight.w400, fontStyle: FontStyle.italic),
            locale: locale,
          ),
        ],
        const SizedBox(height: 16),
        ReadingMetaLine(r),
        const SizedBox(height: 8),
        Text('${l10n.wordsCount(r.wordCount)} · ${l10n.paragraphsCount(widget.detail.paragraphs)} · ${l10n.detailReaders(r.readers)}', style: text.bodySmall),
        if (r.started) ...[const SizedBox(height: 12), ReadingProgressBar(percent: r.progress!.percent)],
        const SizedBox(height: 20),
        Text(
          r.summary,
          style: text.bodyLarge?.copyWith(fontFamily: 'Newsreader', fontSize: 19, height: 1.55),
          locale: locale,
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: FilledButton.icon(
                key: const ValueKey('start-reading'),
                onPressed: () => context.push(Routes.reader(r.slug)),
                icon: const Icon(Icons.menu_book_outlined),
                label: Text(primaryLabel),
              ),
            ),
            const SizedBox(width: 12),
            Semantics(
              toggled: _bookmarked,
              child: IconButton.outlined(
                tooltip: _bookmarked ? l10n.detailBookmarked : l10n.detailBookmark,
                onPressed: _saving ? null : _toggleBookmark,
                iconSize: 26,
                style: IconButton.styleFrom(minimumSize: const Size(52, 52)),
                icon: Icon(_bookmarked ? Icons.bookmark : Icons.bookmark_outline, color: _bookmarked ? t.brand : null),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        DownloadButton(slug: r.slug),
        TextButton.icon(onPressed: () => showAddToList(context, r.slug), icon: const Icon(Icons.playlist_add), label: Text(l10n.listsAddTo)),
      ],
    );

    return CustomScrollView(
      slivers: [
        SliverAppBar(pinned: true, backgroundColor: t.surface, surfaceTintColor: Colors.transparent),
        SliverToBoxAdapter(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1040),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                child: wide
                    ? Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 5,
                            child: CoverImage(reading: r, aspectRatio: 3 / 4),
                          ),
                          const SizedBox(width: 32),
                          Expanded(flex: 6, child: info),
                        ],
                      )
                    : Column(
                        children: [
                          CoverImage(reading: r, aspectRatio: 16 / 11),
                          const SizedBox(height: 20),
                          info,
                        ],
                      ),
              ),
            ),
          ),
        ),
        if (widget.detail.related.isNotEmpty) ...[
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
              child: Semantics(header: true, child: Text(l10n.detailRelated, style: text.headlineSmall)),
            ),
          ),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 232 * 3 / 4 + 172 * MediaQuery.textScalerOf(context).scale(1).clamp(1.0, 1.6),
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: widget.detail.related.length,
                separatorBuilder: (_, _) => const SizedBox(width: 14),
                itemBuilder: (_, i) {
                  final rel = widget.detail.related[i];
                  return SizedBox(
                    width: 232,
                    child: ReadingCardView(reading: rel, onTap: () => context.push(Routes.reading(rel.slug))),
                  );
                },
              ),
            ),
          ),
        ],
        const SliverToBoxAdapter(child: SizedBox(height: 32)),
      ],
    );
  }
}
