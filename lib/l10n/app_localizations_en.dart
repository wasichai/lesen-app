// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Lesen';

  @override
  String get commonRetry => 'Try again';

  @override
  String get commonBack => 'Back';

  @override
  String get commonContinue => 'Continue';

  @override
  String get commonCancel => 'Cancel';

  @override
  String get commonSave => 'Save';

  @override
  String get commonClose => 'Close';

  @override
  String get commonSeeAll => 'See all';

  @override
  String get errorOffline => 'You\'re offline. What\'s already on this device is still available.';

  @override
  String get errorTimeout => 'The server is taking too long to respond.';

  @override
  String get errorForbidden => 'Your account doesn\'t have access to this.';

  @override
  String get errorNotFound => 'We couldn\'t find what you\'re looking for.';

  @override
  String get errorServer => 'Something went wrong on the server. Try again in a moment.';

  @override
  String get errorContract => 'The server\'s response wasn\'t what we expected. The app may need an update.';

  @override
  String get errorGeneric => 'Something didn\'t go right.';

  @override
  String get offlineBanner => 'Offline: you can keep going with what\'s on this device.';

  @override
  String get loginTitle => 'Learn a language by reading';

  @override
  String get loginLead => 'Stories at your level, with every word one tap away.';

  @override
  String get loginEmail => 'Email';

  @override
  String get loginPassword => 'Password';

  @override
  String get loginShowPassword => 'Show password';

  @override
  String get loginHidePassword => 'Hide password';

  @override
  String get loginSubmit => 'Sign in';

  @override
  String get loginInvalid => 'The email or password is incorrect.';

  @override
  String get loginTooMany => 'Too many attempts. Wait a moment before trying again.';

  @override
  String get loginEmailRequired => 'Enter your email.';

  @override
  String get loginPasswordRequired => 'Enter your password.';

  @override
  String get loginNoAccount => 'Your account is created by whoever runs Lesen in your organization.';

  @override
  String get sessionExpired => 'Your session ended. Sign in again; anything pending is kept.';

  @override
  String get navDiscover => 'Discover';

  @override
  String get navLibrary => 'My readings';

  @override
  String get navVocabulary => 'Vocabulary';

  @override
  String get navProgress => 'Progress';

  @override
  String get navProfile => 'Profile';

  @override
  String get navSearch => 'Search';

  @override
  String onboardingStep(int current, int total) {
    return 'Step $current of $total';
  }

  @override
  String get onboardingFinish => 'Start reading';

  @override
  String get onboardingSaving => 'Saving…';

  @override
  String get onboardingError => 'We couldn\'t save your profile. Please try again.';

  @override
  String get onboardingWelcomeEyebrow => 'Hello';

  @override
  String get onboardingWelcomeHeading => 'Learn a language by reading stories you enjoy';

  @override
  String get onboardingWelcomeBody => 'Read, tap any word you don\'t know and save it for later. First, which language should the app speak?';

  @override
  String get onboardingTargetHeading => 'Which language do you want to read?';

  @override
  String get onboardingTargetBody => 'You can change it later in your profile.';

  @override
  String onboardingLevelHeading(String language) {
    return 'How do you read $language today?';
  }

  @override
  String get onboardingLevelBody => 'Pick what describes you best. You can change it any time.';

  @override
  String get onboardingLevelUnsure => 'I\'m not sure';

  @override
  String get onboardingLevelUnsureBody => 'We start at A2 and you adjust as you go. It\'s an estimate, not a grade.';

  @override
  String get onboardingInterestsHeading => 'What would you like to read?';

  @override
  String get onboardingInterestsBody => 'Pick whatever catches your eye. It helps us recommend.';

  @override
  String get onboardingGoals => 'Why you are learning';

  @override
  String get onboardingTopics => 'Topics';

  @override
  String get onboardingHabitHeading => 'A pace that suits you';

  @override
  String get onboardingHabitBody => 'A few minutes a day is enough. No punishing streaks: if you skip a day, that\'s fine.';

  @override
  String get onboardingDaily => 'Minutes a day';

  @override
  String get onboardingDifficulty => 'Reading difficulty';

  @override
  String minutesShort(int count) {
    return '$count min';
  }

  @override
  String minutesRead(int count) {
    String _temp0 = intl.Intl.pluralLogic(count, locale: localeName, other: '$count-minute read', one: '1-minute read');
    return '$_temp0';
  }

  @override
  String wordsCount(int count) {
    return '$count words';
  }

  @override
  String paragraphsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(count, locale: localeName, other: '$count paragraphs', one: '1 paragraph');
    return '$_temp0';
  }

  @override
  String readingsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(count, locale: localeName, other: '$count readings', one: '1 reading');
    return '$_temp0';
  }

  @override
  String readersThisWeek(int count) {
    String _temp0 = intl.Intl.pluralLogic(count, locale: localeName, other: '$count people finished it', one: '1 person finished it');
    return '$_temp0';
  }

  @override
  String get levelA1 => 'I understand single words and very basic phrases.';

  @override
  String get levelA2 => 'I can follow short, simple texts on everyday topics.';

  @override
  String get levelB1 => 'I get the gist of clear texts on familiar topics.';

  @override
  String get levelB2 => 'I read articles and stories fairly fluently.';

  @override
  String get levelC1 => 'I read long, demanding texts and catch what\'s implied.';

  @override
  String get levelC2 => 'I read almost anything with ease.';

  @override
  String get goalTRAVEL => 'Travel';

  @override
  String get goalWORK => 'Work';

  @override
  String get goalSTUDY => 'Study';

  @override
  String get goalCULTURE => 'Culture';

  @override
  String get goalFAMILY => 'Family and friends';

  @override
  String get goalFUN => 'For fun';

  @override
  String get goalEXAM => 'An exam';

  @override
  String get difficultyCOMFORTABLE => 'Comfortable';

  @override
  String get difficultyBALANCED => 'Balanced';

  @override
  String get difficultyCHALLENGING => 'Challenging';

  @override
  String get difficultyCOMFORTABLEBody => 'Readings you understand almost entirely.';

  @override
  String get difficultyBALANCEDBody => 'A few new words in every paragraph.';

  @override
  String get difficultyCHALLENGINGBody => 'A little above your level.';

  @override
  String get greetingMorning => 'Good morning';

  @override
  String get greetingAfternoon => 'Good afternoon';

  @override
  String get greetingEvening => 'Good evening';

  @override
  String greetingNamed(String greeting, String name) {
    return '$greeting, $name';
  }

  @override
  String discoverLead(String language, int minutes) {
    return 'Time to read in $language. Your goal: $minutes minutes, at your own pace.';
  }

  @override
  String get discoverFeatured => 'Featured';

  @override
  String get discoverContinue => 'Pick up where you left off';

  @override
  String get discoverRecommended => 'For you';

  @override
  String get discoverRecommendedLead => 'Chosen for your level and interests.';

  @override
  String get discoverThisWeek => 'Read this week';

  @override
  String get discoverFresh => 'Just published';

  @override
  String get discoverCollections => 'Collections';

  @override
  String get discoverTopics => 'Explore by topic';

  @override
  String get discoverLevels => 'Explore by level';

  @override
  String get discoverCatalog => 'Browse the whole catalog';

  @override
  String discoverEmpty(String language) {
    return 'No readings in $language yet';
  }

  @override
  String get discoverEmptyBody => 'They\'re on their way. Meanwhile, browse the catalog in other languages.';

  @override
  String get reasonLEVEL => 'At your level';

  @override
  String get reasonCOMPREHENSION => 'Based on your comprehension';

  @override
  String get reasonTOPIC => 'From your topics';

  @override
  String get reasonHISTORY => 'Like what you\'ve read';

  @override
  String get reasonNEW => 'New';

  @override
  String get reasonTRENDING => 'Read this week';

  @override
  String get catalogTitle => 'Catalog';

  @override
  String get catalogSearch => 'Search readings';

  @override
  String get catalogSearchHint => 'Title, topic or idea…';

  @override
  String get catalogLanguage => 'Language';

  @override
  String get catalogAllLanguages => 'All';

  @override
  String get catalogLevel => 'Level';

  @override
  String get catalogTopic => 'Topic';

  @override
  String get catalogAllTopics => 'All topics';

  @override
  String get catalogDuration => 'Duration';

  @override
  String get catalogDurationShort => 'Up to 3 min';

  @override
  String get catalogDurationMedium => '4–6 min';

  @override
  String get catalogDurationLong => '7 min or more';

  @override
  String get catalogSort => 'Sort';

  @override
  String get sortRECENT => 'Newest';

  @override
  String get sortPOPULAR => 'Most read';

  @override
  String get sortLEVEL => 'By level';

  @override
  String get sortDURATION => 'Shortest first';

  @override
  String get sortTITLE => 'By title';

  @override
  String get catalogFilters => 'Filters';

  @override
  String catalogFiltersCount(int count) {
    return 'Filters ($count)';
  }

  @override
  String get catalogClear => 'Clear filters';

  @override
  String get catalogApply => 'Show results';

  @override
  String catalogResults(int count) {
    String _temp0 = intl.Intl.pluralLogic(count, locale: localeName, other: '$count readings', one: '1 reading', zero: 'No readings');
    return '$_temp0';
  }

  @override
  String get catalogEmpty => 'Nothing matches these filters';

  @override
  String get catalogEmptyBody => 'Try another level or remove a filter.';

  @override
  String get statusNOT_STARTED => 'Not started';

  @override
  String get statusIN_PROGRESS => 'In progress';

  @override
  String get statusCOMPLETED => 'Completed';

  @override
  String get statusBOOKMARKED => 'Saved';

  @override
  String cardProgress(int percent) {
    return '$percent% read';
  }

  @override
  String get cardCompleted => 'Completed';

  @override
  String cardSemantics(String title, String language, String level, int minutes) {
    return '$title. $language, level $level, $minutes minutes.';
  }

  @override
  String get detailStart => 'Start reading';

  @override
  String get detailContinue => 'Continue reading';

  @override
  String get detailReadAgain => 'Read again';

  @override
  String get detailBookmark => 'Save for later';

  @override
  String get detailBookmarked => 'Saved';

  @override
  String get detailRelated => 'If you like this one, try';

  @override
  String get detailInCollections => 'In collections';

  @override
  String detailReaders(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count people opened it',
      one: '1 person opened it',
      zero: 'Nobody has opened it yet',
    );
    return '$_temp0';
  }

  @override
  String get readerComingSoon => 'The immersive reader arrives in the next version of the app.';

  @override
  String get libraryComingSoon => 'Here you\'ll see what you\'re reading, what you saved and what you finished.';

  @override
  String get vocabularyComingSoon => 'The words you save while reading will live here, ready to review.';

  @override
  String get progressComingSoon => 'Your progress will show here: what\'s measured and what\'s estimated, no penalties.';

  @override
  String get comingSoonTitle => 'Coming soon';

  @override
  String get profileTitle => 'Your profile';

  @override
  String get profileInterface => 'App language';

  @override
  String get profileTarget => 'Language you read';

  @override
  String get profileLevel => 'Level';

  @override
  String get profileLevelEstimated => 'estimated';

  @override
  String get profileDaily => 'Daily goal';

  @override
  String get profileEdit => 'Edit preferences';

  @override
  String get profileSignOut => 'Sign out';

  @override
  String profileSignedInAs(String email) {
    return 'Signed in as $email';
  }

  @override
  String get profileAbout => 'About Lesen';

  @override
  String profileVersion(String version, String env) {
    return 'Version $version · $env';
  }

  @override
  String get catalogStatus => 'Status';

  @override
  String get detailBookmarkFailed => 'We couldn\'t save that change. Try again.';

  @override
  String get profileTopics => 'Topics';

  @override
  String get profileGoals => 'Goals';

  @override
  String get profileDifficulty => 'Difficulty';
}
