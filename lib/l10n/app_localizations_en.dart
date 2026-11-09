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

  @override
  String get readerBack => 'Leave the reading';

  @override
  String get readerSettings => 'Text and aids';

  @override
  String get readerNotes => 'Notes';

  @override
  String get readerFocus => 'Distraction-free mode';

  @override
  String get readerFocusExit => 'Show controls';

  @override
  String readerRemaining(int count) {
    return '$count min left';
  }

  @override
  String get readerAlmostDone => 'Almost done';

  @override
  String readerProgress(int percent) {
    return 'Reading progress: $percent%';
  }

  @override
  String get readerHint => 'Tap any word to see what it means.';

  @override
  String readerOldVersion(int version) {
    return 'You\'re reading version $version, the one you started. A newer version is available.';
  }

  @override
  String get readerTranslateParagraph => 'Translate paragraph';

  @override
  String get readerHideParagraph => 'Hide translation';

  @override
  String get readerNoParagraphTranslation => 'This paragraph has no translation yet.';

  @override
  String get readerSavePending => 'Saved on this device; it will sync when you\'re back online.';

  @override
  String get readerFinish => 'I\'ve finished reading';

  @override
  String get readerFinishing => 'Saving…';

  @override
  String get wordLoading => 'Looking up the word…';

  @override
  String wordTitle(String word) {
    return 'The word “$word”';
  }

  @override
  String get wordNoEntry => 'We don\'t have this word in the dictionary yet.';

  @override
  String get wordNoEntryBody => 'We\'d rather say so than make up a translation.';

  @override
  String wordFormOf(String form, String lemma) {
    return '“$form” is a form of “$lemma”.';
  }

  @override
  String get wordDefinition => 'Definition';

  @override
  String get wordExamples => 'Examples';

  @override
  String get wordSynonyms => 'Synonyms';

  @override
  String get wordAntonyms => 'Antonyms';

  @override
  String get wordRelated => 'Related';

  @override
  String get wordForms => 'Forms';

  @override
  String get wordGrammar => 'Grammar';

  @override
  String get wordNote => 'Keep in mind';

  @override
  String get wordAlternatives => 'It could also be';

  @override
  String get wordSave => 'Save to my vocabulary';

  @override
  String get wordSaving => 'Saving…';

  @override
  String get wordSaved => 'In your vocabulary';

  @override
  String get wordSaveFailed => 'We couldn\'t save the word. Try again.';

  @override
  String get wordMore => 'See everything';

  @override
  String get wordLess => 'See less';

  @override
  String get wordInContext => 'In this sentence';

  @override
  String get wordTranslateSentence => 'Translate sentence';

  @override
  String get wordHideSentence => 'Hide translation';

  @override
  String get wordSentenceUnavailable => 'This sentence has no translation yet.';

  @override
  String get wordSaveSentence => 'Save sentence to my notes';

  @override
  String get wordSentenceSaved => 'Sentence saved to your notes';

  @override
  String get wordCopySentence => 'Copy sentence';

  @override
  String get wordCopied => 'Copied';

  @override
  String get wordAddNote => 'Add a note (optional)';

  @override
  String get wordPronunciation => 'Pronunciation';

  @override
  String get settingsSize => 'Font size';

  @override
  String get settingsSmaller => 'Smaller text';

  @override
  String get settingsLarger => 'Larger text';

  @override
  String get settingsLeading => 'Line spacing';

  @override
  String get leadingcompact => 'Compact';

  @override
  String get leadingcomfortable => 'Comfortable';

  @override
  String get leadingairy => 'Airy';

  @override
  String get settingsWidth => 'Text width';

  @override
  String get widthnarrow => 'Narrow';

  @override
  String get widthmedium => 'Medium';

  @override
  String get widthwide => 'Wide';

  @override
  String get settingsTheme => 'Reading theme';

  @override
  String get themelight => 'Light';

  @override
  String get themesepia => 'Sepia';

  @override
  String get themedark => 'Dark';

  @override
  String get settingsAssistance => 'Aids';

  @override
  String get settingsHighlightSaved => 'Highlight words you saved';

  @override
  String get settingsHighlightNew => 'Mark words that are new to you';

  @override
  String get settingsHighlightNewHint => 'Ones that weren\'t in any reading you finished and that you haven\'t saved.';

  @override
  String get settingsHighlightLearned => 'Mark words you\'ve already learned';

  @override
  String get settingsParagraphTranslations => 'Show each paragraph\'s translation';

  @override
  String get settingsParagraphTranslationsHint => 'Best left off: try to understand first and translate only what you need.';

  @override
  String get settingsResume => 'Return to where I left off';

  @override
  String get notesTitle => 'Your notes';

  @override
  String get notesEmpty => 'You haven\'t saved any sentences from this reading. Tap a word and choose “Save sentence”.';

  @override
  String get notesRemove => 'Delete note';

  @override
  String get notesGo => 'Go to sentence';

  @override
  String get endTitle => 'Reading finished!';

  @override
  String endBody(int words, String language) {
    return 'You read $words words in $language.';
  }

  @override
  String endTime(int count) {
    String _temp0 = intl.Intl.pluralLogic(count, locale: localeName, other: 'You spent $count minutes on it.', one: 'You spent 1 minute on it.');
    return '$_temp0';
  }

  @override
  String endSaved(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'You saved $count words.',
      one: 'You saved 1 word.',
      zero: 'You didn\'t save any words this time.',
    );
    return '$_temp0';
  }

  @override
  String get endDiscover => 'Back to Discover';

  @override
  String get endLibrary => 'See my readings';

  @override
  String get endFailed => 'We couldn\'t mark it as finished. Try again.';

  @override
  String get libraryInProgress => 'Reading';

  @override
  String get libraryBookmarked => 'Saved for later';

  @override
  String get libraryCompleted => 'Finished';

  @override
  String get libraryEmptyTitle => 'Your library is waiting';

  @override
  String get libraryEmptyBody => 'What you start, save or finish will show up here.';

  @override
  String get librarySearch => 'Search my readings';

  @override
  String get audioLabel => 'Reading audio';

  @override
  String get audioPlay => 'Listen';

  @override
  String get audioPause => 'Pause';

  @override
  String get audioBack => 'Back 5 seconds';

  @override
  String get audioForward => 'Forward 5 seconds';

  @override
  String get audioPreviousSentence => 'Previous sentence';

  @override
  String get audioNextSentence => 'Next sentence';

  @override
  String get audioPreviousParagraph => 'Previous paragraph';

  @override
  String get audioNextParagraph => 'Next paragraph';

  @override
  String get audioPosition => 'Audio position';

  @override
  String audioPositionValue(String current, String total) {
    return '$current of $total';
  }

  @override
  String get audioRate => 'Speed';

  @override
  String audioRateValue(String rate) {
    return 'Speed $rate×';
  }

  @override
  String get audioFollow => 'Follow the text';

  @override
  String get audioFollowBack => 'Back to what\'s playing';

  @override
  String get audioLoading => 'Loading audio…';

  @override
  String audioVoice(String voice) {
    return 'Voice: $voice';
  }

  @override
  String get audioError => 'We couldn\'t load the audio. You can keep reading.';

  @override
  String get audioFromHere => 'Listen from here';

  @override
  String get audioParagraph => 'Listen to this paragraph';

  @override
  String get audioOpenReading => 'Open the reading';

  @override
  String get audioClose => 'Close the player';

  @override
  String get audioExpand => 'Open the player';

  @override
  String get audioNowPlaying => 'Now playing';

  @override
  String get audioTapToPlayHint => 'While it plays, tap a word to listen from there.';

  @override
  String get vocabTitle => 'Vocabulary';

  @override
  String get vocabSearch => 'Search your vocabulary';

  @override
  String get vocabAll => 'All';

  @override
  String get statusSAVED => 'Saved';

  @override
  String get statusLEARNING => 'Learning';

  @override
  String get statusFAMILIAR => 'Familiar';

  @override
  String get statusMASTERED => 'Mastered';

  @override
  String get vocabEmptyTitle => 'Your notebook is blank';

  @override
  String get vocabEmptyBody => 'Tap a word while reading and save it: it\'ll show up here with the sentence you found it in.';

  @override
  String get vocabNoResults => 'No words match.';

  @override
  String get vocabReview => 'Review';

  @override
  String vocabReviewDue(int count) {
    String _temp0 = intl.Intl.pluralLogic(count, locale: localeName, other: 'Review $count words', one: 'Review 1 word', zero: 'Nothing to review now');
    return '$_temp0';
  }

  @override
  String vocabStatsTotal(int count) {
    String _temp0 = intl.Intl.pluralLogic(count, locale: localeName, other: '$count words', one: '1 word');
    return '$_temp0';
  }

  @override
  String vocabStatsToday(int count) {
    return '$count reviewed today';
  }

  @override
  String vocabStatsEncountered(int count) {
    return '$count met while reading';
  }

  @override
  String vocabFrom(String title) {
    return 'From “$title”';
  }

  @override
  String get vocabDueNow => 'Due for review';

  @override
  String vocabDueOn(String date) {
    return 'Next review: $date';
  }

  @override
  String vocabReviews(int count) {
    String _temp0 = intl.Intl.pluralLogic(count, locale: localeName, other: '$count reviews', one: '1 review', zero: 'Not reviewed yet');
    return '$_temp0';
  }

  @override
  String get vocabNote => 'Your note';

  @override
  String get vocabNoteHint => 'Something to help you remember it';

  @override
  String get vocabRemove => 'Remove from notebook';

  @override
  String vocabRemoveConfirm(String word) {
    return 'Remove “$word” from your notebook?';
  }

  @override
  String get vocabOpenReading => 'Open the reading';

  @override
  String get vocabOpenEntry => 'Open in dictionary';

  @override
  String get reviewTitle => 'Review';

  @override
  String reviewProgress(int current, int total) {
    return '$current of $total';
  }

  @override
  String get reviewShow => 'Show the answer';

  @override
  String get reviewPromptMeaning => 'What does it mean?';

  @override
  String reviewPromptWord(String language) {
    return 'How do you say it in $language?';
  }

  @override
  String get reviewPromptContext => 'Which word is missing?';

  @override
  String get reviewHowWell => 'How well did you remember it?';

  @override
  String get ratingAGAIN => 'Again';

  @override
  String get ratingHARD => 'Hard';

  @override
  String get ratingGOOD => 'Good';

  @override
  String get ratingEASY => 'Easy';

  @override
  String reviewIn(String when) {
    return 'in $when';
  }

  @override
  String get reviewDoneTitle => 'Review done!';

  @override
  String reviewDoneBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(count, locale: localeName, other: 'You reviewed $count words.', one: 'You reviewed 1 word.');
    return '$_temp0 Each one comes back when it\'s due, no sooner, no later.';
  }

  @override
  String get reviewNothing => 'Nothing to review right now';

  @override
  String get reviewNothingBody => 'Words come back when they\'re due. Keep reading and save the ones you want to learn.';

  @override
  String reviewNext(String date) {
    return 'Next review: $date';
  }

  @override
  String get reviewFailed => 'This review couldn\'t be saved. It\'ll be retried.';

  @override
  String get dictTitle => 'Dictionary';

  @override
  String dictSearchHint(String target, String interface) {
    return 'Search in $target or $interface';
  }

  @override
  String get dictHistory => 'Recent searches';

  @override
  String get dictClearHistory => 'Clear history';

  @override
  String get dictFavorites => 'Favorites';

  @override
  String dictNoResults(String query) {
    return 'We couldn\'t find “$query” in the dictionary.';
  }

  @override
  String get dictEmptyBody => 'Look up a word in either of your languages.';

  @override
  String get dictFavorite => 'Add to favorites';

  @override
  String get dictUnfavorite => 'Remove from favorites';

  @override
  String get dictAppearsIn => 'Appears in';

  @override
  String dictOccurrences(int count) {
    String _temp0 = intl.Intl.pluralLogic(count, locale: localeName, other: '$count times', one: 'once');
    return '$_temp0';
  }

  @override
  String get dictMeanings => 'Meanings';

  @override
  String get quizTitle => 'Comprehension';

  @override
  String quizStart(int count) {
    return 'Check what you understood ($count questions)';
  }

  @override
  String quizLastResult(int correct, int total) {
    return 'Last attempt: $correct of $total';
  }

  @override
  String quizQuestion(int current, int total) {
    return 'Question $current of $total';
  }

  @override
  String get quizNext => 'Next';

  @override
  String get quizPrevious => 'Previous';

  @override
  String get quizSubmit => 'Submit answers';

  @override
  String get quizSubmitting => 'Submitting…';

  @override
  String get quizTrue => 'True';

  @override
  String get quizFalse => 'False';

  @override
  String get quizChooseMany => 'Choose all that apply';

  @override
  String get quizBank => 'Words to fill in';

  @override
  String quizBlankEmpty(int n) {
    return 'Blank $n, empty';
  }

  @override
  String quizBlankFilled(int n, String word) {
    return 'Blank $n: $word. Tap to remove';
  }

  @override
  String get quizMatchHint => 'Choose the match for each one';

  @override
  String get quizMatchChoose => 'Choose';

  @override
  String get quizOrderHint => 'Put them in the order they happen in the text';

  @override
  String get quizMoveUp => 'Move up';

  @override
  String get quizMoveDown => 'Move down';

  @override
  String get quizShortHint => 'Answer in your own words, in whichever language you prefer';

  @override
  String quizUnanswered(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count questions are unanswered: they will count as incorrect.',
      one: '1 question is unanswered: it will count as incorrect.',
    );
    return '$_temp0';
  }

  @override
  String get quizResultTitle => 'Your result';

  @override
  String quizScore(int correct, int total) {
    return '$correct of $total correct';
  }

  @override
  String quizPartial(int count) {
    return '$count partly';
  }

  @override
  String quizPending(int count) {
    String _temp0 = intl.Intl.pluralLogic(count, locale: localeName, other: '$count answers are being graded…', one: '1 answer is being graded…');
    return '$_temp0';
  }

  @override
  String quizUngraded(int count) {
    String _temp0 = intl.Intl.pluralLogic(count, locale: localeName, other: '$count open answers for you to compare', one: '1 open answer for you to compare');
    return '$_temp0';
  }

  @override
  String get quizStrengths => 'What went well';

  @override
  String get quizImprove => 'To practise';

  @override
  String get resultCORRECT => 'Correct';

  @override
  String get resultPARTIAL => 'Partly correct';

  @override
  String get resultINCORRECT => 'Incorrect';

  @override
  String get resultPENDING => 'Grading…';

  @override
  String get resultUNGRADED => 'Self-assess';

  @override
  String get quizYourAnswer => 'Your answer';

  @override
  String get quizSolution => 'Answer';

  @override
  String get quizModelAnswer => 'Model answer';

  @override
  String get quizNoAnswer => 'Not answered';

  @override
  String get quizExplanation => 'Why';

  @override
  String get quizInText => 'In the text';

  @override
  String get quizAssisted => 'Assisted grading, with the sentences it relies on';

  @override
  String get quizRule => 'Automatic grading';

  @override
  String get quizSelf => 'Self-assessed';

  @override
  String get quizSelfPrompt => 'Compare your answer with the model answer. How did you do?';

  @override
  String get quizRetry => 'Try again';

  @override
  String get quizBackToReading => 'Back to the reading';

  @override
  String get skillMULTIPLE_CHOICE => 'Multiple choice';

  @override
  String get skillTRUE_FALSE => 'True or false';

  @override
  String get skillCOMPLETION => 'Sentence completion';

  @override
  String get skillMATCHING => 'Matching';

  @override
  String get skillORDERING => 'Ordering events';

  @override
  String get skillSHORT_ANSWER => 'Short answer';

  @override
  String get skillVOCABULARY_IN_CONTEXT => 'Vocabulary in context';

  @override
  String get skillMAIN_IDEA => 'Main idea';

  @override
  String get skillINFERENCE => 'Inference';

  @override
  String get skillDETAIL => 'Details';

  @override
  String get skillunknown => 'Other';

  @override
  String durMinutes(int count) {
    return '$count min';
  }

  @override
  String durHours(int count) {
    return '$count h';
  }

  @override
  String durDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(count, locale: localeName, other: '$count days', one: '1 day');
    return '$_temp0';
  }
}
