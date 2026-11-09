import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/l10n.dart';
import '../../../../app/theme/tokens.dart';
import '../../../../core/networking/api_failure.dart';
import '../../../../core/widgets/feedback_views.dart';
import '../../../dictionary/domain/entry.dart';
import '../../application/reader_providers.dart';
import '../../data/reader_repository.dart';
import '../../domain/reading_content.dart';

/// El diccionario en contexto: primero lo esencial (lema, traducción, categoría, pronunciación) y, al expandir, el
/// resto. Debajo, la oración con sus acciones. Sirve igual en la hoja inferior del teléfono y en el panel de la tableta.
class WordPanel extends ConsumerStatefulWidget {
  const WordPanel({
    super.key,
    required this.slug,
    required this.version,
    required this.language,
    required this.token,
    required this.sentence,
    this.onClose,
    this.onPlayFrom,
  });

  final String slug;
  final int version;
  final String language;
  final Token token;
  final Sentence sentence;
  final VoidCallback? onClose;

  /// Si la lectura tiene narración: escucharla desde esta palabra.
  final VoidCallback? onPlayFrom;

  @override
  ConsumerState<WordPanel> createState() => _WordPanelState();
}

class _WordPanelState extends ConsumerState<WordPanel> {
  bool _expanded = false;
  bool _saving = false;
  bool _showSentence = false;

  @override
  void didUpdateWidget(WordPanel old) {
    super.didUpdateWidget(old);
    if (old.token.id != widget.token.id) {
      _expanded = false;
      _showSentence = false;
    }
  }

  TokenRef get _ref => (slug: widget.slug, version: widget.version, tokenId: widget.token.id);

