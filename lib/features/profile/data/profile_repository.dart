import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/networking/api_client.dart';
import '../../../core/networking/api_failure.dart';
import '../../../core/networking/json.dart';
import '../../catalog/domain/reading.dart';
import '../domain/learner_profile.dart';

final profileRepositoryProvider = Provider<ProfileRepository>((ref) => ProfileRepository(ref.watch(apiProvider)));

class ProfileRepository {
  ProfileRepository(this._api);

  final Api _api;
  static const _path = '/lesen/learner/profile';

  /// `null` hasta completar el onboarding.
  Future<LearnerProfile?> fetch() async {
    final json = await _api.getJsonOrNull(_path);
    return json == null ? null : parse(json);
  }

  Future<LearnerProfile> save(LearnerProfile p) async {
    final json = await _api.send('PUT', _path, body: toJson(p));
    return json == null ? p : parse(json);
  }

  static LearnerProfile parse(Json j) {
    final level = cefrOf(j.strOrNull('level'));
    if (level == null) throw ContractException('level: "${j['level']}"');
    return LearnerProfile(
      interfaceLanguage: j.str('interfaceLanguage'),
      targetLanguage: j.str('targetLanguage'),
      level: level,
      levelEstimated: j.boolean('levelEstimated'),
      goals: {for (final g in j.strings('goals')) ...LearningGoal.values.where((v) => v.name == g)},
      topics: j.strings('topics'),
      dailyMinutes: j.integerOrNull('dailyMinutes') ?? 10,
      difficulty: enumByName(ReadingDifficulty.values, j.strOrNull('difficulty'), ReadingDifficulty.BALANCED),
    );
  }

  static Json toJson(LearnerProfile p) => {
    'interfaceLanguage': p.interfaceLanguage,
    'targetLanguage': p.targetLanguage,
    'level': p.level.name,
    'levelEstimated': p.levelEstimated,
    'goals': (p.goals.toList()..sort((a, b) => a.index - b.index)).map((g) => g.name).toList(),
    'topics': p.topics,
    'dailyMinutes': p.dailyMinutes,
    'difficulty': p.difficulty.name,
  };
}
