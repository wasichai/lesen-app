import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/dictionary_repository.dart';
import '../domain/entry.dart';

final entryProvider = FutureProvider.autoDispose.family<Entry, String>((ref, key) => ref.watch(dictionaryRepositoryProvider).entry(key));

final dictionaryHistoryProvider = FutureProvider.autoDispose<List<HistoryItem>>((ref) => ref.watch(dictionaryRepositoryProvider).history());

final dictionaryFavoritesProvider = FutureProvider.autoDispose<List<EntrySummary>>((ref) => ref.watch(dictionaryRepositoryProvider).favorites());

/// Resultados de una búsqueda (vacía: ninguno). Se guarda en el historial solo al elegir un resultado, no al teclear.
final dictionarySearchProvider = FutureProvider.autoDispose.family<List<EntrySummary>, String>((ref, q) async {
  if (q.trim().length < 2) return const [];
  return ref.watch(dictionaryRepositoryProvider).search(q.trim());
});
