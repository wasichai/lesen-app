import 'package:flutter/material.dart';

import '../../../app/l10n.dart';
import '../../../app/theme/tokens.dart';
import '../domain/assessment.dart';

typedef DraftChanged = void Function(AnswerDraft);

/// La forma de responder de cada tipo de pregunta.
class QuestionInput extends StatelessWidget {
  const QuestionInput({super.key, required this.question, required this.draft, required this.onChanged, required this.studyLanguage});

  final Question question;
  final AnswerDraft draft;
  final DraftChanged onChanged;
  final String studyLanguage;

  @override
  Widget build(BuildContext context) => switch (question.type) {
    QuestionType.TRUE_FALSE => _TrueFalse(draft: draft, onChanged: onChanged),
    QuestionType.COMPLETION => _Completion(question: question, draft: draft, onChanged: onChanged, language: studyLanguage),
    QuestionType.MATCHING => _Matching(question: question, draft: draft, onChanged: onChanged),
    QuestionType.ORDERING => _Ordering(question: question, draft: draft, onChanged: onChanged),
    QuestionType.SHORT_ANSWER => _ShortAnswer(draft: draft, onChanged: onChanged),
    _ => _Choices(question: question, draft: draft, onChanged: onChanged, language: studyLanguage),
  };
}

class _Choices extends StatelessWidget {
  const _Choices({required this.question, required this.draft, required this.onChanged, required this.language});

  final Question question;
  final AnswerDraft draft;
  final DraftChanged onChanged;
  final String language;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final t = LesenTokens.of(context);
    final text = Theme.of(context).textTheme;
    final selected = draft.options ?? const <String>[];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (question.type == QuestionType.VOCABULARY_IN_CONTEXT && question.word != null) ...[
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: t.surfaceMuted, borderRadius: BorderRadius.circular(t.radiusLg)),
            child: Text.rich(
              TextSpan(
                children: _highlight(
                  question.wordSentence ?? question.word!,
                  question.word!,
                  TextStyle(fontWeight: FontWeight.w700, backgroundColor: t.markSaved),
                ),
              ),
              style: text.bodyLarge?.copyWith(fontFamily: t.readingFont, fontSize: 19),
              locale: Locale(language),
            ),
          ),
          const SizedBox(height: 12),
        ],
        if (question.multiple)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(l10n.quizChooseMany, style: text.bodySmall),
          ),
        for (final o in question.options)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: _OptionTile(
              label: o.text,
              locale: o.lang == null ? null : Locale(o.lang!),
              selected: selected.contains(o.id),
              multiple: question.multiple,
              onTap: () {
                final next = question.multiple ? (selected.contains(o.id) ? (selected.toList()..remove(o.id)) : [...selected, o.id]) : [o.id];
                onChanged(AnswerDraft(options: next));
              },
            ),
          ),
      ],
    );
  }

  static List<InlineSpan> _highlight(String sentence, String word, TextStyle style) {
    final at = sentence.indexOf(word);
    if (at < 0) return [TextSpan(text: sentence)];
    return [TextSpan(text: sentence.substring(0, at)), TextSpan(text: word, style: style), TextSpan(text: sentence.substring(at + word.length))];
  }
}

class _OptionTile extends StatelessWidget {
  const _OptionTile({required this.label, required this.selected, required this.multiple, required this.onTap, this.locale});

  final String label;
  final bool selected;
  final bool multiple;
  final VoidCallback onTap;
  final Locale? locale;

