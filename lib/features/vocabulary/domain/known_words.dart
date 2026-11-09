enum WordStatus { SAVED, LEARNING, FAMILIAR, MASTERED }

/// Lo que quien lee ya conoce, para resaltar en el texto (`vocabulary/known`): lo guardado con su estado y lo encontrado
/// al terminar lecturas.
class KnownWords {
  const KnownWords({required this.saved, required this.encountered});

  static const empty = KnownWords(saved: {}, encountered: {});

  final Map<String, WordStatus> saved;
  final Set<String> encountered;

  bool isSaved(String key) => saved.containsKey(key);

  /// Aprendida: ya familiar o dominada en el repaso.
  bool isLearned(String key) => switch (saved[key]) {
    WordStatus.FAMILIAR || WordStatus.MASTERED => true,
    _ => false,
  };

  /// Nueva para quien lee: ni guardada ni encontrada al terminar una lectura.
  bool isNew(String key) => !saved.containsKey(key) && !encountered.contains(key);

  KnownWords withSaved(String key) => KnownWords(saved: {...saved, key: saved[key] ?? WordStatus.SAVED}, encountered: encountered);
}
