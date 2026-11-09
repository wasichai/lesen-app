import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/l10n.dart';
import '../../../app/routing/routes.dart';
import '../../../core/widgets/feedback_views.dart';
import '../../catalog/domain/reading.dart';
import '../../catalog/presentation/widgets/reading_card_view.dart';
import '../../shell/presentation/app_shell.dart';
import '../data/library_repository.dart';

/// Mis lecturas: lo que se está leyendo, lo guardado para después y lo terminado.
class LibraryScreen extends ConsumerWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final library = ref.watch(libraryProvider);
    final wide = MediaQuery.sizeOf(context).width >= tabletBreakpoint;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.navLibrary)),
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(libraryProvider.future),
        child: switch (library) {
          AsyncData(:final value) when value.isEmpty => ListView(
            children: [
              EmptyState(
                title: l10n.libraryEmptyTitle,
                body: l10n.libraryEmptyBody,
                icon: Icons.auto_stories_outlined,
                action: FilledButton(onPressed: () => context.go(Routes.discover), child: Text(l10n.navDiscover)),
              ),
            ],
          ),
          AsyncData(:final value) => CustomScrollView(
            slivers: [
              ..._section(context, l10n.libraryInProgress, value.inProgress, wide, reading: true),
              ..._section(context, l10n.libraryBookmarked, value.bookmarked, wide),
              ..._section(context, l10n.libraryCompleted, value.completed, wide),
              const SliverToBoxAdapter(child: SizedBox(height: 24)),
            ],
          ),
          AsyncError(:final error) => ListView(
            children: [FailureView(error: error, onRetry: () => ref.invalidate(libraryProvider))],
          ),
          _ => const LoadingView(),
        },
      ),
    );
  }

  List<Widget> _section(BuildContext context, String title, List<ReadingCard> items, bool wide, {bool reading = false}) {
    if (items.isEmpty) return const [];
    void open(ReadingCard r) => reading ? context.push(Routes.reader(r.slug)) : context.go(Routes.reading(r.slug));
    return [
      SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
          child: Semantics(header: true, child: Text(title, style: Theme.of(context).textTheme.headlineSmall)),
        ),
      ),
      if (wide)
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          sliver: SliverGrid.builder(
            gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 320,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 0.72 / MediaQuery.textScalerOf(context).scale(1).clamp(1.0, 1.5),
            ),
            itemCount: items.length,
            itemBuilder: (_, i) => ReadingCardView(reading: items[i], onTap: () => open(items[i])),
          ),
        )
      else
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          sliver: SliverList.builder(
            itemCount: items.length,
            itemBuilder: (_, i) => ReadingListTile(reading: items[i], onTap: () => open(items[i])),
          ),
        ),
    ];
  }
}
