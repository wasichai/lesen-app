import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart' show ScrollCacheExtent;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/l10n.dart';
import '../../../app/routing/routes.dart';
import '../../../core/networking/api_failure.dart';
import '../../../core/widgets/feedback_views.dart';
import '../../catalog/application/catalog_providers.dart';
import '../../catalog/domain/reading.dart';
import '../../library/data/library_repository.dart';
import '../../profile/application/profile_providers.dart';
import '../application/reader_providers.dart';
import '../application/reading_tracker.dart';
import '../data/reader_repository.dart';
import '../domain/reading_content.dart';
import 'end_of_reading.dart';
import 'notes_sheet.dart';
import 'reader_settings_sheet.dart';
import 'reader_theme.dart';
import 'widgets/paragraph_view.dart';
import 'widgets/word_panel.dart';

/// Ancho a partir del cual el diccionario va en un panel lateral y no en una hoja inferior.
const sidePanelBreakpoint = 900.0;

class ReaderScreen extends ConsumerWidget {
  const ReaderScreen({super.key, required this.slug});

  final String slug;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(readerSessionProvider(slug));
    final palette = ReaderPalette.of(ref.watch(readerPreferencesProvider.select((p) => p.theme)));
    return Theme(
      data: palette.theme(),
      child: switch (session) {
        AsyncData(:final value) => ReaderView(session: value, palette: palette),
        AsyncError(:final error) => Scaffold(
          appBar: AppBar(leading: BackButton(onPressed: () => _leave(context, slug))),
          body: FailureView(error: error, onRetry: () => ref.invalidate(readerSessionProvider(slug))),
        ),
        _ => const Scaffold(body: LoadingView()),
      },
    );
  }
}

void _leave(BuildContext context, String slug) {
  if (context.canPop()) {
    context.pop();
  } else {
    context.go(Routes.reading(slug));
  }
}

class ReaderView extends ConsumerStatefulWidget {
  const ReaderView({super.key, required this.session, required this.palette});

  final ReaderSession session;
  final ReaderPalette palette;

  @override
  ConsumerState<ReaderView> createState() => _ReaderViewState();
}

class _ReaderViewState extends ConsumerState<ReaderView> {
  final _scroll = ScrollController();
  late final ReadingTracker _tracker;
  late final AppLifecycleListener _lifecycle;
  late final List<GlobalKey<ParagraphViewState>> _keys;
  final _revealed = <String>{};
  ({Token token, Sentence sentence})? _selected;
  bool _focus = false;
  bool _finishing = false;
  late bool _bookmarked = widget.session.reading.bookmarked;
  Timer? _scrollThrottle;
  late final ProviderContainer _container;
  int _percent = 0;

  ReadingContent get _content => widget.session.content;

  @override
  void initState() {
    super.initState();
    _keys = List.generate(_content.paragraphs.length, (_) => GlobalKey<ParagraphViewState>());
    _tracker = ReadingTracker(repository: ref.read(readerRepositoryProvider), content: _content, initial: widget.session.progress)..resume();
    _percent = _tracker.percent;
    _lifecycle = AppLifecycleListener(onHide: _tracker.pause, onShow: _tracker.resume);
    _scroll.addListener(_onScroll);
    _container = ProviderScope.containerOf(context, listen: false);
    WidgetsBinding.instance.addPostFrameCallback((_) => _restore());
  }

  @override
  void dispose() {
    _scrollThrottle?.cancel();
    _lifecycle.dispose();
    _tracker.dispose();
    _scroll.dispose();
    // al salir, la ficha y la biblioteca deben ver el progreso nuevo
    _container
      ..invalidate(readingDetailProvider(_content.slug))
      ..invalidate(libraryProvider);
    super.dispose();
  }

  void _restore() {
    final position = widget.session.progress?.position;
    if (position == null || widget.session.progress!.completed || !ref.read(readerPreferencesProvider).resumePosition) return;
    unawaited(_scrollToSentence(position, animate: false));
  }

  void _onScroll() {
    if (_scrollThrottle?.isActive ?? false) return;
    // se mide después del siguiente fotograma, con el desplazamiento ya aplicado al diseño
    _scrollThrottle = Timer(const Duration(milliseconds: 250), () {
      WidgetsBinding.instance
        ..addPostFrameCallback((_) => _trackPosition())
        ..scheduleFrame();
    });
  }

