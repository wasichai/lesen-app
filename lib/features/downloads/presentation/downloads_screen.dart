import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/l10n.dart';
import '../../../app/routing/routes.dart';
import '../../../core/widgets/feedback_views.dart';
import '../application/downloads_controller.dart';
import '../domain/download.dart';
import 'download_button.dart';

/// Lo descargado, cuánto ocupa y la preferencia de descargar el audio solo con Wi-Fi.
class DownloadsScreen extends ConsumerWidget {
  const DownloadsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final downloads = ref.watch(downloadsProvider).values.toList()..sort((a, b) => a.title.compareTo(b.title));
    final total = downloads.fold<int>(0, (a, d) => a + d.bytes);
    final wifiOnly = ref.watch(appPrefsProvider.select((p) => p['wifiOnly'] as bool? ?? true));
    return Scaffold(
      appBar: AppBar(title: Text(l10n.downloadsTitle)),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          SwitchListTile(title: Text(l10n.downloadsWifiOnly), value: wifiOnly, onChanged: (v) => ref.read(appPrefsProvider.notifier).set('wifiOnly', v)),
          if (downloads.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: Text(l10n.downloadsStorage(formatBytes(total)), style: Theme.of(context).textTheme.bodySmall),
            ),
          if (downloads.isEmpty)
            EmptyState(title: l10n.downloadsEmpty, body: l10n.downloadsEmptyBody, icon: Icons.download_for_offline_outlined)
          else
            for (final d in downloads)
              ListTile(
                title: Text(d.title),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: DownloadButton(slug: d.slug),
                ),
                onTap: d.readableOffline ? () => context.push(Routes.reader(d.slug)) : null,
              ),
        ],
      ),
    );
  }
}
