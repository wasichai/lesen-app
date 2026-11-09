import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/networking/api_failure.dart';
import '../data/catalog_repository.dart';
import '../domain/catalog_query.dart';
import '../domain/reading.dart';

final discoverProvider = FutureProvider.autoDispose<Discover?>((ref) => ref.watch(catalogRepositoryProvider).discover());

final readingDetailProvider = FutureProvider.autoDispose.family<ReadingDetail, String>((ref, slug) => ref.watch(catalogRepositoryProvider).detail(slug));

/// Estado del catálogo con carga incremental.
class CatalogState {
  const CatalogState({required this.query, this.items = const [], this.total, this.page = -1, this.hasNext = true, this.loading = false, this.error});

  final CatalogQuery query;
  final List<ReadingCard> items;
  final int? total;
  final int page;
  final bool hasNext;
  final bool loading;
  final ApiFailure? error;

  bool get initialLoading => loading && items.isEmpty;

  CatalogState copyWith({List<ReadingCard>? items, int? total, int? page, bool? hasNext, bool? loading, ApiFailure? Function()? error}) => CatalogState(
    query: query,
    items: items ?? this.items,
    total: total ?? this.total,
    page: page ?? this.page,
    hasNext: hasNext ?? this.hasNext,
    loading: loading ?? this.loading,
    error: error != null ? error() : this.error,
  );
}

final catalogProvider = NotifierProvider.autoDispose<CatalogController, CatalogState>(CatalogController.new);

class CatalogController extends Notifier<CatalogState> {
  int _generation = 0;

  @override
  CatalogState build() {
    Future.microtask(loadMore);
    return const CatalogState(query: CatalogQuery());
  }

  /// Cambia los filtros y empieza desde la primera página; descarta respuestas de consultas anteriores.
  void setQuery(CatalogQuery query) {
    if (query == state.query && state.items.isNotEmpty) return;
    _generation++;
    state = CatalogState(query: query);
    loadMore();
  }

  Future<void> refresh() async {
    _generation++;
    state = CatalogState(query: state.query);
    await loadMore();
  }

  Future<void> loadMore() async {
    if (state.loading || !state.hasNext) return;
    final generation = _generation;
    state = state.copyWith(loading: true, error: () => null);
    try {
      final page = await ref.read(catalogRepositoryProvider).readings(state.query, page: state.page + 1);
      if (generation != _generation || !ref.mounted) return;
      state = state.copyWith(items: [...state.items, ...page.content], total: page.totalElements, page: page.page, hasNext: page.hasNext, loading: false);
    } on ApiFailure catch (e) {
      if (generation != _generation || !ref.mounted) return;
      state = state.copyWith(loading: false, error: () => e);
    }
  }
}
