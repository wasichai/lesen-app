import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../app/l10n.dart';
import '../../../app/routing/routes.dart';
import '../../../core/networking/api_failure.dart';
import '../application/vocabulary_providers.dart';
import '../data/vocabulary_repository.dart';
import '../domain/vocabulary.dart';
import 'word_status_badge.dart';

Future<void> showVocabularyItem(BuildContext context, VocabularyItem item) => showModalBottomSheet<void>(
  context: context,
  isScrollControlled: true,
  useSafeArea: true,
  builder: (_) => VocabularyItemSheet(item: item),
);

class VocabularyItemSheet extends ConsumerStatefulWidget {
  const VocabularyItemSheet({super.key, required this.item});

  final VocabularyItem item;

  @override
  ConsumerState<VocabularyItemSheet> createState() => _VocabularyItemSheetState();
}

class _VocabularyItemSheetState extends ConsumerState<VocabularyItemSheet> {
  late final _note = TextEditingController(text: widget.item.note);
  bool _saving = false;

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  Future<void> _saveNote() async {
    if ((_note.text.trim()) == (widget.item.note ?? '')) return;
    setState(() => _saving = true);
    try {
      final updated = await ref.read(vocabularyRepositoryProvider).setNote(widget.item.id, _note.text);
      ref.read(notebookProvider.notifier).replace(updated);
    } on ApiFailure catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(context.l10n.failure(e))));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _remove() async {
    final l10n = context.l10n;
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        content: Text(l10n.vocabRemoveConfirm(widget.item.lemma)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c, false), child: Text(l10n.commonCancel)),
          FilledButton(onPressed: () => Navigator.pop(c, true), child: Text(l10n.vocabRemove)),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    try {
      await ref.read(vocabularyRepositoryProvider).remove(widget.item.id);
      ref.read(notebookProvider.notifier).removeLocal(widget.item.id);
      ref.invalidate(vocabularyStatsProvider);
      if (mounted) Navigator.pop(context);
    } on ApiFailure catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.failure(e))));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final item = widget.item;
    final text = Theme.of(context).textTheme;
    final now = DateTime.now();
    final date = item.dueAt == null ? null : DateFormat.yMMMd(Localizations.localeOf(context).toLanguageTag()).format(item.dueAt!.toLocal());
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(item.lemma, style: text.headlineMedium, locale: Locale(item.language)),
                ),
                WordStatusBadge(item.status),
              ],
            ),
            if (item.pos != null) Text(item.pos!, style: text.labelMedium),
            const SizedBox(height: 8),
            Text(item.translations.join(', '), style: text.titleLarge?.copyWith(fontFamily: 'SourceSans3')),
            if (item.context != null) ...[
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(color: Theme.of(context).colorScheme.surfaceContainer, borderRadius: BorderRadius.circular(14)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.context!,
                      style: text.bodyLarge?.copyWith(fontFamily: 'Newsreader', fontSize: 18),
                      locale: Locale(item.language),
                    ),
                    if (item.source != null) ...[const SizedBox(height: 6), Text(l10n.vocabFrom(item.source!.title), style: text.bodySmall)],
                  ],
                ),
              ),
            ],
            const SizedBox(height: 12),
            Text(item.isDue(now) ? l10n.vocabDueNow : (date == null ? '' : l10n.vocabDueOn(date)), style: text.bodyMedium),
            Text(l10n.vocabReviews(item.reviews), style: text.bodySmall),
            const SizedBox(height: 16),
            TextField(
              controller: _note,
              maxLines: 3,
              minLines: 1,
              maxLength: 500,
              decoration: InputDecoration(
                labelText: l10n.vocabNote,
                hintText: l10n.vocabNoteHint,
                suffixIcon: _saving
                    ? const Padding(
                        padding: EdgeInsets.all(12),
                        child: SizedBox.square(dimension: 16, child: CircularProgressIndicator(strokeWidth: 2)),
                      )
                    : null,
              ),
              onEditingComplete: _saveNote,
              onTapOutside: (_) => _saveNote(),
            ),
            Wrap(
              spacing: 8,
              children: [
                TextButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    context.push(Routes.entry(item.entryKey));
                  },
                  icon: const Icon(Icons.menu_book_outlined),
                  label: Text(l10n.vocabOpenEntry),
                ),
                if (item.source != null)
                  TextButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      context.push(Routes.reader(item.source!.slug));
                    },
                    icon: const Icon(Icons.auto_stories_outlined),
                    label: Text(l10n.vocabOpenReading),
                  ),
                TextButton.icon(onPressed: _remove, icon: const Icon(Icons.delete_outline), label: Text(l10n.vocabRemove)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
