import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/l10n.dart';
import '../application/downloads_controller.dart';
import '../domain/download.dart';

/// El estado de la descarga de una lectura, con su acción: descargar, cancelar, reintentar o quitar.
class DownloadButton extends ConsumerWidget {
  const DownloadButton({super.key, required this.slug});

  final String slug;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (kIsWeb) return const SizedBox.shrink();
    final l10n = context.l10n;
    final d = ref.watch(downloadsProvider.select((s) => s[slug]));
    final c = ref.read(downloadsProvider.notifier);
    final text = Theme.of(context).textTheme;
    if (d == null || d.state == DownloadState.cancelled) {
      return TextButton.icon(onPressed: () => c.download(slug), icon: const Icon(Icons.download_outlined), label: Text(l10n.downloadAction));
    }
    return switch (d.state) {
      DownloadState.queued || DownloadState.downloading => Row(
        children: [
          Expanded(
            child: Semantics(
              liveRegion: true,
              label: l10n.downloadProgress((d.progress * 100).round()),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ExcludeSemantics(
                    child: Text(
                      d.state == DownloadState.queued ? l10n.downloadQueued : l10n.downloadProgress((d.progress * 100).round()),
                      style: text.bodySmall,
                    ),
                  ),
                  const SizedBox(height: 4),
                  LinearProgressIndicator(value: d.progress, minHeight: 4, borderRadius: BorderRadius.circular(2)),
                ],
              ),
            ),
          ),
          IconButton(tooltip: l10n.downloadCancel, onPressed: () => c.cancel(slug), icon: const Icon(Icons.close)),
        ],
      ),
      DownloadState.done || DownloadState.waitingWifi => Row(
        children: [
          Icon(d.state == DownloadState.done ? Icons.offline_pin : Icons.wifi_find, size: 20),
          const SizedBox(width: 8),
          Expanded(child: Text(d.state == DownloadState.done ? l10n.downloadDone : l10n.downloadWaitingWifi, style: text.bodySmall)),
          if (d.state == DownloadState.waitingWifi) IconButton(tooltip: l10n.downloadRetry, onPressed: () => c.download(slug), icon: const Icon(Icons.refresh)),
          IconButton(tooltip: l10n.downloadRemove, onPressed: () => c.remove(slug), icon: const Icon(Icons.delete_outline)),
        ],
      ),
      _ => Row(
        children: [
          const Icon(Icons.error_outline, size: 20),
          const SizedBox(width: 8),
          Expanded(child: Text(l10n.downloadFailed, style: text.bodySmall)),
          TextButton(onPressed: () => c.download(slug), child: Text(l10n.downloadRetry)),
        ],
      ),
    };
  }
}
