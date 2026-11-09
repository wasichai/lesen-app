import '../../catalog/domain/reading.dart';

enum LearningGoal { TRAVEL, WORK, STUDY, CULTURE, FAMILY, FUN, EXAM }

enum ReadingDifficulty { COMFORTABLE, BALANCED, CHALLENGING }

/// Perfil de aprendizaje: tres idiomas independientes (interfaz, estudio y, por defecto, traducción = interfaz).
class LearnerProfile {
  const LearnerProfile({
    required this.interfaceLanguage,
    required this.targetLanguage,
    required this.level,
    required this.levelEstimated,
    required this.goals,
    required this.topics,
    required this.dailyMinutes,
    required this.difficulty,
  });

  final String interfaceLanguage;
  final String targetLanguage;
  final CefrLevel level;
  final bool levelEstimated;
  final Set<LearningGoal> goals;
  final List<String> topics;
  final int dailyMinutes;
  final ReadingDifficulty difficulty;

  static const minDaily = 5;
  static const maxDaily = 120;
  static const maxTopics = 24;

  LearnerProfile copyWith({
    String? interfaceLanguage,
    String? targetLanguage,
    CefrLevel? level,
    bool? levelEstimated,
    Set<LearningGoal>? goals,
    List<String>? topics,
    int? dailyMinutes,
    ReadingDifficulty? difficulty,
  }) => LearnerProfile(
    interfaceLanguage: interfaceLanguage ?? this.interfaceLanguage,
    targetLanguage: targetLanguage ?? this.targetLanguage,
    level: level ?? this.level,
    levelEstimated: levelEstimated ?? this.levelEstimated,
    goals: goals ?? this.goals,
    topics: topics ?? this.topics,
    dailyMinutes: dailyMinutes ?? this.dailyMinutes,
    difficulty: difficulty ?? this.difficulty,
  );
}
