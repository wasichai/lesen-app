import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import '../../../vocabulary/domain/known_words.dart';
import '../../domain/reader_preferences.dart';
import '../../domain/reading_content.dart';
import '../reader_theme.dart';

/// Un párrafo como un único `RichText`: cada palabra es un tramo que se puede tocar. Solo se reconstruye este párrafo al
/// cambiar su selección, sus resaltados o su traducción; nunca el documento entero.
class ParagraphView extends StatefulWidget {
  const ParagraphView({
    super.key,
    required this.paragraph,
    required this.language,
    required this.preferences,
    required this.palette,
    required this.known,
    required this.selectedToken,
    required this.onWordTap,
    this.translation,
    this.trailing,
  });

  final Paragraph paragraph;
  final String language;
  final ReaderPreferences preferences;
  final ReaderPalette palette;
  final KnownWords known;

  /// La palabra abierta en el diccionario, si es de este párrafo.
  final String? selectedToken;
  final void Function(Token token, Sentence sentence) onWordTap;

  /// La traducción del párrafo, si se muestra.
  final String? translation;
  final Widget? trailing;

  @override
  State<ParagraphView> createState() => ParagraphViewState();
}

class ParagraphViewState extends State<ParagraphView> {
  final _textKey = GlobalKey();
  final _recognizers = <String, TapGestureRecognizer>{};

  /// Desplazamiento (en caracteres) donde empieza cada oración dentro del texto del párrafo.
  final _sentenceStart = <String, int>{};

  @override
  void dispose() {
    for (final r in _recognizers.values) {
      r.dispose();
    }
    super.dispose();
  }

  TapGestureRecognizer _recognizer(Token token, Sentence sentence) {
    final r = _recognizers.putIfAbsent(token.id, TapGestureRecognizer.new);
    r.onTap = () => widget.onWordTap(token, sentence);
    return r;
  }

  /// La oración que está a `dy` píxeles del borde superior del texto del párrafo.
  String? sentenceAtDy(double dy) {
    final render = _textKey.currentContext?.findRenderObject();
    if (render is! RenderParagraph || _sentenceStart.isEmpty) return widget.paragraph.sentences.firstOrNull?.id;
    String? best = widget.paragraph.sentences.first.id;
    for (final s in widget.paragraph.sentences) {
      final start = _sentenceStart[s.id];
      if (start == null) continue;
      final y = render.getOffsetForCaret(TextPosition(offset: start), Rect.zero).dy;
      if (y <= dy) best = s.id;
    }
    return best;
  }

  /// Vertical (en el texto del párrafo) donde empieza una oración.
  double? offsetOfSentence(String sentenceId) {
    final render = _textKey.currentContext?.findRenderObject();
    final start = _sentenceStart[sentenceId];
    if (render is! RenderParagraph || start == null) return null;
    return render.getOffsetForCaret(TextPosition(offset: start), Rect.zero).dy;
  }

  @override
  Widget build(BuildContext context) {
    final prefs = widget.preferences;
    final palette = widget.palette;
    final base = TextStyle(fontFamily: 'Newsreader', fontSize: prefs.fontSize, height: prefs.leading.height, color: palette.ink, letterSpacing: 0.05);
    final spans = <InlineSpan>[];
    var offset = 0;
    _sentenceStart.clear();
    final sentences = widget.paragraph.sentences;
    for (final (si, sentence) in sentences.indexed) {
      // entre oraciones va un espacio aunque el último signo no lo traiga (como en la web)
      if (si > 0 && !(sentences[si - 1].tokens.lastOrNull?.space ?? false)) {
        spans.add(const TextSpan(text: ' '));
        offset += 1;
      }
      _sentenceStart[sentence.id] = offset;
      final selectedHere = widget.selectedToken != null && sentence.tokens.any((t) => t.id == widget.selectedToken);
      for (final token in sentence.tokens) {
        final text = token.space ? '${token.text} ' : token.text;
        offset += text.length;
        if (!token.isWord) {
          spans.add(
            TextSpan(
              text: text,
              style: selectedHere ? TextStyle(backgroundColor: palette.sentence) : null,
            ),
          );
          continue;
        }
        final key = token.entry;
        final selected = token.id == widget.selectedToken;
        final saved = key != null && prefs.highlightSaved && widget.known.isSaved(key);
        final learned = key != null && prefs.highlightLearned && widget.known.isLearned(key);
        final fresh = key != null && prefs.highlightNew && widget.known.isNew(key);
        // la palabra (sin el espacio) lleva el estilo; el espacio queda fuera para que el resaltado no se alargue
        spans.add(
          TextSpan(
            text: token.text,
            recognizer: _recognizer(token, sentence),
            style: TextStyle(
              backgroundColor: selected ? palette.active : (saved ? palette.saved : (selectedHere ? palette.sentence : null)),
              // no solo color: la abierta va subrayada y en negrita; nueva, punteada; aprendida, subrayado fino
              fontWeight: selected ? FontWeight.w600 : null,
              decoration: selected || fresh || learned ? TextDecoration.underline : null,
              decorationStyle: selected ? TextDecorationStyle.solid : (fresh ? TextDecorationStyle.dotted : TextDecorationStyle.solid),
              decorationColor: selected || fresh ? palette.brand : palette.inkMuted,
              decorationThickness: selected ? 2.2 : 1.4,
            ),
          ),
        );
        if (token.space) {
          spans.add(
            TextSpan(
              text: ' ',
              style: selectedHere ? TextStyle(backgroundColor: palette.sentence) : null,
            ),
          );
        }
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          key: _textKey,
          locale: Locale(widget.language),
          textScaler: MediaQuery.textScalerOf(context),
          text: TextSpan(style: base, children: spans),
        ),
        if (widget.translation != null)
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Container(
              padding: const EdgeInsets.only(left: 12),
              decoration: BoxDecoration(
                border: Border(left: BorderSide(color: palette.brand.withValues(alpha: 0.5), width: 3)),
              ),
              child: Text(
                widget.translation!,
                style: TextStyle(fontFamily: 'SourceSans3', fontSize: prefs.fontSize * 0.78, height: 1.5, color: palette.inkMuted, fontStyle: FontStyle.italic),
              ),
            ),
          ),
        ?widget.trailing,
      ],
    );
  }
}
