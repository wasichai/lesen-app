import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/l10n.dart';
import '../../profile/application/profile_providers.dart';
import '../domain/catalog_query.dart';
import '../domain/reading.dart';

/// Todos los filtros del catálogo en una hoja inferior; devuelve la consulta nueva al aplicar.
class CatalogFiltersSheet extends ConsumerStatefulWidget {
  const CatalogFiltersSheet({super.key, required this.initial});

  final CatalogQuery initial;

  @override
  ConsumerState<CatalogFiltersSheet> createState() => _CatalogFiltersSheetState();
}

class _CatalogFiltersSheetState extends ConsumerState<CatalogFiltersSheet> {
  late CatalogQuery _q = widget.initial;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final text = Theme.of(context).textTheme;
    final languages = ref.watch(languagesProvider).value;
    final topics = ref.watch(topicsProvider).value ?? const <Topic>[];
    final locale = Localizations.localeOf(context).languageCode;

    Widget section(String title, List<Widget> chips) => Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: text.titleMedium),
          const SizedBox(height: 10),
          Wrap(spacing: 8, runSpacing: 8, children: chips),
        ],
      ),
    );

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.85,
      maxChildSize: 0.95,
      builder: (context, scroll) => Column(
        children: [
          Expanded(
            child: ListView(
              controller: scroll,
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
              children: [
                Semantics(header: true, child: Text(l10n.catalogFilters, style: text.headlineSmall)),
                const SizedBox(height: 16),
                if (languages != null)
                  section(l10n.catalogLanguage, [
                    ChoiceChip(
                      label: Text(l10n.catalogAllLanguages),
                      selected: _q.language == null,
                      onSelected: (_) => setState(() => _q = _q.copyWith(language: () => null)),
                    ),
                    for (final lang in languages.studyLanguages)
                      ChoiceChip(
                        label: Text(lang.nativeName),
                        selected: _q.language == lang.code,
                        onSelected: (_) => setState(() => _q = _q.copyWith(language: () => lang.code)),
                      ),
                  ]),
                section(l10n.catalogLevel, [
                  for (final level in CefrLevel.values)
                    FilterChip(
                      label: Text(level.name),
                      tooltip: l10n.levelDescription(level),
                      selected: _q.levels.contains(level),
                      onSelected: (on) => setState(() => _q = _q.copyWith(levels: on ? {..._q.levels, level} : ({..._q.levels}..remove(level)))),
                    ),
                ]),
                if (topics.isNotEmpty)
                  section(l10n.catalogTopic, [
                    ChoiceChip(
                      label: Text(l10n.catalogAllTopics),
                      selected: _q.topic == null,
                      onSelected: (_) => setState(() => _q = _q.copyWith(topic: () => null)),
                    ),
                    for (final topic in topics) ...[
                      ChoiceChip(
                        label: Text(topic.label(locale)),
                        selected: _q.topic == topic.slug,
                        onSelected: (_) => setState(() => _q = _q.copyWith(topic: () => topic.slug)),
                      ),
                      for (final child in topic.children)
                        ChoiceChip(
                          label: Text('${topic.label(locale)} · ${child.label(locale)}'),
                          selected: _q.topic == child.slug,
                          onSelected: (_) => setState(() => _q = _q.copyWith(topic: () => child.slug)),
                        ),
                    ],
                  ]),
                section(l10n.catalogDuration, [
                  for (final d in DurationRange.values)
                    ChoiceChip(
                      label: Text(l10n.duration(d)),
                      selected: _q.duration == d,
                      onSelected: (on) => setState(() => _q = _q.copyWith(duration: () => on ? d : null)),
                    ),
                ]),
                section(l10n.catalogStatus, [
                  for (final s in CatalogStatus.values)
                    ChoiceChip(
                      label: Text(l10n.status(s)),
                      selected: _q.status == s,
                      onSelected: (on) => setState(() => _q = _q.copyWith(status: () => on ? s : null)),
                    ),
                ]),
                section(l10n.catalogSort, [
                  for (final s in CatalogSort.values)
                    ChoiceChip(
                      label: Text(l10n.sort(s)),
                      selected: _q.sort == s,
                      onSelected: (_) => setState(() => _q = _q.copyWith(sort: s)),
                    ),
                ]),
              ],
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(onPressed: () => setState(() => _q = _q.cleared()), child: Text(l10n.catalogClear)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(onPressed: () => Navigator.pop(context, _q), child: Text(l10n.catalogApply)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
