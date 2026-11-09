import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/l10n.dart';
import '../../../app/routing/routes.dart';
import '../../../core/networking/api_failure.dart';
import '../../../core/widgets/feedback_views.dart';
import '../../catalog/presentation/widgets/reading_card_view.dart';
import '../data/lists_repository.dart';

final listsProvider = FutureProvider.autoDispose.family<List<ReadingList>, String?>((ref, reading) => ref.watch(listsRepositoryProvider).all(reading: reading));

final listProvider = FutureProvider.autoDispose.family<ReadingList, String>((ref, id) => ref.watch(listsRepositoryProvider).get(id));

/// Pide un nombre y crea la lista; devuelve la nueva o `null`.
Future<ReadingList?> createListDialog(BuildContext context, WidgetRef ref) async {
  final l10n = context.l10n;
  final name = await showDialog<String>(context: context, builder: (_) => const _NameDialog());
  if (name == null || name.trim().isEmpty) return null;
  try {
    final list = await ref.read(listsRepositoryProvider).create(name);
    ref.invalidate(listsProvider);
    return list;
  } on ConflictFailure {
    if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.listsDuplicate)));
  } on ApiFailure catch (e) {
    if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.failure(e))));
  }
  return null;
}

Future<void> showAddToList(BuildContext context, String slug) => showModalBottomSheet<void>(
  context: context,
  isScrollControlled: true,
  useSafeArea: true,
  builder: (_) => _AddToList(slug: slug),
);

class _AddToList extends ConsumerWidget {
  const _AddToList({required this.slug});

  final String slug;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final lists = ref.watch(listsProvider(slug));
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Semantics(header: true, child: Text(l10n.listsAddTo, style: Theme.of(context).textTheme.headlineSmall)),
          const SizedBox(height: 8),
          switch (lists) {
            AsyncData(:final value) when value.isEmpty => Padding(padding: const EdgeInsets.symmetric(vertical: 12), child: Text(l10n.listsEmpty)),
            AsyncData(:final value) => Column(
              children: [
                for (final l in value)
                  CheckboxListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(l.name),
                    subtitle: Text(l10n.listsCount(l.count)),
                    value: l.contains,
                    onChanged: (v) async {
                      try {
                        await ref.read(listsRepositoryProvider).setMembership(l.id, slug, v ?? false);
                        ref.invalidate(listsProvider);
                      } on ApiFailure catch (e) {
                        if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.failure(e))));
                      }
                    },
                  ),
              ],
            ),
            AsyncError(:final error) => FailureView(error: error, compact: true, onRetry: () => ref.invalidate(listsProvider(slug))),
            _ => const Padding(padding: EdgeInsets.all(16), child: LoadingView()),
          },
          TextButton.icon(
            onPressed: () async {
              final created = await createListDialog(context, ref);
              if (created != null) await ref.read(listsRepositoryProvider).setMembership(created.id, slug, true);
              ref.invalidate(listsProvider);
            },
            icon: const Icon(Icons.add),
            label: Text(l10n.listsNew),
          ),
        ],
      ),
    );
  }
}

/// La sección «Mis listas» de la biblioteca.
class ListsSection extends ConsumerWidget {
  const ListsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final lists = ref.watch(listsProvider(null)).value ?? const <ReadingList>[];
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Semantics(header: true, child: Text(l10n.listsTitle, style: Theme.of(context).textTheme.headlineSmall)),
              ),
              IconButton(tooltip: l10n.listsNew, onPressed: () => createListDialog(context, ref), icon: const Icon(Icons.add)),
            ],
          ),
          if (lists.isEmpty)
            Text(l10n.listsEmpty, style: Theme.of(context).textTheme.bodySmall)
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final l in lists)
                  ActionChip(
                    avatar: const Icon(Icons.folder_outlined, size: 18),
                    label: Text('${l.name} · ${l.count}'),
                    onPressed: () => context.push(Routes.list(l.id)),
                  ),
              ],
            ),
        ],
      ),
    );
  }
}

class ListScreen extends ConsumerWidget {
  const ListScreen({super.key, required this.id});

  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final list = ref.watch(listProvider(id));
    return Scaffold(
      appBar: AppBar(
        title: Text(list.value?.name ?? ''),
        actions: [
          if (list.hasValue)
            IconButton(
              tooltip: l10n.listsDelete,
              icon: const Icon(Icons.delete_outline),
              onPressed: () async {
                final ok = await showDialog<bool>(
                  context: context,
                  builder: (c) => AlertDialog(
                    content: Text(l10n.listsDeleteConfirm(list.value!.name)),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(c, false), child: Text(l10n.commonCancel)),
                      FilledButton(onPressed: () => Navigator.pop(c, true), child: Text(l10n.listsDelete)),
                    ],
                  ),
                );
                if (ok != true) return;
                await ref.read(listsRepositoryProvider).delete(id);
                ref.invalidate(listsProvider);
                if (context.mounted) context.pop();
              },
            ),
        ],
      ),
      body: switch (list) {
        AsyncData(:final value) when value.readings.isEmpty => EmptyState(title: value.name, body: l10n.listsEmptyList, icon: Icons.folder_open),
        AsyncData(:final value) => ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          children: [for (final r in value.readings) ReadingListTile(reading: r, onTap: () => context.push(Routes.reading(r.slug)))],
        ),
        AsyncError(:final error) => FailureView(error: error, onRetry: () => ref.invalidate(listProvider(id))),
        _ => const LoadingView(),
      },
    );
  }
}

/// El diálogo es dueño de su controlador: se libera al desmontarse, después de la animación de salida.
class _NameDialog extends StatefulWidget {
  const _NameDialog();

  @override
  State<_NameDialog> createState() => _NameDialogState();
}

class _NameDialogState extends State<_NameDialog> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AlertDialog(
      title: Text(l10n.listsNew),
      content: TextField(
        controller: _controller,
        autofocus: true,
        maxLength: 80,
        decoration: InputDecoration(labelText: l10n.listsName),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.commonCancel)),
        FilledButton(onPressed: () => Navigator.pop(context, _controller.text), child: Text(l10n.listsCreate)),
      ],
    );
  }
}
