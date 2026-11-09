import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/networking/api_client.dart';
import '../../../core/networking/json.dart';
import '../../../core/storage/cache.dart';
import '../../../core/storage/local_store.dart';
import '../domain/progress.dart';

final progressRepositoryProvider = Provider<ProgressRepository>((ref) => ProgressRepository(ref.watch(apiProvider), ref.watch(localStoreProvider)));

class ProgressRepository {
  ProgressRepository(this._api, this._local);

  final Api _api;
  final LocalStore _local;
  static const _base = '/lesen/progress';

  /// El panel; sin red, la última copia. `null` sin perfil (404).
  Future<Dashboard?> dashboard() async {
    final j = await _local.networkFirst('dashboard', () async => await _api.getJsonOrNull('$_base/dashboard') ?? const {'none': true});
    return j['none'] == true ? null : parseDashboard(j);
  }

  Future<WeeklySummary> weekly({DateTime? week}) async {
    final j = await _api.getJson('$_base/weekly', query: {if (week != null) 'week': _date(week)});
    return parseWeekly(j);
  }

  Future<List<Achievement>> achievements() async =>
      (await _api.getList('$_base/achievements')).map((a) => achievement((a as Map).cast<String, dynamic>())).toList();

  Future<Goals> goals() async => parseGoals(await _api.getJson('$_base/goals'));

  Future<Goals> saveGoals({int? dailyMinutes, int? weeklyDays, bool? weeklySummary, String? timeZone}) async => parseGoals(
    (await _api.send(
      'PUT',
      '$_base/goals',
      body: {'dailyMinutes': ?dailyMinutes, 'weeklyDays': ?weeklyDays, 'weeklySummary': ?weeklySummary, 'timeZone': ?timeZone},
    ))!,
  );

  static String _date(DateTime d) => '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  static Metric metric(Object? m) {
    if (m is! Map) return Metric.zero;
    return Metric(m['value'] as num? ?? 0, m['kind'] == 'ESTIMATED' ? MetricKind.ESTIMATED : MetricKind.MEASURED);
  }

  static Map<String, Metric> metrics(Json? j) => {
    for (final e in (j ?? const {}).entries)
      if (e.value is Map && (e.value as Map).containsKey('value')) e.key: metric(e.value),
  };

  static DayActivity day(Json d) =>
      DayActivity(date: DateTime.parse(d.str('date')), minutes: d.integerOrNull('minutes') ?? 0, active: d.boolean('active'), goalMet: d.boolean('goalMet'));

  static Streak streak(Json? s) => Streak(
    current: s?.integerOrNull('current') ?? 0,
    best: s?.integerOrNull('best') ?? 0,
    weeksMet: s?.integerOrNull('weeksMet') ?? 0,
    target: s?.integerOrNull('target') ?? 3,
    activeThisWeek: s?.integerOrNull('activeThisWeek') ?? 0,
    metThisWeek: s?.boolean('metThisWeek') ?? false,
  );

  static Achievement achievement(Json a) => Achievement(
    code: a.str('code'),
    kind: a.strOrNull('kind') ?? '',
    threshold: a.integerOrNull('threshold') ?? 0,
    value: a.integerOrNull('value') ?? 0,
    earnedAt: a.dateOrNull('earnedAt'),
  );

  static Score score(Json s) => Score(key: s.str('key'), answered: s.integerOrNull('answered') ?? 0, score: s.integerOrNull('score') ?? 0);

  static Dashboard parseDashboard(Json j) {
    final goal = j.objOrNull('goal');
    final vocab = j.objOrNull('vocabulary');
    final comp = j.objOrNull('comprehension');
    final level = j.objOrNull('level');
    return Dashboard(
      language: j.str('language'),
      today: DateTime.parse(j.str('today')),
      dailyMinutes: goal?.integerOrNull('dailyMinutes') ?? 10,
      todayMinutes: metric(goal?['todayMinutes']),
      goalMet: goal?.boolean('met') ?? false,
      streak: streak(j.objOrNull('streak')),
      days: j.list('days', day),
      reading: metrics(j.objOrNull('reading')),
      vocabulary: metrics(vocab),
      growth: vocab == null ? const [] : vocab.list('growth', (g) => (DateTime.parse(g.str('weekStart')), g.integerOrNull('value') ?? 0)),
      answered: metric(comp?['answered']),
      average: comp?['average'] == null ? null : metric(comp!['average']),
      byType: comp == null ? const [] : comp.list('byType', score),
      byLevel: comp == null ? const [] : comp.list('byLevel', score),
      level: level?.strOrNull('level') ?? 'A1',
      levelKind: level?['kind'] == 'MEASURED' ? MetricKind.MEASURED : MetricKind.ESTIMATED,
      levelSignal: LevelSignal.values.where((s) => s.name == level?['signal']).firstOrNull ?? LevelSignal.unknown,
      answeredAtLevel: level?.integerOrNull('answeredAtLevel') ?? 0,
      recentAchievements: j.list('recentAchievements', achievement),
    );
  }

  static WeeklySummary parseWeekly(Json j) => WeeklySummary(
    weekStart: DateTime.parse(j.str('weekStart')),
    weekEnd: DateTime.parse(j.str('weekEnd')),
    current: j.boolean('current'),
    days: j.list('days', day),
    metrics: metrics(j),
    activeDays: j.integerOrNull('activeDays') ?? 0,
    target: j.integerOrNull('target') ?? 3,
    met: j.boolean('met'),
    achievements: j.list('achievements', achievement),
  );

  static Goals parseGoals(Json j) => Goals(
    dailyMinutes: j.integerOrNull('dailyMinutes') ?? 10,
    weeklyDays: j.integerOrNull('weeklyDays') ?? 3,
    timeZone: j.strOrNull('timeZone') ?? 'UTC',
    weeklySummary: j.boolean('weeklySummary'),
  );
}