  @override
  Widget build(BuildContext context) {
    final t = LesenTokens.of(context);
    return Semantics(
      selected: selected,
      inMutuallyExclusiveGroup: !multiple,
      child: Material(
        color: selected ? t.brandSoft : t.surfaceRaised,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(t.radiusLg),
          side: BorderSide(color: selected ? t.brand : t.inkMuted.withValues(alpha: 0.25), width: selected ? 2 : 1),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(t.radiusLg),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            child: Row(
              children: [
                Icon(
                  multiple ? (selected ? Icons.check_box : Icons.check_box_outline_blank) : (selected ? Icons.radio_button_checked : Icons.radio_button_off),
                  color: selected ? t.brand : t.inkMuted,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(label, style: Theme.of(context).textTheme.bodyLarge, locale: locale),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TrueFalse extends StatelessWidget {
  const _TrueFalse({required this.draft, required this.onChanged});

  final AnswerDraft draft;
  final DraftChanged onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      children: [
        for (final (value, label) in [(true, l10n.quizTrue), (false, l10n.quizFalse)])
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: _OptionTile(
              label: label,
              selected: draft.value == value,
              multiple: false,
              onTap: () => onChanged(AnswerDraft(value: value)),
            ),
          ),
      ],
    );
  }
}

/// Completar: los huecos se rellenan tocando palabras del banco, en orden; tocar un hueco lleno lo vacía.
class _Completion extends StatelessWidget {
  const _Completion({required this.question, required this.draft, required this.onChanged, required this.language});

  final Question question;
  final AnswerDraft draft;
  final DraftChanged onChanged;
  final String language;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final t = LesenTokens.of(context);
    final text = Theme.of(context).textTheme;
    final blanks = {...?draft.blanks};
    final order = [for (final p in question.parts) ?p.blank];
    final used = blanks.values.toList();
    void fill(String word) {
      final free = order.where((b) => !blanks.containsKey(b)).firstOrNull;
      if (free == null) return;
      onChanged(AnswerDraft(blanks: {...blanks, free: word}));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: t.surfaceMuted, borderRadius: BorderRadius.circular(t.radiusLg)),
          child: Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            runSpacing: 8,
            children: [
              for (final p in question.parts)
                if (p.blank == null)
                  Text(
                    p.text ?? '',
                    style: text.bodyLarge?.copyWith(fontFamily: t.readingFont, fontSize: 19),
                    locale: Locale(language),
                  )
                else
                  Semantics(
                    button: true,
                    label: blanks[p.blank] == null
                        ? l10n.quizBlankEmpty(order.indexOf(p.blank!) + 1)
                        : l10n.quizBlankFilled(order.indexOf(p.blank!) + 1, blanks[p.blank]!),
                    excludeSemantics: true,
                    child: InkWell(
                      onTap: blanks[p.blank] == null ? null : () => onChanged(AnswerDraft(blanks: {...blanks}..remove(p.blank))),
                      child: Container(
                        constraints: const BoxConstraints(minWidth: 72, minHeight: 40),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: blanks[p.blank] == null ? null : t.brandSoft,
                          border: Border(bottom: BorderSide(color: t.brand, width: 2)),
                        ),
                        child: Text(
                          blanks[p.blank] ?? ' ',
                          style: text.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
                          locale: Locale(language),
                        ),
                      ),
                    ),
                  ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Text(l10n.quizBank, style: text.titleSmall),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final w in question.bank)
              ActionChip(
                label: Text(w, locale: Locale(language)),
                onPressed: used.contains(w) ? null : () => fill(w),
              ),
          ],
        ),
      ],
    );
  }
}

/// Emparejar con un menú por fila (más accesible que arrastrar).
class _Matching extends StatelessWidget {
  const _Matching({required this.question, required this.draft, required this.onChanged});

  final Question question;
  final AnswerDraft draft;
  final DraftChanged onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final pairs = {...?draft.pairs};
    final text = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(l10n.quizMatchHint, style: text.bodySmall),
        const SizedBox(height: 8),
        for (final left in question.left)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              children: [
                Expanded(
                  child: Text(left.text, style: text.titleMedium, locale: left.lang == null ? null : Locale(left.lang!)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: pairs[left.id],
                    isExpanded: true,
                    hint: Text(l10n.quizMatchChoose),
                    items: [
                      for (final r in question.right)
                        DropdownMenuItem(
                          value: r.id,
                          child: Text(r.text, overflow: TextOverflow.ellipsis),
                        ),
                    ],
                    onChanged: (v) => onChanged(AnswerDraft(pairs: {...pairs, left.id: ?v})),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

/// Ordenar: arrastrar o, para teclado y lectores de pantalla, subir y bajar.
class _Ordering extends StatelessWidget {
  const _Ordering({required this.question, required this.draft, required this.onChanged});

  final Question question;
  final AnswerDraft draft;
  final DraftChanged onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final byId = {for (final i in question.items) i.id: i};
    final order = draft.order ?? [for (final i in question.items) i.id];
    void move(int from, int to) {
      final next = [...order];
      final id = next.removeAt(from);
      next.insert(to.clamp(0, next.length), id);
      onChanged(AnswerDraft(order: next));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(l10n.quizOrderHint, style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: 8),
        ReorderableListView(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          buildDefaultDragHandles: false,
          onReorderItem: move,
          children: [
            for (final (i, id) in order.indexed)
              Card(
                key: ValueKey(id),
                elevation: 0,
                color: LesenTokens.of(context).surfaceRaised,
                child: ListTile(
                  leading: ReorderableDragStartListener(
                    index: i,
                    child: CircleAvatar(radius: 14, child: Text('${i + 1}')),
                  ),
                  title: Text(byId[id]?.text ?? id),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(tooltip: l10n.quizMoveUp, onPressed: i == 0 ? null : () => move(i, i - 1), icon: const Icon(Icons.arrow_upward)),
                      IconButton(
                        tooltip: l10n.quizMoveDown,
                        onPressed: i == order.length - 1 ? null : () => move(i, i + 1),
                        icon: const Icon(Icons.arrow_downward),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _ShortAnswer extends StatefulWidget {
  const _ShortAnswer({required this.draft, required this.onChanged});

  final AnswerDraft draft;
  final DraftChanged onChanged;

  @override
  State<_ShortAnswer> createState() => _ShortAnswerState();
}

class _ShortAnswerState extends State<_ShortAnswer> {
  late final _controller = TextEditingController(text: widget.draft.text);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => TextField(
    controller: _controller,
    minLines: 3,
    maxLines: 6,
    maxLength: 1000,
    decoration: InputDecoration(hintText: context.l10n.quizShortHint),
    onChanged: (v) => widget.onChanged(AnswerDraft(text: v)),
  );
}