  /// La oración que está arriba del todo en pantalla es la posición de lectura.
  void _trackPosition() {
    if (!mounted) return;
    final viewport = context.findRenderObject() as RenderBox?;
    if (viewport == null) return;
    final top = viewport.localToGlobal(Offset.zero).dy + 96;
    for (var i = 0; i < _keys.length; i++) {
      final ctx = _keys[i].currentContext;
      final box = ctx?.findRenderObject() as RenderBox?;
      if (box == null || !box.attached) continue;
      final y = box.localToGlobal(Offset.zero).dy;
      if (y + box.size.height < top) continue;
      final sentence = _keys[i].currentState?.sentenceAtDy((top - y).clamp(0, box.size.height));
      if (sentence != null) {
        _tracker.moveTo(sentence);
        if (_tracker.percent != _percent) setState(() => _percent = _tracker.percent);
      }
      return;
    }
  }

  /// Lleva una oración a la parte de arriba. Con párrafos aún sin construir, se acerca por estimación y luego afina.
  Future<void> _scrollToSentence(String sentenceId, {bool animate = true}) async {
    final p = _content.index.paragraphOfSentence[sentenceId];
    if (p == null) return;
    for (var attempt = 0; attempt < 6; attempt++) {
      if (!mounted) return;
      final box = _keys[p].currentContext?.findRenderObject() as RenderBox?;
      if (box != null) {
        final viewport = context.findRenderObject()! as RenderBox;
        final inner = _keys[p].currentState?.offsetOfSentence(sentenceId) ?? 0;
        final delta = box.localToGlobal(Offset.zero).dy - viewport.localToGlobal(Offset.zero).dy - 96 + inner;
        final target = (_scroll.offset + delta).clamp(0.0, _scroll.position.maxScrollExtent);
        if (animate && !MediaQuery.disableAnimationsOf(context)) {
          await _scroll.animateTo(target, duration: const Duration(milliseconds: 350), curve: Curves.easeOutCubic);
        } else {
          _scroll.jumpTo(target);
        }
        return;
      }
      final estimate = _scroll.position.maxScrollExtent * p / _keys.length;
      _scroll.jumpTo(estimate.clamp(0.0, _scroll.position.maxScrollExtent));
      await WidgetsBinding.instance.endOfFrame;
    }
  }

