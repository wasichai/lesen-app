import 'package:flutter/widgets.dart';

import '../core/networking/api_failure.dart';
import '../features/catalog/domain/catalog_query.dart';
import '../features/catalog/domain/reading.dart';
import '../features/profile/domain/learner_profile.dart';
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
}
