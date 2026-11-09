import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/l10n.dart';
import '../../../app/routing/routes.dart';
import '../../../core/widgets/feedback_views.dart';
import '../../profile/application/profile_providers.dart';
import '../application/dictionary_providers.dart';
import '../data/dictionary_repository.dart';
import '../domain/entry.dart';

/// El diccionario bilingüe: búsqueda en los dos idiomas, historial y favoritas.
class DictionaryScreen extends ConsumerStatefulWidget {
  const DictionaryScreen({super.key});

  @override
  ConsumerState<DictionaryScreen> createState() => _DictionaryScreenState();
}

class _DictionaryScreenState extends ConsumerState<DictionaryScreen> {
  final _controller = TextEditingController();
  Timer? _debounce;
  String _q = '';

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _open(String key) {
    // al elegir, la búsqueda queda en el historial
    if (_q.trim().length >= 2) unawaited(ref.read(dictionaryRepositoryProvider).search(_q.trim(), limit: 1, record: true).then((_) {}, onError: (_) {}));
    context.push(Routes.entry(key));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final profile = ref.watch(profileProvider).value;
    final langs = ref.watch(languagesProvider).value;
    final hint = profile == null || langs == null
        ? l10n.dictTitle
        : l10n.dictSearchHint(langs.nameOf(profile.targetLanguage), langs.nameOf(profile.interfaceLanguage));
    final results = ref.watch(dictionarySearchProvider(_q));
    return Scaffold(
      appBar: AppBar(title: Text(l10n.dictTitle)),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
            child: TextField(
              controller: _controller,
              autofocus: true,
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(hintText: hint, prefixIcon: const Icon(Icons.search)),
              onChanged: (v) {
                _debounce?.cancel();
                _debounce = Timer(const Duration(milliseconds: 250), () => setState(() => _q = v));
              },
            ),
          ),
          Expanded(
            child: _q.trim().length < 2
                ? _Home(
                    onOpen: (k) => context.push(Routes.entry(k)),
                    onQuery: (q) {
                      _controller.text = q;
                      setState(() => _q = q);
                    },
                  )
                : switch (results) {
                    AsyncData(:final value) when value.isEmpty => EmptyState(
                      title: l10n.dictNoResults(_q.trim()),
                      body: l10n.dictEmptyBody,
                      icon: Icons.search_off,
                    ),
                    AsyncData(:final value) => ListView.separated(
                      itemCount: value.length,
                      separatorBuilder: (_, _) => const Divider(indent: 20, endIndent: 20),
                      itemBuilder: (_, i) => _SummaryTile(summary: value[i], onTap: () => _open(value[i].key)),
                    ),
                    AsyncError(:final error) => FailureView(error: error, onRetry: () => ref.invalidate(dictionarySearchProvider(_q))),
                    _ => const LoadingView(),
                  },
          ),
        ],
      ),
    );
  }
}

class _Home extends ConsumerWidget {
  const _Home({required this.onOpen, required this.onQuery});

  final void Function(String key) onOpen;
  final void Function(String q) onQuery;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final text = Theme.of(context).textTheme;
    final history = ref.watch(dictionaryHistoryProvider).value ?? const [];
    final favorites = ref.watch(dictionaryFavoritesProvider).value ?? const [];
    if (history.isEmpty && favorites.isEmpty) return EmptyState(title: l10n.dictTitle, body: l10n.dictEmptyBody, icon: Icons.translate);
    return ListView(
      padding: const EdgeInsets.only(bottom: 24),
      children: [
        if (favorites.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
            child: Text(l10n.dictFavorites, style: text.titleMedium),
          ),
          for (final f in favorites) _SummaryTile(summary: f, onTap: () => onOpen(f.key)),
        ],
        if (history.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 8, 4),
            child: Row(
              children: [
                Expanded(child: Text(l10n.dictHistory, style: text.titleMedium)),
                TextButton(
                  onPressed: () async {
                    await ref.read(dictionaryRepositoryProvider).clearHistory();
                    ref.invalidate(dictionaryHistoryProvider);
                  },
                  child: Text(l10n.dictClearHistory),
                ),
              ],
            ),
          ),
          for (final h in history)
            ListTile(leading: const Icon(Icons.history), title: Text(h.query), onTap: () => h.entryKey != null ? onOpen(h.entryKey!) : onQuery(h.query)),
        ],
      ],
    );
  }
}

class _SummaryTile extends StatelessWidget {
  const _SummaryTile({required this.summary, required this.onTap});

  final EntrySummary summary;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => ListTile(
    contentPadding: const EdgeInsets.symmetric(horizontal: 20),
    title: Text(summary.lemma, style: Theme.of(context).textTheme.titleLarge, locale: Locale(summary.language)),
    subtitle: Text([if (summary.pos != null) summary.pos!, summary.translations.join(', ')].join(' · ')),
    trailing: Text(summary.language.toUpperCase(), style: Theme.of(context).textTheme.labelSmall),
    onTap: onTap,
  );
}