  Future<void> _onWordTap(Token token, Sentence sentence) async {
    setState(() => _selected = (token: token, sentence: sentence));
    if (MediaQuery.sizeOf(context).width >= sidePanelBreakpoint) return;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: widget.palette.paper,
      builder: (_) => Theme(
        data: widget.palette.theme(),
        child: DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.5,
          minChildSize: 0.3,
          maxChildSize: 0.92,
          builder: (context, scroll) => SingleChildScrollView(
            controller: scroll,
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
            child: WordPanel(slug: _content.slug, version: _content.version, language: _content.language, token: token, sentence: sentence),
          ),
        ),
      ),
    );
    if (mounted) setState(() => _selected = null);
  }

  Future<void> _toggleBookmark() async {
    final next = !_bookmarked;
    setState(() => _bookmarked = next);
    try {
      await ref.read(readerRepositoryProvider).setBookmark(_content.slug, next);
    } on ApiFailure {
      if (!mounted) return;
      setState(() => _bookmarked = !next);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(context.l10n.detailBookmarkFailed)));
    }
  }

  Future<void> _finish() async {
    setState(() => _finishing = true);
    try {
      await _tracker.complete();
      if (!mounted) return;
      final saved = ref.read(knownWordsProvider(_content.language)).saved.keys.where((k) => _content.index.words.any((w) => w.entry == k)).length;
      setState(() => _percent = 100);
      await showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        useSafeArea: true,
        builder: (_) => EndOfReading(reading: widget.session.reading, minutes: (_tracker.secondsRead / 60).ceil(), savedWords: saved),
      );
    } on ApiFailure {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(context.l10n.endFailed)));
    } finally {
      if (mounted) setState(() => _finishing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final prefs = ref.watch(readerPreferencesProvider);
    final palette = widget.palette;
    final known = ref.watch(knownWordsProvider(_content.language));
    final reading = widget.session.reading;
    final wide = MediaQuery.sizeOf(context).width >= sidePanelBreakpoint;
    final paragraphTranslations = ref.watch(translationsProvider((slug: _content.slug, version: _content.version, unit: TranslationUnit.PARAGRAPH)));
    final remaining = remainingMinutes(reading.minutes, _percent);

    final list = ListView.builder(
      controller: _scroll,
      padding: EdgeInsets.fromLTRB(24, 8, 24, 48 + MediaQuery.paddingOf(context).bottom),
      scrollCacheExtent: const ScrollCacheExtent.pixels(1600),
      itemCount: _content.paragraphs.length + 2,
      itemBuilder: (context, i) {
        Widget centered(Widget child) => Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: prefs.width.maxWidth),
            child: child,
          ),
        );
        if (i == 0) return centered(_Intro(reading: reading, content: _content, palette: palette));
        if (i == _content.paragraphs.length + 1) {
          return centered(
            Padding(
              padding: const EdgeInsets.only(top: 32),
              child: _tracker.completed && _percent >= 100
                  ? OutlinedButton.icon(onPressed: () => _leave(context, _content.slug), icon: const Icon(Icons.check), label: Text(l10n.cardCompleted))
                  : FilledButton.icon(
                      onPressed: _finishing ? null : _finish,
                      icon: const Icon(Icons.flag_outlined),
                      label: Text(_finishing ? l10n.readerFinishing : l10n.readerFinish),
                    ),
            ),
          );
        }
        final paragraph = _content.paragraphs[i - 1];
        final shown = prefs.paragraphTranslations || _revealed.contains(paragraph.id);
        final translation = shown ? (paragraphTranslations.value ?? const <String, String>{})[paragraph.id] : null;
        final missing = shown && paragraphTranslations.hasValue && translation == null;
        return centered(
          Padding(
            padding: const EdgeInsets.only(bottom: 22),
            child: ParagraphView(
              key: _keys[i - 1],
              paragraph: paragraph,
              language: _content.language,
              preferences: prefs,
              palette: palette,
              known: known,
              selectedToken: _selected?.token.id,
              onWordTap: _onWordTap,
              translation: missing ? l10n.readerNoParagraphTranslation : translation,
              trailing: prefs.paragraphTranslations
                  ? null
                  : Align(
                      alignment: AlignmentDirectional.centerEnd,
                      child: TextButton.icon(
                        style: TextButton.styleFrom(foregroundColor: palette.inkMuted, visualDensity: VisualDensity.compact),
                        onPressed: () => setState(() => _revealed.contains(paragraph.id) ? _revealed.remove(paragraph.id) : _revealed.add(paragraph.id)),
                        icon: const Icon(Icons.translate, size: 16),
                        label: Text(_revealed.contains(paragraph.id) ? l10n.readerHideParagraph : l10n.readerTranslateParagraph),
                      ),
                    ),
            ),
          ),
        );
      },
    );

    final body = wide
        ? Row(
            children: [
              Expanded(child: list),
              AnimatedSwitcher(
                duration: MediaQuery.disableAnimationsOf(context) ? Duration.zero : const Duration(milliseconds: 220),
                child: _selected == null
                    ? const SizedBox.shrink()
                    : Container(
                        key: ValueKey(_selected!.token.id),
                        width: 400,
                        decoration: BoxDecoration(
                          border: Border(left: BorderSide(color: palette.inkMuted.withValues(alpha: 0.2))),
                        ),
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                          child: WordPanel(
                            slug: _content.slug,
                            version: _content.version,
                            language: _content.language,
                            token: _selected!.token,
                            sentence: _selected!.sentence,
                            onClose: () => setState(() => _selected = null),
                          ),
                        ),
                      ),
              ),
            ],
          )
        : list;

    return Scaffold(
      backgroundColor: palette.paper,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            if (!_focus)
              _TopBar(
                title: reading.title,
                remaining: _percent >= 95 ? l10n.readerAlmostDone : l10n.readerRemaining(remaining),
                percent: _percent,
                bookmarked: _bookmarked,
                palette: palette,
                onBack: () => _leave(context, _content.slug),
                onBookmark: _toggleBookmark,
                onNotes: () => showNotesSheet(context, slug: _content.slug, palette: palette, onGo: _scrollToSentence),
                onSettings: () => showReaderSettings(context, palette: palette, wide: MediaQuery.sizeOf(context).width >= 600),
                onFocus: () => setState(() => _focus = true),
              ),
            Expanded(child: body),
          ],
        ),
      ),
      floatingActionButton: _focus
          ? FloatingActionButton.small(
              tooltip: l10n.readerFocusExit,
              backgroundColor: palette.paper,
              foregroundColor: palette.inkMuted,
              elevation: 1,
              onPressed: () => setState(() => _focus = false),
              child: const Icon(Icons.fullscreen_exit),
            )
          : null,
    );
  }
}

