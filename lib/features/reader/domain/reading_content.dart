enum TokenKind { WORD, PUNCT }

class Token {
  const Token({required this.id, required this.text, required this.kind, required this.space, required this.entry});

  final String id;
  final String text;
  final TokenKind kind;

  /// Si va seguido de un espacio en el texto escrito.
  final bool space;

  /// Clave de la entrada del diccionario (`de:verbringen`), o `null` si no hay.
  final String? entry;

  bool get isWord => kind == TokenKind.WORD;
}

class Sentence {
  const Sentence({required this.id, required this.tokens});

  final String id;
  final List<Token> tokens;

  /// El texto tal como se escribió (palabras, signos y espacios).
  String get text => tokens.map((t) => t.space ? '${t.text} ' : t.text).join().trim();
}

class Paragraph {
  const Paragraph({required this.id, required this.sentences});

  final String id;
  final List<Sentence> sentences;
}

/// Una ilustración entre párrafos (ADR-0018 del backend). Sus medidas reservan el hueco antes de que llegue el archivo,
/// y `alt` es obligatorio: sin texto alternativo, el contenido no cumple el contrato.
class Illustration {
  const Illustration({required this.id, required this.url, required this.width, required this.height, required this.alt, this.caption});

  final String id;

  /// Ruta pública (`/api/lesen/public/illustrations/…`), relativa como las portadas.
  final String url;
  final int width;
  final int height;

  /// Texto alternativo y pie, los dos en el idioma de la lectura.
  final String alt;
  final String? caption;

  double get aspectRatio => width / height;
}

/// Un elemento del orden de lectura: un párrafo (por su posición en `paragraphs`) o una ilustración.
sealed class ContentBlock {
  const ContentBlock();
}

final class ParagraphBlock extends ContentBlock {
  const ParagraphBlock(this.index);

  final int index;
}

final class IllustrationBlock extends ContentBlock {
  const IllustrationBlock(this.illustration);

  final Illustration illustration;
}

/// El contenido de una versión publicada e inmutable (ADR-0003 y ADR-0004 del backend): los ids son estables.
class ReadingContent {
  ReadingContent({
    required this.slug,
    required this.version,
    required this.language,
    required this.current,
    required this.paragraphs,
    List<ContentBlock>? blocks,
  }) : blocks = blocks ?? [for (var i = 0; i < paragraphs.length; i++) ParagraphBlock(i)],
       index = ReaderIndex._(paragraphs);

  final String slug;
  final int version;
  final String language;

  /// Si es la versión vigente; una lectura empezada en una versión anterior se sigue leyendo en esa.
  final bool current;
  final List<Paragraph> paragraphs;

  /// El orden de lectura: los párrafos y, entre ellos, las ilustraciones. Sin ilustraciones, solo los párrafos.
  final List<ContentBlock> blocks;
  final ReaderIndex index;

  List<Illustration> get illustrations => [
    for (final b in blocks)
      if (b is IllustrationBlock) b.illustration,
  ];
}

/// Índices planos del texto, como `readerModel.ts` de la web: orden de oraciones y palabras y a quién pertenece cada una.
class ReaderIndex {
  ReaderIndex._(List<Paragraph> paragraphs) {
    for (var p = 0; p < paragraphs.length; p++) {
      final paragraph = paragraphs[p];
      for (final sentence in paragraph.sentences) {
        sentenceAt[sentence.id] = sentences.length;
        sentences.add(sentence);
        paragraphOfSentence[sentence.id] = p;
        for (final token in sentence.tokens) {
          tokenById[token.id] = token;
          sentenceOfToken[token.id] = sentence.id;
          if (token.isWord) words.add(token);
        }
      }
    }
  }

  final sentences = <Sentence>[];
  final words = <Token>[];
  final sentenceAt = <String, int>{};
  final paragraphOfSentence = <String, int>{};
  final sentenceOfToken = <String, String>{};
  final tokenById = <String, Token>{};

  Sentence? sentence(String id) {
    final at = sentenceAt[id];
    return at == null ? null : sentences[at];
  }

  /// El avance de quien está en una oración: las oraciones hasta esa incluida sobre el total (la última es el 100 %).
  int percentAt(String? sentenceId) {
    if (sentenceId == null || sentences.isEmpty) return 0;
    final at = sentenceAt[sentenceId];
    if (at == null) return 0;
    return ((at + 1) / sentences.length * 100).round();
  }

  /// De varias oraciones visibles, la primera en el orden del texto.
  String? topmost(Iterable<String> visible) {
    String? best;
    var bestAt = 1 << 30;
    for (final id in visible) {
      final at = sentenceAt[id];
      if (at != null && at < bestAt) {
        best = id;
        bestAt = at;
      }
    }
    return best;
  }
}

int remainingMinutes(int minutes, int percent) => (minutes * (100 - percent.clamp(0, 100)) / 100).ceil().clamp(0, minutes);
