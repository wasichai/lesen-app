import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/l10n.dart';
import '../../../app/routing/routes.dart';
import '../../../app/theme/tokens.dart';
import '../../../core/widgets/feedback_views.dart';
import '../application/vocabulary_providers.dart';
import '../domain/known_words.dart';
import '../domain/vocabulary.dart';
import 'vocabulary_item_sheet.dart';
import 'word_status_badge.dart';

/// El cuaderno: lo que se guardó leyendo, con su oración, su estado y cuándo toca repasarlo.
class VocabularyScreen extends ConsumerStatefulWidget {
  const VocabularyScreen({super.key});

  @override
  ConsumerState<VocabularyScreen> createState() => _VocabularyScreenState();
}

class _VocabularyScreenState extends ConsumerState<VocabularyScreen> {
  final _scroll = ScrollController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _scroll.addListener(() {
      if (_scroll.position.extentAfter < 500) ref.read(notebookProvider.notifier).loadMore();
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final state = ref.watch(notebookProvider);
    final stats = ref.watch(vocabularyStatsProvider).value;
    final text = Theme.of(context).textTheme;
    final t = LesenTokens.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.vocabTitle),
        actions: [IconButton(tooltip: l10n.dictTitle, onPressed: () => context.push(Routes.dictionary), icon: const Icon(Icons.manage_search))],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(vocabularyStatsProvider);
          await ref.read(notebookProvider.notifier).refresh();
        },
        child: CustomScrollView(
          controller: _scroll,
          slivers: [
            if (stats != null && stats.total > 0)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
                  child: Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: [t.brandSoft, t.surfaceRaised]),
                      borderRadius: BorderRadius.circular(LesenTokens.radiusCard),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(l10n.vocabStatsTotal(stats.total), style: text.headlineSmall),
                        const SizedBox(height: 4),
                        Text('${l10n.vocabStatsToday(stats.reviewedToday)} · ${l10n.vocabStatsEncountered(stats.encountered)}', style: text.bodySmall),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 8,
                          runSpacing: 6,
                          children: [
                            for (final s in WordStatus.values)
                              if ((stats.byStatus[s] ?? 0) > 0)
                                Row(mainAxisSize: MainAxisSize.min, children: [WordStatusBadge(s), const SizedBox(width: 4), Text('${stats.byStatus[s]}')]),
                          ],
                        ),
                        const SizedBox(height: 14),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton.icon(
                            onPressed: stats.dueNow == 0 ? null : () => context.push(Routes.review),
                            icon: const Icon(Icons.style),
                            label: Text(l10n.vocabReviewDue(stats.dueNow)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                child: TextField(
                  textInputAction: TextInputAction.search,
                  decoration: InputDecoration(labelText: l10n.vocabSearch, prefixIcon: const Icon(Icons.search)),
                  onChanged: (v) {
                    _debounce?.cancel();
                    _debounce = Timer(const Duration(milliseconds: 350), () => ref.read(notebookProvider.notifier).filter(q: v));
                  },
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: SizedBox(
                height: 64,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                  children: [
                    ChoiceChip(
                      label: Text(l10n.vocabAll),
                      selected: state.status == null,
                      onSelected: (_) => ref.read(notebookProvider.notifier).filter(status: () => null),
                    ),
                    for (final s in WordStatus.values) ...[
                      const SizedBox(width: 6),
                      ChoiceChip(
                        label: Text(l10n.wordStatus(s)),
                        selected: state.status == s,
                        onSelected: (on) => ref.read(notebookProvider.notifier).filter(status: () => on ? s : null),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            if (state.items.isEmpty && state.loading)
              const SliverFillRemaining(child: LoadingView())
            else if (state.items.isEmpty && state.error != null)
              SliverFillRemaining(
                hasScrollBody: false,
                child: FailureView(error: state.error!, onRetry: () => ref.read(notebookProvider.notifier).refresh()),
              )
            else if (state.items.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: state.q.isEmpty && state.status == null
                    ? EmptyState(
                        title: l10n.vocabEmptyTitle,
                        body: l10n.vocabEmptyBody,
                        icon: Icons.style_outlined,
                        action: FilledButton(onPressed: () => context.go(Routes.discover), child: Text(l10n.navDiscover)),
                      )
                    : EmptyState(title: l10n.vocabNoResults, body: '', icon: Icons.search_off),
              )
            else
              SliverList.separated(
                itemCount: state.items.length,
                separatorBuilder: (_, _) => const Divider(indent: 20, endIndent: 20),
                itemBuilder: (_, i) => _WordTile(item: state.items[i]),
              ),
            const SliverToBoxAdapter(child: SizedBox(height: 24)),
          ],
        ),
      ),
    );
  }
}

class _WordTile extends StatelessWidget {
  const _WordTile({required this.item});

  final VocabularyItem item;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final t = LesenTokens.of(context);
    return InkWell(
      onTap: () => showVocabularyItem(context, item),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.lemma, style: text.titleLarge, locale: Locale(item.language)),
                  Text(item.translations.join(', '), style: text.bodyMedium),
                  if (item.context != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      item.context!,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: text.bodySmall?.copyWith(fontFamily: 'Newsreader', fontStyle: FontStyle.italic, color: t.inkMuted),
                      locale: Locale(item.language),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 12),
            WordStatusBadge(item.status),
          ],
        ),
      ),
    );
  }
}
