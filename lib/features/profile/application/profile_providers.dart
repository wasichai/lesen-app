import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../catalog/data/catalog_repository.dart';
import '../../catalog/domain/reading.dart';
import '../../../core/session/session_controller.dart';
import '../data/profile_repository.dart';
import '../domain/learner_profile.dart';

final languagesProvider = FutureProvider<LanguageCatalog>((ref) => ref.watch(catalogRepositoryProvider).languages());

final topicsProvider = FutureProvider<List<Topic>>((ref) => ref.watch(catalogRepositoryProvider).topics());

/// El perfil de quien ha entrado; `null` hasta el onboarding. Se recarga al cambiar de sesión.
final profileProvider = AsyncNotifierProvider<ProfileController, LearnerProfile?>(ProfileController.new);

class ProfileController extends AsyncNotifier<LearnerProfile?> {
  @override
  Future<LearnerProfile?> build() async {
    final session = ref.watch(sessionControllerProvider.select((s) => s.session?.token));
    if (session == null) return null;
    return ref.watch(profileRepositoryProvider).fetch();
  }

  Future<void> save(LearnerProfile profile) async {
    final saved = await ref.read(profileRepositoryProvider).save(profile);
    state = AsyncData(saved);
  }
}
