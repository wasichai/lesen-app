import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/comprehension_repository.dart';
import '../domain/assessment.dart';

typedef ReadingVersion = ({String slug, int version});

final assessmentProvider = FutureProvider.autoDispose.family<Assessment?, ReadingVersion>(
  (ref, k) => ref.watch(comprehensionRepositoryProvider).assessment(k.slug, k.version),
);

/// Un intento enviado. Mientras alguna respuesta está `PENDING` (la corrige el asistente), se vuelve a pedir cada 2 s.
final attemptProvider = AsyncNotifierProvider.autoDispose.family<AttemptController, Attempt, String>(AttemptController.new);

class AttemptController extends AsyncNotifier<Attempt> {
  AttemptController(this.attemptId);

  final String attemptId;
  Timer? _poll;

  /// El intento recién enviado, para no pedirlo dos veces.
  static final seeds = <String, Attempt>{};

  @override
  Future<Attempt> build() async {
    ref.onDispose(() => _poll?.cancel());
    final seeded = seeds.remove(attemptId);
    final attempt = seeded ?? await ref.read(comprehensionRepositoryProvider).fetch(attemptId);
    _schedule(attempt);
    return attempt;
  }

  void _schedule(Attempt a) {
    _poll?.cancel();
    if (!a.summary.evaluating) return;
    _poll = Timer(const Duration(seconds: 2), () async {
      try {
        final next = await ref.read(comprehensionRepositoryProvider).fetch(attemptId);
        if (!ref.mounted) return;
        state = AsyncData(next);
        _schedule(next);
      } catch (_) {
        if (ref.mounted) _schedule(a);
      }
    });
  }

  Future<void> selfAssess(String questionId, AnswerResult result) async {
    final next = await ref.read(comprehensionRepositoryProvider).selfAssess(attemptId, questionId, result);
    state = AsyncData(next);
  }
}
