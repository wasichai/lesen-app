import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/l10n.dart';
import '../../../app/theme/tokens.dart';
import '../application/reader_providers.dart';
import '../domain/reader_preferences.dart';
import 'reader_theme.dart';

Future<void> showReaderSettings(BuildContext context, {required ReaderPalette palette, required bool wide}) => showModalBottomSheet<void>(
  context: context,
  isScrollControlled: true,
  useSafeArea: true,
  backgroundColor: palette.paper,
  builder: (_) => Theme(
    data: palette.theme(),
    child: ReaderSettingsSheet(wide: wide),
  ),
);

/// Texto y ayudas del lector. Cada cambio se aplica al momento y se guarda en el dispositivo.
class ReaderSettingsSheet extends ConsumerWidget {
  const ReaderSettingsSheet({super.key, required this.wide});

  final bool wide;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final text = Theme.of(context).textTheme;
    final p = ref.watch(readerPreferencesProvider);
    void set(ReaderPreferences next) => ref.read(readerPreferencesProvider.notifier).update(next);
    Widget label(String s) => Padding(
      padding: const EdgeInsets.only(top: 18, bottom: 8),
      child: Text(s, style: text.titleSmall),
    );
    String leading(ReaderLeading l) => switch (l) {
      ReaderLeading.compact => l10n.leadingcompact,
      ReaderLeading.comfortable => l10n.leadingcomfortable,
      ReaderLeading.airy => l10n.leadingairy,
    };
    String theme(ReaderTheme t) => switch (t) {
      ReaderTheme.light => l10n.themelight,
      ReaderTheme.sepia => l10n.themesepia,
      ReaderTheme.dark => l10n.themedark,
    };
    String width(ReaderWidth w) => switch (w) {
      ReaderWidth.narrow => l10n.widthnarrow,
      ReaderWidth.medium => l10n.widthmedium,
      ReaderWidth.wide => l10n.widthwide,
    };

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.7,
      maxChildSize: 0.95,
      builder: (context, scroll) => ListView(
        controller: scroll,
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        children: [
          Semantics(header: true, child: Text(l10n.readerSettings, style: text.headlineSmall)),
          label(l10n.settingsSize),
          Row(
            children: [
              IconButton.outlined(tooltip: l10n.settingsSmaller, onPressed: p.canShrink ? () => set(p.step(-1)) : null, icon: const Icon(Icons.text_decrease)),
              Expanded(
                child: Text(
                  'Aa',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontFamily: LesenTokens.of(context).readingFont, fontSize: p.fontSize),
                  semanticsLabel: '${l10n.settingsSize}: ${p.fontSize.round()}',
                ),
              ),
              IconButton.outlined(tooltip: l10n.settingsLarger, onPressed: p.canGrow ? () => set(p.step(1)) : null, icon: const Icon(Icons.text_increase)),
            ],
          ),
          label(l10n.settingsLeading),
          SegmentedButton<ReaderLeading>(
            segments: [for (final l in ReaderLeading.values) ButtonSegment(value: l, label: Text(leading(l)))],
            selected: {p.leading},
            onSelectionChanged: (s) => set(p.copyWith(leading: s.first)),
          ),
          label(l10n.settingsTheme),
          SegmentedButton<ReaderTheme>(
            segments: [for (final t in ReaderTheme.values) ButtonSegment(value: t, label: Text(theme(t)))],
            selected: {p.theme},
            onSelectionChanged: (s) => set(p.copyWith(theme: s.first)),
          ),
          if (wide) ...[
            label(l10n.settingsWidth),
            SegmentedButton<ReaderWidth>(
              segments: [for (final w in ReaderWidth.values) ButtonSegment(value: w, label: Text(width(w)))],
              selected: {p.width},
              onSelectionChanged: (s) => set(p.copyWith(width: s.first)),
            ),
          ],
          label(l10n.settingsAssistance),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(l10n.settingsHighlightSaved),
            value: p.highlightSaved,
            onChanged: (v) => set(p.copyWith(highlightSaved: v)),
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(l10n.settingsHighlightNew),
            subtitle: Text(l10n.settingsHighlightNewHint),
            value: p.highlightNew,
            onChanged: (v) => set(p.copyWith(highlightNew: v)),
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(l10n.settingsHighlightLearned),
            value: p.highlightLearned,
            onChanged: (v) => set(p.copyWith(highlightLearned: v)),
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(l10n.settingsParagraphTranslations),
            subtitle: Text(l10n.settingsParagraphTranslationsHint),
            value: p.paragraphTranslations,
            onChanged: (v) => set(p.copyWith(paragraphTranslations: v)),
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(l10n.settingsResume),
            value: p.resumePosition,
            onChanged: (v) => set(p.copyWith(resumePosition: v)),
          ),
        ],
      ),
    );
  }
}
