import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/l10n.dart';
import '../../../app/routing/routes.dart';
import '../../../app/theme/tokens.dart';
import '../../../core/networking/api_failure.dart';
import '../../../core/widgets/feedback_views.dart';
import '../../vocabulary/application/vocabulary_providers.dart';
import '../../vocabulary/data/vocabulary_repository.dart';
import '../application/dictionary_providers.dart';
import '../data/dictionary_repository.dart';
import '../domain/entry.dart';

/// La entrada completa: todos los significados con sus ejemplos, gramática, formas, relaciones y dónde aparece.
class EntryScreen extends ConsumerWidget {
  const EntryScreen({super.key, required this.entryKey});

  final String entryKey;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entry = ref.watch(entryProvider(entryKey));
    return Scaffold(
      appBar: AppBar(),
      body: switch (entry) {
        AsyncData(:final value) => _EntryBody(entry: value),
        AsyncError(:final error) => FailureView(error: error, onRetry: () => ref.invalidate(entryProvider(entryKey))),
        _ => const LoadingView(),
      },
    );
  }
}

class _EntryBody extends ConsumerStatefulWidget {
  const _EntryBody({required this.entry});

  final Entry entry;

  @override
  ConsumerState<_EntryBody> createState() => _EntryBodyState();
}

class _EntryBodyState extends ConsumerState<_EntryBody> {
  late bool _favorite = widget.entry.favorite;
  late bool _saved = widget.entry.saved;

  Future<void> _toggleFavorite() async {
    final next = !_favorite;
    setState(() => _favorite = next);
    try {
      await ref.read(dictionaryRepositoryProvider).setFavorite(widget.entry.key, next);
      ref.invalidate(dictionaryFavoritesProvider);
    } on ApiFailure catch (e) {
      if (!mounted) return;
      setState(() => _favorite = !next);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(context.l10n.failure(e))));
    }
  }

  Future<void> _save() async {
    try {
      await ref.read(vocabularyRepositoryProvider).save(entryKey: widget.entry.key);
      setState(() => _saved = true);
      ref.invalidate(vocabularyStatsProvider);
    } on ApiFailure catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(context.l10n.failure(e))));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final e = widget.entry;
    final text = Theme.of(context).textTheme;
    final t = LesenTokens.of(context);
    final locale = Locale(e.language);
    Widget section(String title, Widget child) => Padding(
      padding: const EdgeInsets.only(top: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: text.titleMedium),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Semantics(
                header: true,
                child: Text(e.lemma, style: text.displaySmall, locale: locale),
              ),
            ),
            Semantics(
              toggled: _favorite,
              child: IconButton(
                tooltip: _favorite ? l10n.dictUnfavorite : l10n.dictFavorite,
                onPressed: _toggleFavorite,
                icon: Icon(_favorite ? Icons.star : Icons.star_outline, color: _favorite ? t.brand : null),
              ),
            ),
          ],
        ),
        Wrap(
          spacing: 8,
          children: [
            if (e.pos != null) Chip(label: Text(e.pos!)),
            if (e.ipa != null)
              Semantics(
                label: '${l10n.wordPronunciation}: ${e.ipa}',
                excludeSemantics: true,
                child: Chip(label: Text('/${e.ipa}/')),
              ),
          ],
        ),
        const SizedBox(height: 8),
        _saved
            ? OutlinedButton.icon(onPressed: null, icon: const Icon(Icons.check), label: Text(l10n.wordSaved))
            : FilledButton.icon(onPressed: _save, icon: const Icon(Icons.bookmark_add_outlined), label: Text(l10n.wordSave)),
        section(
          l10n.dictMeanings,
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final (i, s) in e.senses.indexed)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${i + 1}. ${s.translations.join(', ')}', style: text.titleLarge?.copyWith(fontFamily: t.interfaceFont)),
                      if (s.definition != null) Text(s.definition!, style: text.bodyMedium),
                      for (final ex in s.examples)
                        Padding(
                          padding: const EdgeInsets.only(top: 6, left: 12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                ex.text,
                                style: text.bodyLarge?.copyWith(fontFamily: t.readingFont, fontStyle: FontStyle.italic),
                                locale: locale,
                              ),
                              if (ex.translation != null) Text(ex.translation!, style: text.bodySmall),
                            ],
                          ),
                        ),
                      if (s.synonyms.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text('${l10n.wordSynonyms}: ${s.synonyms.join(', ')}', locale: locale),
                        ),
                      if (s.antonyms.isNotEmpty) Text('${l10n.wordAntonyms}: ${s.antonyms.join(', ')}', locale: locale),
                      if (s.note != null) Padding(padding: const EdgeInsets.only(top: 6), child: Text('${l10n.wordNote}: ${s.note}')),
                      if (s.related.isNotEmpty)
                        Wrap(
                          spacing: 6,
                          children: [for (final r in s.related) ActionChip(label: Text(r.lemma), onPressed: () => context.push(Routes.entry(r.key)))],
                        ),
                    ],
                  ),
                ),
            ],
          ),
        ),
        if (e.grammar.isNotEmpty)
          section(l10n.wordGrammar, Wrap(spacing: 8, runSpacing: 8, children: [for (final g in e.grammar.entries) Chip(label: Text('${g.key}: ${g.value}'))])),
        if (e.forms.isNotEmpty) section(l10n.wordForms, Text(e.forms.join(' · '), style: text.bodyLarge, locale: locale)),
        if (e.readings.isNotEmpty)
          section(
            l10n.dictAppearsIn,
            Column(
              children: [
                for (final r in e.readings)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.auto_stories_outlined),
                    title: Text(r.title, locale: locale),
                    subtitle: Text('${r.level} · ${l10n.dictOccurrences(r.occurrences)}'),
                    onTap: () => context.push(Routes.reading(r.slug)),
                  ),
              ],
            ),
          ),
      ],
    );
  }
}
