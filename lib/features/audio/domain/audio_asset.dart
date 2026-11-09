import 'timing_index.dart';

class Voice {
  const Voice({required this.id, required this.name, required this.language, required this.license});

  final String id;
  final String name;
  final String language;
  final String license;
}

/// Una narración de una versión, con sus tiempos por palabra anclados a los ids de token (ADR-0008 del backend).
class AudioAsset {
  AudioAsset({
    required this.id,
    required this.voice,
    required this.url,
    required this.format,
    required this.duration,
    required this.origin,
    required List<TimedSpan> words,
    required List<TimedSpan> sentences,
    required List<TimedSpan> paragraphs,
  }) : words = TimingIndex(words),
       sentences = TimingIndex(sentences),
       paragraphs = TimingIndex(paragraphs);

  final String id;
  final Voice voice;

  /// Relativa al origen del backend; servida con rangos (206).
  final String url;
  final String format;
  final Duration duration;
  final String origin;
  final TimingIndex words;
  final TimingIndex sentences;
  final TimingIndex paragraphs;
}
