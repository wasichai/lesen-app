import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/l10n.dart';
import '../../../app/routing/routes.dart';
import '../../../app/theme/tokens.dart';
import '../../../core/networking/api_client.dart';
import '../../../core/session/session_controller.dart';
import '../../../core/sync/outbox.dart';
import '../../../core/sync/sync.dart';
import '../../audio/application/playback_controller.dart';
import '../../downloads/application/downloads_controller.dart';
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
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(t.radiusCard)),
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
            const SizedBox(height: 16),
            const _SyncCard(),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.download_for_offline_outlined),
              title: Text(l10n.downloadsTitle),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push(Routes.downloads),
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: () async {
                // nada se pierde en silencio: si queda algo por enviar, se avisa antes
                final pending = ref.read(syncStatusProvider).value?.pending ?? 0;
                if (pending > 0) {
                  final ok = await showDialog<bool>(
                    context: context,
                    builder: (c) => AlertDialog(
                      title: Text(l10n.signOutPendingTitle),
                      content: Text(l10n.signOutPendingBody(pending)),
                      actions: [
                        TextButton(onPressed: () => Navigator.pop(c, false), child: Text(l10n.commonCancel)),
                        TextButton(onPressed: () => Navigator.pop(c, true), child: Text(l10n.signOutAnyway)),
                      ],
                    ),
                  );
                  if (ok != true) return;
                }
                await ref.read(playbackProvider.notifier).close();
                await ref.read(downloadsProvider.notifier).removeAll();
                await ref.read(sessionControllerProvider.notifier).signOut();
              },
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

/// Lo que espera para enviarse y lo que el servidor rechazó (nunca se borra en silencio).
class _SyncCard extends ConsumerWidget {
  const _SyncCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final status = ref.watch(syncStatusProvider).value ?? SyncStatus.idle;
    final text = Theme.of(context).textTheme;
    final outbox = ref.read(outboxProvider);
    return Card(
      elevation: 0,
      color: LesenTokens.of(context).surfaceRaised,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.syncTitle, style: text.titleMedium),
            const SizedBox(height: 4),
            Semantics(liveRegion: true, child: Text(status.syncing ? l10n.syncing : l10n.syncPending(status.pending), style: text.bodyMedium)),
            if (status.rejected.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(l10n.syncRejected(status.rejected.length), style: text.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.error)),
              for (final op in status.rejected)
                Row(
                  children: [
                    Expanded(child: Text('${op.kind} · ${op.error ?? ''}', style: text.bodySmall)),
                    TextButton(onPressed: () => outbox.discard(op), child: Text(l10n.syncDiscard)),
                  ],
                ),
            ],
            if (status.pending > 0)
              Align(
                alignment: AlignmentDirectional.centerEnd,
                child: TextButton.icon(onPressed: () => outbox.flush(force: true), icon: const Icon(Icons.sync), label: Text(l10n.syncNow)),
              ),
          ],
        ),
      ),
    );
  }
}