class _Intro extends ConsumerWidget {
  const _Intro({required this.reading, required this.content, required this.palette});

  final ReadingCard reading;
  final ReadingContent content;
  final ReaderPalette palette;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final text = Theme.of(context).textTheme;
    final language = ref.watch(languagesProvider).value?.nameOf(content.language) ?? content.language.toUpperCase();
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('${language.toUpperCase()} · ${reading.level.name}', style: text.labelMedium?.copyWith(color: palette.brand, letterSpacing: 1.2)),
          const SizedBox(height: 8),
          Semantics(
            header: true,
            child: Text(
              reading.title,
              style: text.displaySmall?.copyWith(color: palette.ink),
              locale: Locale(content.language),
            ),
          ),
          if (reading.subtitle != null) ...[
            const SizedBox(height: 6),
            Text(
              reading.subtitle!,
              style: text.titleLarge?.copyWith(color: palette.inkMuted, fontStyle: FontStyle.italic, fontWeight: FontWeight.w400),
              locale: Locale(content.language),
            ),
          ],
          if (!content.current) ...[
            const SizedBox(height: 14),
            Text(l10n.readerOldVersion(content.version), style: text.bodySmall?.copyWith(color: palette.inkMuted)),
          ],
          const SizedBox(height: 14),
          Row(
            children: [
              Icon(Icons.touch_app_outlined, size: 18, color: palette.inkMuted),
              const SizedBox(width: 6),
              Expanded(
                child: Text(l10n.readerHint, style: text.bodySmall?.copyWith(color: palette.inkMuted)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({
    required this.title,
    required this.remaining,
    required this.percent,
    required this.bookmarked,
    required this.palette,
    required this.onBack,
    required this.onBookmark,
    required this.onNotes,
    required this.onSettings,
    required this.onFocus,
  });

  final String title;
  final String remaining;
  final int percent;
  final bool bookmarked;
  final ReaderPalette palette;
  final VoidCallback onBack;
  final VoidCallback onBookmark;
  final VoidCallback onNotes;
  final VoidCallback onSettings;
  final VoidCallback onFocus;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final text = Theme.of(context).textTheme;
    final narrow = MediaQuery.sizeOf(context).width < 400;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(4, 4, 4, 0),
          child: Row(
            children: [
              IconButton(tooltip: l10n.readerBack, onPressed: onBack, icon: const Icon(Icons.arrow_back)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: text.titleSmall?.copyWith(color: palette.ink),
                    ),
                    Text(remaining, style: text.labelSmall?.copyWith(color: palette.inkMuted)),
                  ],
                ),
              ),
              Semantics(
                toggled: bookmarked,
                child: IconButton(
                  tooltip: bookmarked ? l10n.detailBookmarked : l10n.detailBookmark,
                  onPressed: onBookmark,
                  icon: Icon(bookmarked ? Icons.bookmark : Icons.bookmark_outline, color: bookmarked ? palette.brand : null),
                ),
              ),
              IconButton(tooltip: l10n.readerNotes, onPressed: onNotes, icon: const Icon(Icons.sticky_note_2_outlined)),
              IconButton(tooltip: l10n.readerSettings, onPressed: onSettings, icon: const Icon(Icons.text_fields)),
              if (!narrow) IconButton(tooltip: l10n.readerFocus, onPressed: onFocus, icon: const Icon(Icons.fullscreen)),
            ],
          ),
        ),
        Semantics(
          label: l10n.readerProgress(percent),
          child: LinearProgressIndicator(value: percent / 100, minHeight: 3, backgroundColor: palette.inkMuted.withValues(alpha: 0.12), color: palette.brand),
        ),
      ],
    );
  }
}
