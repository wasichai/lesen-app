enum ReaderTheme { light, sepia, dark }

enum ReaderLeading {
  compact(1.55),
  comfortable(1.75),
  airy(1.95);

  const ReaderLeading(this.height);

  final double height;
}

enum ReaderWidth {
  narrow(520),
  medium(640),
  wide(820);

  const ReaderWidth(this.maxWidth);

  final double maxWidth;
}

/// Preferencias del lector, en el dispositivo. Por defecto, la ayuda mínima: traducir es a demanda.
class ReaderPreferences {
  const ReaderPreferences({
    this.fontSize = 21,
    this.leading = ReaderLeading.comfortable,
    this.theme = ReaderTheme.light,
    this.width = ReaderWidth.medium,
    this.highlightSaved = true,
    this.highlightNew = false,
    this.highlightLearned = false,
    this.paragraphTranslations = false,
    this.resumePosition = true,
  });

  factory ReaderPreferences.fromJson(Map<String, dynamic> j) {
    T pick<T extends Enum>(List<T> values, Object? name, T fallback) => values.where((v) => v.name == name).firstOrNull ?? fallback;
    final size = (j['fontSize'] as num?)?.toDouble();
    return ReaderPreferences(
      fontSize: sizes.contains(size) ? size! : 21,
      leading: pick(ReaderLeading.values, j['leading'], ReaderLeading.comfortable),
      theme: pick(ReaderTheme.values, j['theme'], ReaderTheme.light),
      width: pick(ReaderWidth.values, j['width'], ReaderWidth.medium),
      highlightSaved: j['highlightSaved'] as bool? ?? true,
      highlightNew: j['highlightNew'] as bool? ?? false,
      highlightLearned: j['highlightLearned'] as bool? ?? false,
      paragraphTranslations: j['paragraphTranslations'] as bool? ?? false,
      resumePosition: j['resumePosition'] as bool? ?? true,
    );
  }

  /// Los tamaños de la web (`tokens.json`, `size.reading`).
  static const sizes = <double>[18, 20, 21, 23, 26, 29];

  final double fontSize;
  final ReaderLeading leading;
  final ReaderTheme theme;
  final ReaderWidth width;
  final bool highlightSaved;
  final bool highlightNew;
  final bool highlightLearned;
  final bool paragraphTranslations;
  final bool resumePosition;

  bool get canGrow => fontSize < sizes.last;
  bool get canShrink => fontSize > sizes.first;

  ReaderPreferences step(int delta) {
    final i = (sizes.indexOf(fontSize) + delta).clamp(0, sizes.length - 1);
    return copyWith(fontSize: sizes[i]);
  }

  ReaderPreferences copyWith({
    double? fontSize,
    ReaderLeading? leading,
    ReaderTheme? theme,
    ReaderWidth? width,
    bool? highlightSaved,
    bool? highlightNew,
    bool? highlightLearned,
    bool? paragraphTranslations,
    bool? resumePosition,
  }) => ReaderPreferences(
    fontSize: fontSize ?? this.fontSize,
    leading: leading ?? this.leading,
    theme: theme ?? this.theme,
    width: width ?? this.width,
    highlightSaved: highlightSaved ?? this.highlightSaved,
    highlightNew: highlightNew ?? this.highlightNew,
    highlightLearned: highlightLearned ?? this.highlightLearned,
    paragraphTranslations: paragraphTranslations ?? this.paragraphTranslations,
    resumePosition: resumePosition ?? this.resumePosition,
  );

  Map<String, dynamic> toJson() => {
    'fontSize': fontSize,
    'leading': leading.name,
    'theme': theme.name,
    'width': width.name,
    'highlightSaved': highlightSaved,
    'highlightNew': highlightNew,
    'highlightLearned': highlightLearned,
    'paragraphTranslations': paragraphTranslations,
    'resumePosition': resumePosition,
  };
}
