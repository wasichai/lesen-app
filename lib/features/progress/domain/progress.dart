/// Lo medido (contado) frente a lo estimado (inferido): el panel nunca los mezcla (ADR-0011 del backend).
enum MetricKind { MEASURED, ESTIMATED }

class Metric {
  const Metric(this.value, this.kind);

  static const zero = Metric(0, MetricKind.MEASURED);

  final num value;
  final MetricKind kind;

  bool get estimated => kind == MetricKind.ESTIMATED;
  int get asInt => value.round();
}

class DayActivity {
  const DayActivity({required this.date, required this.minutes, required this.active, required this.goalMet});

  final DateTime date;
  final int minutes;
  final bool active;
  final bool goalMet;
}

/// La racha es semanal y amable: cuenta semanas cumplidas y nunca dice que se perdió nada.
class Streak {
  const Streak({
    required this.current,
    required this.best,
    required this.weeksMet,
    required this.target,
    required this.activeThisWeek,
    required this.metThisWeek,
  });

  final int current;
  final int best;
  final int weeksMet;

  /// Días de la semana que quien lee se propuso.
  final int target;
  final int activeThisWeek;
  final bool metThisWeek;
}

class Score {
  const Score({required this.key, required this.answered, required this.score});

  final String key;
  final int answered;

  /// 0–100: lo correcto cuenta entero y lo parcial, la mitad (lo calcula el backend).
  final int score;
}

enum LevelSignal { UP, STEADY, DOWN, unknown }

class Achievement {
  const Achievement({required this.code, required this.kind, required this.threshold, required this.value, required this.earnedAt});

  final String code;
  final String kind;
  final int threshold;
  final int value;
  final DateTime? earnedAt;

  bool get earned => earnedAt != null;
  double get fraction => threshold == 0 ? 1 : (value / threshold).clamp(0, 1).toDouble();
}

class Dashboard {
  const Dashboard({
    required this.language,
    required this.today,
    required this.dailyMinutes,
    required this.todayMinutes,
    required this.goalMet,
    required this.streak,
    required this.days,
    required this.reading,
    required this.vocabulary,
    required this.growth,
    required this.answered,
    required this.average,
    required this.byType,
    required this.byLevel,
    required this.level,
    required this.levelKind,
    required this.levelSignal,
    required this.answeredAtLevel,
    required this.recentAchievements,
  });

  final String language;
  final DateTime today;
  final int dailyMinutes;
  final Metric todayMinutes;
  final bool goalMet;
  final Streak streak;

  /// Los últimos 28 días.
  final List<DayActivity> days;
  final Map<String, Metric> reading;
  final Map<String, Metric> vocabulary;
  final List<(DateTime, int)> growth;
  final Metric answered;
  final Metric? average;
  final List<Score> byType;
  final List<Score> byLevel;
  final String level;
  final MetricKind levelKind;
  final LevelSignal levelSignal;
  final int answeredAtLevel;
  final List<Achievement> recentAchievements;
}

class WeeklySummary {
  const WeeklySummary({
    required this.weekStart,
    required this.weekEnd,
    required this.current,
    required this.days,
    required this.metrics,
    required this.activeDays,
    required this.target,
    required this.met,
    required this.achievements,
  });

  final DateTime weekStart;
  final DateTime weekEnd;
  final bool current;
  final List<DayActivity> days;
  final Map<String, Metric> metrics;
  final int activeDays;
  final int target;
  final bool met;
  final List<Achievement> achievements;
}

class Goals {
  const Goals({required this.dailyMinutes, required this.weeklyDays, required this.timeZone, required this.weeklySummary});

  final int dailyMinutes;
  final int weeklyDays;
  final String timeZone;
  final bool weeklySummary;
}
