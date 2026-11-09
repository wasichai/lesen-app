import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/progress_repository.dart';
import '../domain/progress.dart';

final dashboardProvider = FutureProvider.autoDispose<Dashboard?>((ref) => ref.watch(progressRepositoryProvider).dashboard());

final achievementsProvider = FutureProvider.autoDispose<List<Achievement>>((ref) => ref.watch(progressRepositoryProvider).achievements());

final goalsProvider = FutureProvider.autoDispose<Goals>((ref) => ref.watch(progressRepositoryProvider).goals());

/// `null` es la semana en curso.
final weeklyProvider = FutureProvider.autoDispose.family<WeeklySummary, DateTime?>((ref, week) => ref.watch(progressRepositoryProvider).weekly(week: week));
