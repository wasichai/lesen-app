import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/l10n.dart';
import '../../../core/networking/api_failure.dart';
import '../../../core/widgets/feedback_views.dart';
import '../application/reader_providers.dart';
import 'reader_theme.dart';

Future<void> showNotesSheet(BuildContext context, {required String slug, required ReaderPalette palette, required Future<void> Function(String) onGo}) =>
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: palette.paper,
      builder: (_) => Theme(
        data: palette.theme(),
        child: _NotesSheet(slug: slug, onGo: onGo),
      ),
    );

class _NotesSheet extends ConsumerWidget {
  const _NotesSheet({required this.slug, required this.onGo});

  final String slug;
  final Future<void> Function(String) onGo;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final text = Theme.of(context).textTheme;
    final notes = ref.watch(notesProvider(slug));
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.6,
      maxChildSize: 0.95,
      builder: (context, scroll) => switch (notes) {
        AsyncData(:final value) when value.isEmpty => ListView(
          controller: scroll,
          children: [EmptyState(title: l10n.notesTitle, body: l10n.notesEmpty, icon: Icons.format_quote)],
        ),
        AsyncData(:final value) => ListView(
          controller: scroll,
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
          children: [
            Semantics(header: true, child: Text(l10n.notesTitle, style: text.headlineSmall)),
            const SizedBox(height: 12),
            for (final n in value)
              Card(
                elevation: 0,
                color: Theme.of(context).colorScheme.surfaceContainer,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 4, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('«${n.quote}»', style: text.bodyLarge?.copyWith(fontFamily: 'Newsreader')),
                      if (n.note != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(n.note!, style: text.bodyMedium),
                        ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                              onGo(n.sentenceRef);
                            },
                            child: Text(l10n.notesGo),
                          ),
                          IconButton(
                            tooltip: l10n.notesRemove,
                            icon: const Icon(Icons.delete_outline),
                            onPressed: () async {
                              try {
                                await ref.read(notesProvider(slug).notifier).remove(n.id);
                              } on ApiFailure catch (e) {
                                if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.failure(e))));
                              }
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
        AsyncError(:final error) => FailureView(error: error, onRetry: () => ref.invalidate(notesProvider(slug))),
        _ => const LoadingView(),
      },
    );
  }
}
