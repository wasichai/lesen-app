import 'package:flutter/widgets.dart';

import '../core/networking/api_failure.dart';
import '../features/catalog/domain/catalog_query.dart';
import '../features/catalog/domain/reading.dart';
import '../features/comprehension/domain/assessment.dart';
import '../features/profile/domain/learner_profile.dart';
import '../features/vocabulary/domain/known_words.dart';
import '../features/vocabulary/domain/vocabulary.dart';
import '../l10n/app_localizations.dart';

export '../l10n/app_localizations.dart';

extension L10nContext on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}

/// Textos de enumeraciones y fallos: aquí y no en cada pantalla, para que ninguna se quede sin traducir.
extension L10nLabels on AppLocalizations {
  String failure(Object error) {
    final f = ApiFailure.from(error);
    return switch (f) {
      OfflineFailure() => errorOffline,
      TimeoutFailure() => errorTimeout,
      ForbiddenFailure() => errorForbidden,
      NotFoundFailure() => errorNotFound,
      ServerFailure() => errorServer,
      ContractFailure() => errorContract,
      UnauthorizedFailure() => sessionExpired,
      RateLimitedFailure() => loginTooMany,
      _ => errorGeneric,
    };
  }

  String levelDescription(CefrLevel level) => switch (level) {
    CefrLevel.A1 => levelA1,
    CefrLevel.A2 => levelA2,
    CefrLevel.B1 => levelB1,
    CefrLevel.B2 => levelB2,
    CefrLevel.C1 => levelC1,
    CefrLevel.C2 => levelC2,
  };

  String goal(LearningGoal g) => switch (g) {
    LearningGoal.TRAVEL => goalTRAVEL,
    LearningGoal.WORK => goalWORK,
    LearningGoal.STUDY => goalSTUDY,
    LearningGoal.CULTURE => goalCULTURE,
    LearningGoal.FAMILY => goalFAMILY,
    LearningGoal.FUN => goalFUN,
    LearningGoal.EXAM => goalEXAM,
  };

  String difficulty(ReadingDifficulty d) => switch (d) {
    ReadingDifficulty.COMFORTABLE => difficultyCOMFORTABLE,
    ReadingDifficulty.BALANCED => difficultyBALANCED,
    ReadingDifficulty.CHALLENGING => difficultyCHALLENGING,
  };

  String difficultyBody(ReadingDifficulty d) => switch (d) {
    ReadingDifficulty.COMFORTABLE => difficultyCOMFORTABLEBody,
    ReadingDifficulty.BALANCED => difficultyBALANCEDBody,
    ReadingDifficulty.CHALLENGING => difficultyCHALLENGINGBody,
  };

  String? reason(RecommendationReason r) => switch (r) {
    RecommendationReason.LEVEL => reasonLEVEL,
    RecommendationReason.COMPREHENSION => reasonCOMPREHENSION,
    RecommendationReason.TOPIC => reasonTOPIC,
    RecommendationReason.HISTORY => reasonHISTORY,
    RecommendationReason.NEW => reasonNEW,
    RecommendationReason.TRENDING => reasonTRENDING,
    RecommendationReason.unknown => null,
  };

  String sort(CatalogSort s) => switch (s) {
    CatalogSort.RECENT => sortRECENT,
    CatalogSort.POPULAR => sortPOPULAR,
    CatalogSort.LEVEL => sortLEVEL,
    CatalogSort.DURATION => sortDURATION,
    CatalogSort.TITLE => sortTITLE,
  };

  String status(CatalogStatus s) => switch (s) {
    CatalogStatus.NOT_STARTED => statusNOT_STARTED,
    CatalogStatus.IN_PROGRESS => statusIN_PROGRESS,
    CatalogStatus.COMPLETED => statusCOMPLETED,
    CatalogStatus.BOOKMARKED => statusBOOKMARKED,
  };

  String duration(DurationRange d) => switch (d) {
    DurationRange.short => catalogDurationShort,
    DurationRange.medium => catalogDurationMedium,
    DurationRange.long => catalogDurationLong,
  };

  String wordStatus(WordStatus s) => switch (s) {
    WordStatus.SAVED => statusSAVED,
    WordStatus.LEARNING => statusLEARNING,
    WordStatus.FAMILIAR => statusFAMILIAR,
    WordStatus.MASTERED => statusMASTERED,
  };

  String rating(ReviewRating r) => switch (r) {
    ReviewRating.AGAIN => ratingAGAIN,
    ReviewRating.HARD => ratingHARD,
    ReviewRating.GOOD => ratingGOOD,
    ReviewRating.EASY => ratingEASY,
  };

  String result(AnswerResult r) => switch (r) {
    AnswerResult.CORRECT => resultCORRECT,
    AnswerResult.PARTIAL => resultPARTIAL,
    AnswerResult.INCORRECT => resultINCORRECT,
    AnswerResult.PENDING => resultPENDING,
    AnswerResult.UNGRADED || AnswerResult.unknown => resultUNGRADED,
  };

  String skill(QuestionType t) => switch (t) {
    QuestionType.MULTIPLE_CHOICE => skillMULTIPLE_CHOICE,
    QuestionType.TRUE_FALSE => skillTRUE_FALSE,
    QuestionType.COMPLETION => skillCOMPLETION,
    QuestionType.MATCHING => skillMATCHING,
    QuestionType.ORDERING => skillORDERING,
    QuestionType.SHORT_ANSWER => skillSHORT_ANSWER,
    QuestionType.VOCABULARY_IN_CONTEXT => skillVOCABULARY_IN_CONTEXT,
    QuestionType.MAIN_IDEA => skillMAIN_IDEA,
    QuestionType.INFERENCE => skillINFERENCE,
    QuestionType.DETAIL => skillDETAIL,
    QuestionType.unknown => skillunknown,
  };

  /// «10 min», «3 h», «16 días»: cuánto falta para una fecha.
  String until(DateTime when, DateTime now) {
    final d = when.difference(now);
    if (d.inMinutes < 60) return durMinutes(d.inMinutes.clamp(1, 59));
    if (d.inHours < 24) return durHours(d.inHours);
    return durDays((d.inHours / 24).round());
  }
}
