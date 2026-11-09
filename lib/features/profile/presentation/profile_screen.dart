import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/l10n.dart';
import '../../../app/routing/routes.dart';
import '../../../app/theme/tokens.dart';
import '../../../core/networking/api_client.dart';
import '../../../core/session/session_controller.dart';
import '../../../core/widgets/feedback_views.dart';
import '../application/profile_providers.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final t = LesenTokens.of(context);
    final text = Theme.of(context).textTheme;
    final profile = ref.watch(profileProvider);
    final user = ref.watch(sessionControllerProvider.select((s) => s.session?.user));
    final languages = ref.watch(languagesProvider).value;
    final topics = ref.watch(topicsProvider).value ?? const [];
    final config = ref.watch(appConfigProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.profileTitle)),
      body: profile.when(
        loading: () => const LoadingView(),
        error: (e, _) => FailureView(error: e, onRetry: () => ref.invalidate(profileProvider)),
        data: (p) => ListView(
          padding: const EdgeInsets.all(20),
          children: [
            if (user != null) ...[
              Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: t.brandSoft,
                    child: Text(user.firstName.characters.first.toUpperCase(), style: text.headlineSmall?.copyWith(color: t.brandStrong)),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(user.displayName, style: text.titleLarge),
                        Text(l10n.profileSignedInAs(user.email), style: text.bodySmall),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],
            if (p != null)
              Card(
                elevation: 0,
                color: t.surfaceRaised,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(LesenTokens.radiusCard)),
                child: Column(
                  children: [
                    ListTile(title: Text(l10n.profileInterface), trailing: Text(languages?.nameOf(p.interfaceLanguage) ?? p.interfaceLanguage)),
                    ListTile(title: Text(l10n.profileTarget), trailing: Text(languages?.nameOf(p.targetLanguage) ?? p.targetLanguage)),
                    ListTile(
                      title: Text(l10n.profileLevel),
                      trailing: Text(p.levelEstimated ? '${p.level.name} (${l10n.profileLevelEstimated})' : p.level.name),
                    ),
                    ListTile(title: Text(l10n.profileDaily), trailing: Text(l10n.minutesShort(p.dailyMinutes))),
                    ListTile(title: Text(l10n.profileDifficulty), trailing: Text(l10n.difficulty(p.difficulty))),
                    if (p.goals.isNotEmpty) ListTile(title: Text(l10n.profileGoals), subtitle: Text(p.goals.map(l10n.goal).join(' · '))),
                    if (p.topics.isNotEmpty)
                      ListTile(
                        title: Text(l10n.profileTopics),
                        subtitle: Text(
                          p.topics.map((s) => topics.where((t) => t.slug == s).map((t) => t.label(p.interfaceLanguage)).firstOrNull ?? s).join(' · '),
                        ),
                      ),
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () => context.go(Routes.editProfile()),
                          icon: const Icon(Icons.edit_outlined),
                          label: Text(l10n.profileEdit),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 24),
            OutlinedButton.icon(
              onPressed: () => ref.read(sessionControllerProvider.notifier).signOut(),
              icon: const Icon(Icons.logout),
              label: Text(l10n.profileSignOut),
            ),
            const SizedBox(height: 24),
            Text(l10n.profileVersion(config.version, config.environment), textAlign: TextAlign.center, style: text.bodySmall),
          ],
        ),
      ),
    );
  }
}
