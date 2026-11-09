import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/session/session_controller.dart';
import '../../features/audio/presentation/full_player_screen.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/splash_screen.dart';
import '../../features/catalog/domain/catalog_query.dart';
import '../../features/comprehension/presentation/assessment_screen.dart';
import '../../features/comprehension/presentation/attempt_screen.dart';
import '../../features/dictionary/presentation/dictionary_screen.dart';
import '../../features/dictionary/presentation/entry_screen.dart';
import '../../features/downloads/presentation/downloads_screen.dart';
import '../../features/catalog/domain/reading.dart';
import '../../features/catalog/presentation/catalog_screen.dart';
import '../../features/catalog/presentation/reading_detail_screen.dart';
import '../../features/discover/presentation/discover_screen.dart';
import '../../features/library/presentation/library_screen.dart';
import '../../features/lists/presentation/lists_widgets.dart';
import '../../features/onboarding/presentation/onboarding_screen.dart';
import '../../features/profile/application/profile_providers.dart';
import '../../features/profile/presentation/profile_screen.dart';
import '../../features/progress/presentation/achievements_screen.dart';
import '../../features/progress/presentation/progress_screen.dart';
import '../../features/progress/presentation/weekly_screen.dart';
import '../../features/reader/presentation/reader_screen.dart';
import '../../features/shell/presentation/app_shell.dart';
import '../../features/vocabulary/presentation/review_screen.dart';
import '../../features/vocabulary/presentation/vocabulary_screen.dart';
import 'routes.dart';

/// Qué hacer con una ruta según la sesión y el perfil. Pura, para probarla sin widgets.
@visibleForTesting
String? decideRedirect({required SessionStatus session, required AsyncValue<Object?> profile, required Uri location}) {
  final path = location.path;
  if (session == SessionStatus.restoring) return path == Routes.splash ? null : _withFrom(Routes.splash, location);
  if (session == SessionStatus.signedOut) {
    if (path == Routes.login) return null;
    return _withFrom(Routes.login, location);
  }
  // con sesión: hasta saber si hay perfil, la pantalla de arranque
  if (profile.isLoading && !profile.hasValue) return path == Routes.splash ? null : _withFrom(Routes.splash, location);
  final hasProfile = profile.value != null;
  if (!hasProfile && !profile.hasError) return path == Routes.onboarding ? null : Routes.onboarding;
  if (path == Routes.onboarding && location.queryParameters['edit'] != '1') return Routes.discover;
  if (Routes.public.contains(path)) return _from(location) ?? Routes.discover;
  return null;
}

String _withFrom(String target, Uri location) {
  if (Routes.public.contains(location.path) || location.path == '/' || location.path == Routes.onboarding) return target;
  return Uri(path: target, queryParameters: {'from': location.toString()}).toString();
}

/// Solo se vuelve a rutas propias (evita redirecciones abiertas desde un enlace profundo).
String? _from(Uri location) {
  final from = location.queryParameters['from'];
  if (from == null || !from.startsWith('/') || from.startsWith('//')) return null;
  return from;
}

final routerProvider = Provider<GoRouter>((ref) {
  final refresh = ValueNotifier<int>(0);
  ref.listen(sessionControllerProvider, (_, _) => refresh.value++);
  ref.listen(profileProvider, (_, _) => refresh.value++);
  ref.onDispose(refresh.dispose);

  final router = GoRouter(
    initialLocation: Routes.discover,
    refreshListenable: refresh,
    redirect: (context, state) => decideRedirect(session: ref.read(sessionControllerProvider).status, profile: ref.read(profileProvider), location: state.uri),
    errorBuilder: (context, state) => const _UnknownRoute(),
    routes: [
      GoRoute(path: '/', redirect: (_, _) => Routes.discover),
      GoRoute(path: Routes.splash, builder: (_, _) => const SplashScreen()),
      GoRoute(path: Routes.login, builder: (_, _) => const LoginScreen()),
      GoRoute(
        path: Routes.onboarding,
        builder: (_, state) => OnboardingScreen(editing: state.uri.queryParameters['edit'] == '1'),
      ),
      GoRoute(path: Routes.profile, builder: (_, _) => const ProfileScreen()),
      GoRoute(path: Routes.player, builder: (_, _) => const FullPlayerScreen()),
      GoRoute(
        path: '/read/:slug',
        redirect: (_, state) => _validSlug(state) ? null : Routes.discover,
        builder: (_, state) => ReaderScreen(slug: state.pathParameters['slug']!),
        routes: [
          GoRoute(
            path: 'quiz',
            builder: (_, state) =>
                AssessmentScreen(slug: state.pathParameters['slug']!, version: int.tryParse(state.uri.queryParameters['version'] ?? '') ?? 1),
          ),
        ],
      ),
      GoRoute(
        path: '/attempts/:id',
        builder: (_, state) => AttemptScreen(
          attemptId: state.pathParameters['id']!,
          slug: state.uri.queryParameters['slug'] ?? '',
          version: int.tryParse(state.uri.queryParameters['version'] ?? '') ?? 1,
        ),
      ),
      GoRoute(
        path: Routes.dictionary,
        builder: (_, _) => const DictionaryScreen(),
        routes: [
          GoRoute(
            path: 'entries/:key',
            builder: (_, state) => EntryScreen(entryKey: state.pathParameters['key']!),
          ),
        ],
      ),
      GoRoute(path: Routes.review, builder: (_, _) => const ReviewScreen()),
      GoRoute(path: Routes.downloads, builder: (_, _) => const DownloadsScreen()),
      GoRoute(
        path: '/lists/:id',
        builder: (_, state) => ListScreen(id: state.pathParameters['id']!),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => AppShell(shell: shell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.discover,
                builder: (_, _) => const DiscoverScreen(),
                routes: [
                  GoRoute(
                    path: 'catalog',
                    builder: (_, state) => CatalogScreen(initial: catalogQueryFrom(state.uri)),
                  ),
                  GoRoute(
                    path: 'readings/:slug',
                    redirect: (_, state) => _validSlug(state) ? null : Routes.discover,
                    builder: (_, state) => ReadingDetailScreen(slug: state.pathParameters['slug']!),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [GoRoute(path: Routes.library, builder: (_, _) => const LibraryScreen())],
          ),
          StatefulShellBranch(
            routes: [GoRoute(path: Routes.vocabulary, builder: (_, _) => const VocabularyScreen())],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.progress,
                builder: (_, _) => const ProgressScreen(),
                routes: [
                  GoRoute(path: 'weekly', builder: (_, _) => const WeeklyScreen()),
                  GoRoute(path: 'achievements', builder: (_, _) => const AchievementsScreen()),
                ],
              ),
            ],
          ),
        ],
      ),
    ],
  );
  ref.onDispose(router.dispose);
  return router;
});

bool _validSlug(GoRouterState state) => Routes.slugPattern.hasMatch(state.pathParameters['slug'] ?? '');

/// Filtros iniciales del catálogo desde la URL (enlaces de temas y niveles).
CatalogQuery catalogQueryFrom(Uri uri) {
  final p = uri.queryParameters;
  final level = cefrOf(p['level']);
  return CatalogQuery(language: p['language'], topic: p['topic'], levels: {?level});
}

class _UnknownRoute extends StatelessWidget {
  const _UnknownRoute();

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (context.mounted) context.go(Routes.discover);
    });
    return const Scaffold();
  }
}
