import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/networking/api_failure.dart';
import '../../../core/sync/sync.dart';
import '../../../core/utilities/ids.dart';
import '../../profile/application/profile_providers.dart';
import '../data/vocabulary_repository.dart';
import '../domain/known_words.dart';
import '../domain/vocabulary.dart';

/// El idioma de estudio de quien lee: el cuaderno y el repaso van por idioma.
final studyLanguageProvider = Provider<String?>((ref) => ref.watch(profileProvider.select((p) => p.value?.targetLanguage)));

final vocabularyStatsProvider = FutureProvider.autoDispose<VocabularyStats?>((ref) async {
  final language = ref.watch(studyLanguageProvider);
  if (language == null) return null;
  return ref.watch(vocabularyRepositoryProvider).stats(language);
});

class NotebookState {
  const NotebookState({this.q = '', this.status, this.items = const [], this.page = -1, this.hasNext = true, this.loading = false, this.error, this.total});

  final String q;
  final WordStatus? status;
  final List<VocabularyItem> items;
  final int page;
  final bool hasNext;
  final bool loading;
  final ApiFailure? error;
  final int? total;

  NotebookState copyWith({List<VocabularyItem>? items, int? page, bool? hasNext, bool? loading, ApiFailure? Function()? error, int? total}) => NotebookState(
    q: q,
    status: status,
    items: items ?? this.items,
    page: page ?? this.page,
    hasNext: hasNext ?? this.hasNext,
    loading: loading ?? this.loading,
    error: error != null ? error() : this.error,
    total: total ?? this.total,
  );
}

final notebookProvider = NotifierProvider.autoDispose<NotebookController, NotebookState>(NotebookController.new);

/// El cuaderno con carga incremental (páginas de 24) y filtros por búsqueda y estado.
class NotebookController extends Notifier<NotebookState> {
  int _generation = 0;

  @override
  NotebookState build() {
    Future.microtask(loadMore);
    return const NotebookState();
  }

  void filter({String? q, WordStatus? Function()? status}) {
    _generation++;
    state = NotebookState(q: q ?? state.q, status: status != null ? status() : state.status);
    loadMore();
  }

  Future<void> refresh() async {
    _generation++;
    state = NotebookState(q: state.q, status: state.status);
    await loadMore();
  }

  Future<void> loadMore() async {
    if (state.loading || !state.hasNext) return;
    final g = _generation;
    state = state.copyWith(loading: true, error: () => null);
    try {
      final page = await ref.read(vocabularyRepositoryProvider).list(page: state.page + 1, q: state.q, status: state.status);
      if (g != _generation || !ref.mounted) return;
      state = state.copyWith(items: [...state.items, ...page.content], page: page.page, hasNext: page.hasNext, loading: false, total: page.totalElements);
    } on ApiFailure catch (e) {
      if (g != _generation || !ref.mounted) return;
      state = state.copyWith(loading: false, error: () => e);
    }
  }

  void replace(VocabularyItem item) => state = state.copyWith(items: [for (final i in state.items) i.id == item.id ? item : i]);

  void removeLocal(String id) => state = state.copyWith(items: state.items.where((i) => i.id != id).toList(), total: (state.total ?? 1) - 1);
}

/// Una sesión de repaso: las tarjetas que tocan, en orden, y lo que se va respondiendo.
class ReviewSession {
  const ReviewSession({required this.cards, required this.index, required this.revealed, required this.done, required this.nextDueAt, this.failed = 0});

  final List<ReviewCard> cards;
  final int index;
  final bool revealed;
  final int done;
  final DateTime? nextDueAt;
  final int failed;

  bool get finished => index >= cards.length;
  ReviewCard? get current => finished ? null : cards[index];
}

final reviewSessionProvider = AsyncNotifierProvider.autoDispose<ReviewController, ReviewSession>(ReviewController.new);

class ReviewController extends AsyncNotifier<ReviewSession> {
  @override
  Future<ReviewSession> build() async {
    final language = ref.watch(studyLanguageProvider);
    if (language == null) return const ReviewSession(cards: [], index: 0, revealed: false, done: 0, nextDueAt: null);
    final queue = await ref.watch(vocabularyRepositoryProvider).nextReviews(language);
    return ReviewSession(cards: queue.cards, index: 0, revealed: false, done: 0, nextDueAt: queue.nextDueAt);
  }

  void reveal() {
    final s = state.value;
    if (s == null || s.finished) return;
    state = AsyncData(ReviewSession(cards: s.cards, index: s.index, revealed: true, done: s.done, nextDueAt: s.nextDueAt, failed: s.failed));
  }

  /// Responde la tarjeta actual. El intervalo lo decide el backend (FSRS-5). Va por la cola con un `clientId`: sin red se
  /// envía al volver, y repetirlo no repasa dos veces.
  Future<void> rate(ReviewRating rating) async {
    final s = state.value;
    final card = s?.current;
    if (s == null || card == null) return;
    final outbox = ref.read(outboxProvider);
    await outbox.enqueue(Ops.review, {
      'body': {'vocabularyId': card.item.id, 'rating': rating.name, 'clientId': uuidV4()},
    });
    unawaited(outbox.flush());
    if (!ref.mounted) return;
    state = AsyncData(ReviewSession(cards: s.cards, index: s.index + 1, revealed: false, done: s.done + 1, nextDueAt: s.nextDueAt));
    if (s.index + 1 >= s.cards.length) ref.invalidate(vocabularyStatsProvider);
  }
}
