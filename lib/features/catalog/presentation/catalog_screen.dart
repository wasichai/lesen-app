import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/l10n.dart';
import '../../../app/routing/routes.dart';
import '../../../app/theme/tokens.dart';
import '../../../core/widgets/feedback_views.dart';
import '../../shell/presentation/app_shell.dart';
import '../application/catalog_providers.dart';
import '../domain/catalog_query.dart';
import '../domain/reading.dart';
import 'catalog_filters_sheet.dart';
import 'widgets/reading_card_view.dart';

class CatalogScreen extends ConsumerStatefulWidget {
  const CatalogScreen({super.key, this.initial = const CatalogQuery()});

  final CatalogQuery initial;

  @override
  ConsumerState<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends ConsumerState<CatalogScreen> {
  final _scroll = ScrollController();
  late final TextEditingController _search = TextEditingController(text: widget.initial.q);
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_onScroll);
    Future.microtask(() => ref.read(catalogProvider.notifier).setQuery(widget.initial));
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _scroll.dispose();
    _search.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scroll.position.extentAfter < 600) ref.read(catalogProvider.notifier).loadMore();
  }

  void _setQuery(CatalogQuery q) => ref.read(catalogProvider.notifier).setQuery(q);

  void _onSearch(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () => _setQuery(ref.read(catalogProvider).query.copyWith(q: value)));
  }

  Future<void> _openFilters() async {
    final current = ref.read(catalogProvider).query;
    final next = await showModalBottomSheet<CatalogQuery>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => CatalogFiltersSheet(initial: current),
    );
    if (next != null) _setQuery(next);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final state = ref.watch(catalogProvider);
    final q = state.query;
    final wide = MediaQuery.sizeOf(context).width >= tabletBreakpoint;
    void open(ReadingCard r) => context.go(Routes.reading(r.slug));

    return Scaffold(
      appBar: AppBar(title: Text(l10n.catalogTitle)),
      body: RefreshIndicator(
        onRefresh: () => ref.read(catalogProvider.notifier).refresh(),
        child: CustomScrollView(
          controller: _scroll,
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
                child: TextField(
                  controller: _search,
                  onChanged: _onSearch,
                  textInputAction: TextInputAction.search,
                  decoration: InputDecoration(
                    labelText: l10n.catalogSearch,
                    hintText: l10n.catalogSearchHint,
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _search.text.isEmpty
                        ? null
                        : IconButton(
                            tooltip: l10n.commonClose,
                            icon: const Icon(Icons.close),
                            onPressed: () {
                              _search.clear();
                              _setQuery(q.copyWith(q: ''));
                            },
                          ),
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: SizedBox(
                height: 56,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                  children: [
                    ActionChip(
                      avatar: const Icon(Icons.tune, size: 18),
                      label: Text(q.activeFilters == 0 ? l10n.catalogFilters : l10n.catalogFiltersCount(q.activeFilters)),
                      onPressed: _openFilters,
                    ),
                    const SizedBox(width: 8),
                    for (final level in CefrLevel.values) ...[
                      FilterChip(
                        label: Text(level.name),
                        selected: q.levels.contains(level),
                        onSelected: (on) => _setQuery(q.copyWith(levels: on ? {...q.levels, level} : ({...q.levels}..remove(level)))),
                      ),
                      const SizedBox(width: 6),
                    ],
                    if (q.activeFilters > 0) TextButton(onPressed: () => _setQuery(q.cleared()), child: Text(l10n.catalogClear)),
                  ],
                ),
              ),
            ),
            if (state.total != null)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 6, 20, 6),
                  child: Semantics(liveRegion: true, child: Text(l10n.catalogResults(state.total!), style: Theme.of(context).textTheme.labelMedium)),
                ),
              ),
            if (state.initialLoading)
              const SliverFillRemaining(child: LoadingView())
            else if (state.items.isEmpty && state.error != null)
              SliverFillRemaining(
                hasScrollBody: false,
                child: FailureView(error: state.error!, onRetry: () => ref.read(catalogProvider.notifier).refresh()),
              )
            else if (state.items.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: EmptyState(
                  title: l10n.catalogEmpty,
                  body: l10n.catalogEmptyBody,
                  icon: Icons.filter_alt_off_outlined,
                  action: q.activeFilters > 0 ? OutlinedButton(onPressed: () => _setQuery(q.cleared()), child: Text(l10n.catalogClear)) : null,
                ),
              )
            else if (wide)
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                sliver: SliverGrid.builder(
                  gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 320,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 0.72 / MediaQuery.textScalerOf(context).scale(1).clamp(1.0, 1.5),
                  ),
                  itemCount: state.items.length,
                  itemBuilder: (_, i) => ReadingCardView(reading: state.items[i], onTap: () => open(state.items[i])),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverList.separated(
                  itemCount: state.items.length,
                  separatorBuilder: (_, _) => Divider(color: LesenTokens.of(context).surfaceMuted),
                  itemBuilder: (_, i) => ReadingListTile(reading: state.items[i], onTap: () => open(state.items[i])),
                ),
              ),
            if (state.items.isNotEmpty && (state.loading || state.error != null))
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: state.error != null
                      ? FailureView(error: state.error!, compact: true, onRetry: () => ref.read(catalogProvider.notifier).loadMore())
                      : const LoadingView(),
                ),
              ),
            const SliverToBoxAdapter(child: SizedBox(height: 24)),
          ],
        ),
      ),
    );
  }
}