  Future<void> _save(Entry entry) async {
    setState(() => _saving = true);
    final messenger = ScaffoldMessenger.maybeOf(context);
    final l10n = context.l10n;
    try {
      await ref
          .read(knownWordsProvider(widget.language).notifier)
          .save(entryKey: entry.key, slug: widget.slug, version: widget.version, tokenRef: widget.token.id);
      if (mounted) unawaited(SemanticsService.sendAnnouncement(View.of(context), l10n.wordSaved, Directionality.of(context)));
    } on ApiFailure {
      messenger?.showSnackBar(SnackBar(content: Text(l10n.wordSaveFailed)));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _saveSentence() async {
    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.maybeOf(context);
    final note = await showDialog<String>(context: context, builder: (_) => const _NoteDialog());
    if (note == null) return;
    try {
      await ref.read(notesProvider(widget.slug).notifier).add(version: widget.version, sentenceRef: widget.sentence.id, note: note);
      messenger?.showSnackBar(SnackBar(content: Text(l10n.wordSentenceSaved)));
    } on ApiFailure catch (e) {
      messenger?.showSnackBar(SnackBar(content: Text(l10n.failure(e))));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final lookup = ref.watch(lookupProvider(_ref));
    final saved = ref.watch(knownWordsProvider(widget.language).select((k) => widget.token.entry != null && k.isSaved(widget.token.entry!)));
    final text = Theme.of(context).textTheme;
    final muted = Theme.of(context).colorScheme.onSurfaceVariant;

    final header = Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Semantics(
            header: true,
            label: l10n.wordTitle(widget.token.text),
            child: Text(widget.token.text, style: text.headlineMedium, locale: Locale(widget.language)),
          ),
        ),
        if (widget.onClose != null) IconButton(tooltip: l10n.commonClose, onPressed: widget.onClose, icon: const Icon(Icons.close)),
      ],
    );

    final body = switch (lookup) {
      AsyncData(:final value) => _entryView(context, value, saved),
      AsyncError(:final error) => FailureView(error: error, compact: true, onRetry: () => ref.invalidate(lookupProvider(_ref))),
      _ => Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Row(
          children: [
            const SizedBox.square(dimension: 18, child: CircularProgressIndicator(strokeWidth: 2)),
            const SizedBox(width: 12),
            Text(l10n.wordLoading, style: text.bodyMedium?.copyWith(color: muted)),
          ],
        ),
      ),
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [header, const SizedBox(height: 4), body, const SizedBox(height: 20), _sentenceSection(context)],
    );
  }

  Widget _entryView(BuildContext context, Lookup lookup, bool saved) {
    final l10n = context.l10n;
    final text = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final entry = lookup.entry;
    if (entry == null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          Text(l10n.wordNoEntry, style: text.titleMedium),
          const SizedBox(height: 4),
          Text(l10n.wordNoEntryBody, style: text.bodyMedium?.copyWith(color: scheme.onSurfaceVariant)),
          if (lookup.alternatives.isNotEmpty) ...[const SizedBox(height: 12), _alternatives(context, lookup.alternatives)],
        ],
      );
    }
    final first = entry.senses.firstOrNull;
    final chips = <Widget>[
      if (entry.pos != null) _Tag(entry.pos!),
      if (entry.ipa != null) Semantics(label: '${l10n.wordPronunciation}: ${entry.ipa}', excludeSemantics: true, child: _Tag('/${entry.ipa}/')),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (lookup.inflected && entry.lemma != lookup.token)
          Text(l10n.wordFormOf(lookup.token, entry.lemma), style: text.bodyMedium?.copyWith(color: scheme.onSurfaceVariant))
        else if (entry.lemma != widget.token.text)
          Text(
            entry.lemma,
            style: text.titleMedium?.copyWith(color: scheme.onSurfaceVariant),
            locale: Locale(widget.language),
          ),
        if (chips.isNotEmpty) ...[const SizedBox(height: 8), Wrap(spacing: 6, runSpacing: 6, children: chips)],
        const SizedBox(height: 12),
        Text(
          entry.translations.join(', '),
          style: text.headlineSmall?.copyWith(fontFamily: 'SourceSans3', fontWeight: FontWeight.w600),
        ),
        if (first?.definition != null) ...[const SizedBox(height: 6), Text(first!.definition!, style: text.bodyMedium)],
        if (_expanded) ..._details(context, entry, lookup),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: saved
                  ? OutlinedButton.icon(onPressed: null, icon: const Icon(Icons.check), label: Text(l10n.wordSaved))
                  : FilledButton.icon(
                      onPressed: _saving ? null : () => _save(entry),
                      icon: const Icon(Icons.bookmark_add_outlined),
                      label: Text(_saving ? l10n.wordSaving : l10n.wordSave),
                    ),
            ),
            const SizedBox(width: 8),
            TextButton(onPressed: () => setState(() => _expanded = !_expanded), child: Text(_expanded ? l10n.wordLess : l10n.wordMore)),
          ],
        ),
      ],
    );
  }

  List<Widget> _details(BuildContext context, Entry entry, Lookup lookup) {
    final l10n = context.l10n;
    final text = Theme.of(context).textTheme;
    final muted = Theme.of(context).colorScheme.onSurfaceVariant;
    Widget title(String s) => Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 6),
      child: Text(s, style: text.titleSmall),
    );
    final out = <Widget>[];
    for (final (i, sense) in entry.senses.indexed) {
      if (i > 0) {
        out
          ..add(const SizedBox(height: 12))
          ..add(Text('${i + 1}. ${sense.translations.join(', ')}', style: text.titleMedium));
        if (sense.definition != null) out.add(Text(sense.definition!, style: text.bodyMedium));
      }
      if (sense.examples.isNotEmpty) {
        out.add(title(l10n.wordExamples));
        for (final e in sense.examples) {
          out.add(
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    e.text,
                    style: text.bodyLarge?.copyWith(fontFamily: 'Newsreader'),
                    locale: Locale(widget.language),
                  ),
                  if (e.translation != null) Text(e.translation!, style: text.bodySmall?.copyWith(color: muted)),
                ],
              ),
            ),
          );
        }
      }
      if (sense.synonyms.isNotEmpty) out.addAll([title(l10n.wordSynonyms), Text(sense.synonyms.join(', '), locale: Locale(widget.language))]);
      if (sense.antonyms.isNotEmpty) out.addAll([title(l10n.wordAntonyms), Text(sense.antonyms.join(', '), locale: Locale(widget.language))]);
      if (sense.related.isNotEmpty) out.addAll([title(l10n.wordRelated), Text(sense.related.map((r) => r.lemma).join(', '), locale: Locale(widget.language))]);
      if (sense.note != null) out.addAll([title(l10n.wordNote), Text(sense.note!)]);
    }
    if (entry.grammar.isNotEmpty) {
      out.add(title(l10n.wordGrammar));
      out.add(Wrap(spacing: 6, runSpacing: 6, children: [for (final g in entry.grammar.entries) _Tag('${g.key}: ${g.value}')]));
    }
    if (entry.forms.isNotEmpty) out.addAll([title(l10n.wordForms), Text(entry.forms.join(' · '), locale: Locale(widget.language))]);
    if (lookup.alternatives.isNotEmpty) out.addAll([title(l10n.wordAlternatives), _alternatives(context, lookup.alternatives)]);
    return out;
  }

  Widget _alternatives(BuildContext context, List<EntrySummary> alternatives) =>
      Wrap(spacing: 6, runSpacing: 6, children: [for (final a in alternatives) _Tag('${a.lemma} · ${a.translations.take(2).join(', ')}')]);

  Widget _sentenceSection(BuildContext context) {
    final l10n = context.l10n;
    final text = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final sentenceText = widget.sentence.text;
    final translations = _showSentence ? ref.watch(translationsProvider((slug: widget.slug, version: widget.version, unit: TranslationUnit.SENTENCE))) : null;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: scheme.surfaceContainer, borderRadius: BorderRadius.circular(LesenTokens.radiusLg)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.wordInContext.toUpperCase(), style: text.labelSmall?.copyWith(letterSpacing: 1)),
          const SizedBox(height: 6),
          Text(
            sentenceText,
            style: text.bodyLarge?.copyWith(fontFamily: 'Newsreader', fontSize: 18),
            locale: Locale(widget.language),
          ),
          if (translations != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: switch (translations) {
                AsyncData(:final value) => Semantics(
                  liveRegion: true,
                  child: Text(value[widget.sentence.id] ?? l10n.wordSentenceUnavailable, style: text.bodyMedium?.copyWith(fontStyle: FontStyle.italic)),
                ),
                AsyncError(:final error) => Text(l10n.failure(error), style: text.bodySmall),
                _ => const LinearProgressIndicator(),
              },
            ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 4,
            runSpacing: 4,
            children: [
              if (widget.onPlayFrom != null)
                TextButton.icon(onPressed: widget.onPlayFrom, icon: const Icon(Icons.play_circle_outline, size: 18), label: Text(l10n.audioFromHere)),
              TextButton.icon(
                onPressed: () => setState(() => _showSentence = !_showSentence),
                icon: const Icon(Icons.translate, size: 18),
                label: Text(_showSentence ? l10n.wordHideSentence : l10n.wordTranslateSentence),
              ),
              TextButton.icon(onPressed: _saveSentence, icon: const Icon(Icons.format_quote, size: 18), label: Text(l10n.wordSaveSentence)),
              TextButton.icon(
                onPressed: () async {
                  await Clipboard.setData(ClipboardData(text: sentenceText));
                  if (context.mounted) ScaffoldMessenger.maybeOf(context)?.showSnackBar(SnackBar(content: Text(l10n.wordCopied)));
                },
                icon: const Icon(Icons.copy, size: 18),
                label: Text(l10n.wordCopySentence),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag(this.label);

  final String label;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: BoxDecoration(
      border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      borderRadius: BorderRadius.circular(LesenTokens.radiusSm),
    ),
    child: Text(label, style: Theme.of(context).textTheme.labelMedium),
  );
}

class _NoteDialog extends StatefulWidget {
  const _NoteDialog();

  @override
  State<_NoteDialog> createState() => _NoteDialogState();
}

class _NoteDialogState extends State<_NoteDialog> {
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
      title: Text(l10n.wordSaveSentence),
      content: TextField(
        controller: _controller,
        autofocus: true,
        maxLength: 2000,
        maxLines: 4,
        minLines: 2,
        decoration: InputDecoration(hintText: l10n.wordAddNote),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.commonCancel)),
        FilledButton(onPressed: () => Navigator.pop(context, _controller.text), child: Text(l10n.commonSave)),
      ],
    );
  }
}
