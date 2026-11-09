import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/networking/api_client.dart';
import '../../catalog/data/catalog_dto.dart';
import '../../catalog/domain/reading.dart';

class Library {
  const Library({required this.inProgress, required this.bookmarked, required this.completed});

  final List<ReadingCard> inProgress;
  final List<ReadingCard> bookmarked;
  final List<ReadingCard> completed;

  bool get isEmpty => inProgress.isEmpty && bookmarked.isEmpty && completed.isEmpty;
}

final libraryProvider = FutureProvider.autoDispose<Library>((ref) async {
  final j = await ref.watch(apiProvider).getJson('/lesen/library');
  return Library(
    inProgress: [for (final c in (j['inProgress'] as List? ?? const [])) CatalogDto.card((c as Map).cast<String, dynamic>())],
    bookmarked: [for (final c in (j['bookmarked'] as List? ?? const [])) CatalogDto.card((c as Map).cast<String, dynamic>())],
    completed: [for (final c in (j['completed'] as List? ?? const [])) CatalogDto.card((c as Map).cast<String, dynamic>())],
  );
});
