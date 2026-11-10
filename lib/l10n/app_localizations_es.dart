// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appName => 'Lesen';

  @override
  String get commonRetry => 'Reintentar';

  @override
  String get commonBack => 'Atrás';

  @override
  String get commonContinue => 'Continuar';

  @override
  String get commonCancel => 'Cancelar';

  @override
  String get commonSave => 'Guardar';

  @override
  String get commonClose => 'Cerrar';

  @override
  String get commonSeeAll => 'Ver todo';

  @override
  String get errorOffline => 'Sin conexión. Lo que ya está en el dispositivo sigue disponible.';

  @override
  String get errorTimeout => 'El servidor tarda en responder.';

  @override
  String get errorForbidden => 'Tu cuenta no tiene acceso a esto.';

  @override
  String get errorNotFound => 'No encontramos lo que buscas.';

  @override
  String get errorServer => 'Algo falló en el servidor. Inténtalo de nuevo en un momento.';

  @override
  String get errorContract => 'La respuesta del servidor no es la esperada. Puede que haga falta actualizar la app.';

  @override
  String get errorGeneric => 'Algo no salió bien.';

  @override
  String get offlineBanner => 'Sin conexión: puedes seguir con lo que ya está en el dispositivo.';

  @override
  String get loginTitle => 'Aprende un idioma leyendo';

  @override
  String get loginLead => 'Historias a tu nivel, con cada palabra a un toque.';

  @override
  String get loginEmail => 'Correo electrónico';

  @override
  String get loginPassword => 'Contraseña';

  @override
  String get loginShowPassword => 'Mostrar contraseña';

  @override
  String get loginHidePassword => 'Ocultar contraseña';

  @override
  String get loginSubmit => 'Entrar';

  @override
  String get loginInvalid => 'El correo o la contraseña no son correctos.';

  @override
  String get loginTooMany => 'Demasiados intentos. Espera un momento antes de volver a probar.';

  @override
  String get loginEmailRequired => 'Escribe tu correo.';

  @override
  String get loginPasswordRequired => 'Escribe tu contraseña.';

  @override
  String get loginNoAccount => 'Tu cuenta la crea quien administra Lesen en tu organización.';

  @override
  String get sessionExpired => 'Tu sesión terminó. Vuelve a entrar; lo que tenías pendiente se conserva.';

  @override
  String get navDiscover => 'Descubrir';

  @override
  String get navLibrary => 'Mis lecturas';

  @override
  String get navVocabulary => 'Vocabulario';

  @override
  String get navProgress => 'Progreso';

  @override
  String get navProfile => 'Perfil';

  @override
  String get navSearch => 'Buscar';

  @override
  String onboardingStep(int current, int total) {
    return 'Paso $current de $total';
  }

  @override
  String get onboardingFinish => 'Empezar a leer';

  @override
  String get onboardingSaving => 'Guardando…';

  @override
  String get onboardingError => 'No pudimos guardar tu perfil. Inténtalo de nuevo.';

  @override
  String get onboardingWelcomeEyebrow => 'Hola';

  @override
  String get onboardingWelcomeHeading => 'Aprende un idioma leyendo historias que te gustan';

  @override
  String get onboardingWelcomeBody => 'Lee, toca cualquier palabra que no conozcas y guárdala para después. Primero, ¿en qué idioma quieres usar la app?';

  @override
  String get onboardingTargetHeading => '¿Qué idioma quieres leer?';

  @override
  String get onboardingTargetBody => 'Podrás cambiarlo más adelante en tu perfil.';

  @override
  String onboardingLevelHeading(String language) {
    return '¿Cómo lees en $language hoy?';
  }

  @override
  String get onboardingLevelBody => 'Elige lo que mejor te describa. Puedes cambiarlo cuando quieras.';

  @override
  String get onboardingLevelUnsure => 'No estoy segura o seguro';

  @override
  String get onboardingLevelUnsureBody => 'Empezamos por A2 y ajustas sobre la marcha. Es una estimación, no una nota.';

  @override
  String get onboardingInterestsHeading => '¿Qué te gustaría leer?';

  @override
  String get onboardingInterestsBody => 'Elige lo que te llame. Así recomendamos mejor.';

  @override
  String get onboardingGoals => 'Para qué aprendes';

  @override
  String get onboardingTopics => 'Temas';

  @override
  String get onboardingHabitHeading => 'Un ritmo que te siente bien';

  @override
  String get onboardingHabitBody => 'Unos minutos al día bastan. Sin rachas que castiguen: si un día no lees, no pasa nada.';

  @override
  String get onboardingDaily => 'Minutos al día';

  @override
  String get onboardingDifficulty => 'Dificultad de las lecturas';

  @override
  String minutesShort(int count) {
    return '$count min';
  }

  @override
  String minutesRead(int count) {
    String _temp0 = intl.Intl.pluralLogic(count, locale: localeName, other: '$count minutos de lectura', one: '1 minuto de lectura');
    return '$_temp0';
  }

  @override
  String wordsCount(int count) {
    return '$count palabras';
  }

  @override
  String paragraphsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(count, locale: localeName, other: '$count párrafos', one: '1 párrafo');
    return '$_temp0';
  }

  @override
  String readingsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(count, locale: localeName, other: '$count lecturas', one: '1 lectura');
    return '$_temp0';
  }

  @override
  String readersThisWeek(int count) {
    String _temp0 = intl.Intl.pluralLogic(count, locale: localeName, other: '$count personas la terminaron', one: '1 persona la terminó');
    return '$_temp0';
  }

  @override
  String get levelA1 => 'Entiendo palabras sueltas y frases muy básicas.';

  @override
  String get levelA2 => 'Sigo textos cortos y sencillos sobre temas cotidianos.';

  @override
  String get levelB1 => 'Entiendo lo esencial de textos claros sobre temas conocidos.';

  @override
  String get levelB2 => 'Leo artículos y relatos con bastante soltura.';

  @override
  String get levelC1 => 'Leo textos largos y exigentes y capto lo implícito.';

  @override
  String get levelC2 => 'Leo casi cualquier cosa con facilidad.';

  @override
  String get goalTRAVEL => 'Viajar';

  @override
  String get goalWORK => 'Trabajo';

  @override
  String get goalSTUDY => 'Estudios';

  @override
  String get goalCULTURE => 'Cultura';

  @override
  String get goalFAMILY => 'Familia y amistades';

  @override
  String get goalFUN => 'Por gusto';

  @override
  String get goalEXAM => 'Un examen';

  @override
  String get difficultyCOMFORTABLE => 'Cómoda';

  @override
  String get difficultyBALANCED => 'Equilibrada';

  @override
  String get difficultyCHALLENGING => 'Un reto';

  @override
  String get difficultyCOMFORTABLEBody => 'Lecturas que entiendes casi enteras.';

  @override
  String get difficultyBALANCEDBody => 'Algunas palabras nuevas en cada párrafo.';

  @override
  String get difficultyCHALLENGINGBody => 'Un poco por encima de tu nivel.';

  @override
  String get greetingMorning => 'Buenos días';

  @override
  String get greetingAfternoon => 'Buenas tardes';

  @override
  String get greetingEvening => 'Buenas noches';

  @override
  String greetingNamed(String greeting, String name) {
    return '$greeting, $name';
  }

  @override
  String discoverLead(String language, int minutes) {
    return 'Hoy toca leer en $language. Tu meta: $minutes minutos, a tu ritmo.';
  }

  @override
  String get discoverFeatured => 'Destacada';

  @override
  String get discoverContinue => 'Sigue donde lo dejaste';

  @override
  String get discoverRecommended => 'Para ti';

  @override
  String get discoverRecommendedLead => 'Elegidas por tu nivel y lo que te interesa.';

  @override
  String get discoverThisWeek => 'Lo que se lee esta semana';

  @override
  String get discoverFresh => 'Recién publicadas';

  @override
  String get discoverCollections => 'Colecciones';

  @override
  String get discoverTopics => 'Explora por temas';

  @override
  String get discoverLevels => 'Explora por nivel';

  @override
  String get discoverCatalog => 'Ver todo el catálogo';

  @override
  String discoverEmpty(String language) {
    return 'Aún no hay lecturas en $language';
  }

  @override
  String get discoverEmptyBody => 'Pronto llegarán. Mientras, mira el catálogo en otros idiomas.';

  @override
  String get reasonLEVEL => 'A tu nivel';

  @override
  String get reasonCOMPREHENSION => 'Por cómo entiendes';

  @override
  String get reasonTOPIC => 'De tus temas';

  @override
  String get reasonHISTORY => 'Como lo que leíste';

  @override
  String get reasonNEW => 'Nueva';

  @override
  String get reasonTRENDING => 'Se lee esta semana';

  @override
  String get catalogTitle => 'Catálogo';

  @override
  String get catalogSearch => 'Buscar lecturas';

  @override
  String get catalogSearchHint => 'Título, tema o idea…';

  @override
  String get catalogLanguage => 'Idioma';

  @override
  String get catalogAllLanguages => 'Todos';

  @override
  String get catalogLevel => 'Nivel';

  @override
  String get catalogTopic => 'Tema';

  @override
  String get catalogAllTopics => 'Todos los temas';

  @override
  String get catalogDuration => 'Duración';

  @override
  String get catalogDurationShort => 'Hasta 3 min';

  @override
  String get catalogDurationMedium => '4–6 min';

  @override
  String get catalogDurationLong => '7 min o más';

  @override
  String get catalogSort => 'Ordenar';

  @override
  String get sortRECENT => 'Más recientes';

  @override
  String get sortPOPULAR => 'Más leídas';

  @override
  String get sortLEVEL => 'Por nivel';

  @override
  String get sortDURATION => 'Más cortas primero';

  @override
  String get sortTITLE => 'Por título';

  @override
  String get catalogFilters => 'Filtros';

  @override
  String catalogFiltersCount(int count) {
    return 'Filtros ($count)';
  }

  @override
  String get catalogClear => 'Quitar filtros';

  @override
  String get catalogApply => 'Ver resultados';

  @override
  String catalogResults(int count) {
    String _temp0 = intl.Intl.pluralLogic(count, locale: localeName, other: '$count lecturas', one: '1 lectura', zero: 'Ninguna lectura');
    return '$_temp0';
  }

  @override
  String get catalogEmpty => 'Nada coincide con estos filtros';

  @override
  String get catalogEmptyBody => 'Prueba con otro nivel o quita algún filtro.';

  @override
  String get statusNOT_STARTED => 'Sin empezar';

  @override
  String get statusIN_PROGRESS => 'En curso';

  @override
  String get statusCOMPLETED => 'Terminada';

  @override
  String get statusBOOKMARKED => 'Guardada';

  @override
  String cardProgress(int percent) {
    return '$percent % leído';
  }

  @override
  String get cardCompleted => 'Terminada';

  @override
  String cardSemantics(String title, String language, String level, int minutes) {
    return '$title. $language, nivel $level, $minutes minutos.';
  }

  @override
  String get detailStart => 'Empezar a leer';

  @override
  String get detailContinue => 'Seguir leyendo';

  @override
  String get detailReadAgain => 'Leer otra vez';

  @override
  String get detailBookmark => 'Guardar para después';

  @override
  String get detailBookmarked => 'Guardada';

  @override
  String get detailRelated => 'Si te gusta esta, prueba';

  @override
  String get detailInCollections => 'En las colecciones';

  @override
  String detailReaders(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count personas la abrieron',
      one: '1 persona la abrió',
      zero: 'Aún nadie la abrió',
    );
    return '$_temp0';
  }

  @override
  String get profileTitle => 'Tu perfil';

  @override
  String get profileInterface => 'Idioma de la app';

  @override
  String get profileTarget => 'Idioma que lees';

  @override
  String get profileLevel => 'Nivel';

  @override
  String get profileLevelEstimated => 'estimado';

  @override
  String get profileDaily => 'Meta diaria';

  @override
  String get profileEdit => 'Editar preferencias';

  @override
  String get profileSignOut => 'Cerrar sesión';

  @override
  String profileSignedInAs(String email) {
    return 'Has entrado como $email';
  }

  @override
  String get profileAbout => 'Acerca de Lesen';

  @override
  String profileVersion(String version, String env) {
    return 'Versión $version · $env';
  }

  @override
  String get catalogStatus => 'Estado';

  @override
  String get detailBookmarkFailed => 'No pudimos guardar el cambio. Inténtalo de nuevo.';

  @override
  String get profileTopics => 'Temas';

  @override
  String get profileGoals => 'Metas';

  @override
  String get profileDifficulty => 'Dificultad';

  @override
  String get readerBack => 'Salir de la lectura';

  @override
  String get readerSettings => 'Texto y ayudas';

  @override
  String get readerNotes => 'Notas';

  @override
  String get readerFocus => 'Modo sin distracciones';

  @override
  String get readerFocusExit => 'Mostrar los controles';

  @override
  String readerRemaining(int count) {
    return 'Quedan $count min';
  }

  @override
  String get readerAlmostDone => 'Casi terminas';

  @override
  String readerProgress(int percent) {
    return 'Avance de la lectura: $percent %';
  }

  @override
  String get readerHint => 'Toca cualquier palabra para ver qué significa.';

  @override
  String readerOldVersion(int version) {
    return 'Estás leyendo la versión $version, la que empezaste. Hay una versión más reciente.';
  }

  @override
  String get readerTranslateParagraph => 'Traducir el párrafo';

  @override
  String get readerHideParagraph => 'Ocultar la traducción';

  @override
  String get readerIllustrationMissing => 'No se pudo cargar esta ilustración.';

  @override
  String get readerNoParagraphTranslation => 'Este párrafo aún no tiene traducción.';

  @override
  String get readerSavePending => 'Guardado en el dispositivo; se enviará al volver la conexión.';

  @override
  String get readerFinish => 'Terminé de leer';

  @override
  String get readerFinishing => 'Guardando…';

  @override
  String get wordLoading => 'Buscando la palabra…';

  @override
  String wordTitle(String word) {
    return 'La palabra «$word»';
  }

  @override
  String get wordNoEntry => 'Todavía no tenemos esta palabra en el diccionario.';

  @override
  String get wordNoEntryBody => 'Preferimos decirlo antes que inventar una traducción.';

  @override
  String wordFormOf(String form, String lemma) {
    return '«$form» es una forma de «$lemma».';
  }

  @override
  String get wordDefinition => 'Definición';

  @override
  String get wordExamples => 'Ejemplos';

  @override
  String get wordSynonyms => 'Sinónimos';

  @override
  String get wordAntonyms => 'Antónimos';

  @override
  String get wordRelated => 'Relacionadas';

  @override
  String get wordForms => 'Formas';

  @override
  String get wordGrammar => 'Gramática';

  @override
  String get wordNote => 'Ten en cuenta';

  @override
  String get wordAlternatives => 'También puede ser';

  @override
  String get wordSave => 'Guardar en mi vocabulario';

  @override
  String get wordSaving => 'Guardando…';

  @override
  String get wordSaved => 'En tu vocabulario';

  @override
  String get wordSaveFailed => 'No pudimos guardar la palabra. Inténtalo de nuevo.';

  @override
  String get wordMore => 'Ver todo';

  @override
  String get wordLess => 'Ver menos';

  @override
  String get wordInContext => 'En esta oración';

  @override
  String get wordTranslateSentence => 'Traducir la oración';

  @override
  String get wordHideSentence => 'Ocultar la traducción';

  @override
  String get wordSentenceUnavailable => 'Esta oración aún no tiene traducción.';

  @override
  String get wordSaveSentence => 'Guardar la oración en mis notas';

  @override
  String get wordSentenceSaved => 'Oración guardada en tus notas';

  @override
  String get wordCopySentence => 'Copiar la oración';

  @override
  String get wordCopied => 'Copiada';

  @override
  String get wordAddNote => 'Añadir una nota (opcional)';

  @override
  String get wordPronunciation => 'Pronunciación';

  @override
  String get settingsSize => 'Tamaño de letra';

  @override
  String get settingsSmaller => 'Letra más pequeña';

  @override
  String get settingsLarger => 'Letra más grande';

  @override
  String get settingsLeading => 'Interlineado';

  @override
  String get leadingcompact => 'Junto';

  @override
  String get leadingcomfortable => 'Cómodo';

  @override
  String get leadingairy => 'Amplio';

  @override
  String get settingsWidth => 'Ancho del texto';

  @override
  String get widthnarrow => 'Estrecho';

  @override
  String get widthmedium => 'Medio';

  @override
  String get widthwide => 'Ancho';

  @override
  String get settingsTheme => 'Tema de lectura';

  @override
  String get themelight => 'Claro';

  @override
  String get themesepia => 'Sepia';

  @override
  String get themedark => 'Oscuro';

  @override
  String get settingsAssistance => 'Ayudas';

  @override
  String get settingsHighlightSaved => 'Resaltar las palabras que guardaste';

  @override
  String get settingsHighlightNew => 'Marcar las palabras nuevas para ti';

  @override
  String get settingsHighlightNewHint => 'Las que no aparecieron en ninguna lectura que terminaste ni guardaste.';

  @override
  String get settingsHighlightLearned => 'Marcar las palabras que ya aprendiste';

  @override
  String get settingsParagraphTranslations => 'Mostrar la traducción de cada párrafo';

  @override
  String get settingsParagraphTranslationsHint => 'Mejor apagada: intenta entender primero y traduce solo lo que necesites.';

  @override
  String get settingsResume => 'Volver a donde lo dejé al abrir';

  @override
  String get notesTitle => 'Tus notas';

  @override
  String get notesEmpty => 'Aún no guardaste oraciones de esta lectura. Toca una palabra y elige «Guardar la oración».';

  @override
  String get notesRemove => 'Borrar la nota';

  @override
  String get notesGo => 'Ir a la oración';

  @override
  String get endTitle => '¡Lectura terminada!';

  @override
  String endBody(int words, String language) {
    return 'Leíste $words palabras en $language.';
  }

  @override
  String endTime(int count) {
    String _temp0 = intl.Intl.pluralLogic(count, locale: localeName, other: 'Le dedicaste $count minutos.', one: 'Le dedicaste 1 minuto.');
    return '$_temp0';
  }

  @override
  String endSaved(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Guardaste $count palabras.',
      one: 'Guardaste 1 palabra.',
      zero: 'No guardaste palabras esta vez.',
    );
    return '$_temp0';
  }

  @override
  String get endDiscover => 'Volver a Descubrir';

  @override
  String get endLibrary => 'Ver mis lecturas';

  @override
  String get endFailed => 'No pudimos marcarla como terminada. Inténtalo de nuevo.';

  @override
  String get libraryInProgress => 'Leyendo';

  @override
  String get libraryBookmarked => 'Guardadas para después';

  @override
  String get libraryCompleted => 'Terminadas';

  @override
  String get libraryEmptyTitle => 'Tu biblioteca está esperando';

  @override
  String get libraryEmptyBody => 'Lo que empieces, guardes o termines aparecerá aquí.';

  @override
  String get librarySearch => 'Buscar en mis lecturas';

  @override
  String get audioLabel => 'Audio de la lectura';

  @override
  String get audioPlay => 'Escuchar';

  @override
  String get audioPause => 'Pausar';

  @override
  String get audioBack => 'Retroceder 5 segundos';

  @override
  String get audioForward => 'Avanzar 5 segundos';

  @override
  String get audioPreviousSentence => 'Oración anterior';

  @override
  String get audioNextSentence => 'Oración siguiente';

  @override
  String get audioPreviousParagraph => 'Párrafo anterior';

  @override
  String get audioNextParagraph => 'Párrafo siguiente';

  @override
  String get audioPosition => 'Posición del audio';

  @override
  String audioPositionValue(String current, String total) {
    return '$current de $total';
  }

  @override
  String get audioRate => 'Velocidad';

  @override
  String audioRateValue(String rate) {
    return 'Velocidad $rate×';
  }

  @override
  String get audioFollow => 'Seguir la lectura';

  @override
  String get audioFollowBack => 'Volver a lo que suena';

  @override
  String get audioLoading => 'Cargando el audio…';

  @override
  String audioVoice(String voice) {
    return 'Voz: $voice';
  }

  @override
  String get audioError => 'No pudimos cargar el audio. Puedes seguir leyendo igual.';

  @override
  String get audioFromHere => 'Escuchar desde aquí';

  @override
  String get audioParagraph => 'Escuchar este párrafo';

  @override
  String get audioOpenReading => 'Abrir la lectura';

  @override
  String get audioClose => 'Cerrar el reproductor';

  @override
  String get audioExpand => 'Abrir el reproductor';

  @override
  String get audioNowPlaying => 'Ahora suena';

  @override
  String get audioTapToPlayHint => 'Mientras suena, toca una palabra para escuchar desde ella.';

  @override
  String get vocabTitle => 'Vocabulario';

  @override
  String get vocabSearch => 'Buscar en tu vocabulario';

  @override
  String get vocabAll => 'Todas';

  @override
  String get statusSAVED => 'Guardada';

  @override
  String get statusLEARNING => 'Aprendiendo';

  @override
  String get statusFAMILIAR => 'Familiar';

  @override
  String get statusMASTERED => 'Dominada';

  @override
  String get vocabEmptyTitle => 'Tu cuaderno está en blanco';

  @override
  String get vocabEmptyBody => 'Toca una palabra mientras lees y guárdala: aparecerá aquí, con la oración donde la encontraste.';

  @override
  String get vocabNoResults => 'Ninguna palabra coincide.';

  @override
  String get vocabReview => 'Repasar';

  @override
  String vocabReviewDue(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Repasar $count palabras',
      one: 'Repasar 1 palabra',
      zero: 'Nada que repasar ahora',
    );
    return '$_temp0';
  }

  @override
  String vocabStatsTotal(int count) {
    String _temp0 = intl.Intl.pluralLogic(count, locale: localeName, other: '$count palabras', one: '1 palabra');
    return '$_temp0';
  }

  @override
  String vocabStatsToday(int count) {
    return '$count repasadas hoy';
  }

  @override
  String vocabStatsEncountered(int count) {
    return '$count encontradas al leer';
  }

  @override
  String vocabFrom(String title) {
    return 'De «$title»';
  }

  @override
  String get vocabDueNow => 'Toca repasarla';

  @override
  String vocabDueOn(String date) {
    return 'Próximo repaso: $date';
  }

  @override
  String vocabReviews(int count) {
    String _temp0 = intl.Intl.pluralLogic(count, locale: localeName, other: '$count repasos', one: '1 repaso', zero: 'Sin repasos todavía');
    return '$_temp0';
  }

  @override
  String get vocabNote => 'Tu nota';

  @override
  String get vocabNoteHint => 'Algo que te ayude a recordarla';

  @override
  String get vocabRemove => 'Quitar del cuaderno';

  @override
  String vocabRemoveConfirm(String word) {
    return '¿Quitar «$word» de tu cuaderno?';
  }

  @override
  String get vocabOpenReading => 'Abrir la lectura';

  @override
  String get vocabOpenEntry => 'Abrir en el diccionario';

  @override
  String get reviewTitle => 'Repaso';

  @override
  String reviewProgress(int current, int total) {
    return '$current de $total';
  }

  @override
  String get reviewShow => 'Mostrar la respuesta';

  @override
  String get reviewPromptMeaning => '¿Qué significa?';

  @override
  String reviewPromptWord(String language) {
    return '¿Cómo se dice en $language?';
  }

  @override
  String get reviewPromptContext => '¿Qué palabra falta?';

  @override
  String get reviewHowWell => '¿Qué tal la recordaste?';

  @override
  String get ratingAGAIN => 'Otra vez';

  @override
  String get ratingHARD => 'Difícil';

  @override
  String get ratingGOOD => 'Bien';

  @override
  String get ratingEASY => 'Fácil';

  @override
  String reviewIn(String when) {
    return 'en $when';
  }

  @override
  String get reviewDoneTitle => '¡Repaso hecho!';

  @override
  String reviewDoneBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(count, locale: localeName, other: 'Repasaste $count palabras.', one: 'Repasaste 1 palabra.');
    return '$_temp0 Cada una vuelve cuando toca, ni antes ni después.';
  }

  @override
  String get reviewNothing => 'Nada que repasar ahora';

  @override
  String get reviewNothingBody => 'Las palabras vuelven cuando toca. Sigue leyendo y guarda las que quieras aprender.';

  @override
  String reviewNext(String date) {
    return 'Siguiente repaso: $date';
  }

  @override
  String get reviewFailed => 'No se pudo guardar este repaso. Se reintentará.';

  @override
  String get dictTitle => 'Diccionario';

  @override
  String dictSearchHint(String target, String interface) {
    return 'Busca en $target o en $interface';
  }

  @override
  String get dictHistory => 'Búsquedas recientes';

  @override
  String get dictClearHistory => 'Borrar el historial';

  @override
  String get dictFavorites => 'Favoritas';

  @override
  String dictNoResults(String query) {
    return 'No encontramos «$query» en el diccionario.';
  }

  @override
  String get dictEmptyBody => 'Busca una palabra en cualquiera de tus dos idiomas.';

  @override
  String get dictFavorite => 'Añadir a favoritas';

  @override
  String get dictUnfavorite => 'Quitar de favoritas';

  @override
  String get dictAppearsIn => 'Aparece en';

  @override
  String dictOccurrences(int count) {
    String _temp0 = intl.Intl.pluralLogic(count, locale: localeName, other: '$count veces', one: '1 vez');
    return '$_temp0';
  }

  @override
  String get dictMeanings => 'Significados';

  @override
  String get quizTitle => 'Comprensión';

  @override
  String quizStart(int count) {
    return 'Comprueba lo que entendiste ($count preguntas)';
  }

  @override
  String quizLastResult(int correct, int total) {
    return 'Último intento: $correct de $total';
  }

  @override
  String quizQuestion(int current, int total) {
    return 'Pregunta $current de $total';
  }

  @override
  String get quizNext => 'Siguiente';

  @override
  String get quizPrevious => 'Anterior';

  @override
  String get quizSubmit => 'Enviar respuestas';

  @override
  String get quizSubmitting => 'Enviando…';

  @override
  String get quizTrue => 'Verdadero';

  @override
  String get quizFalse => 'Falso';

  @override
  String get quizChooseMany => 'Elige todas las que correspondan';

  @override
  String get quizBank => 'Palabras para completar';

  @override
  String quizBlankEmpty(int n) {
    return 'Hueco $n, vacío';
  }

  @override
  String quizBlankFilled(int n, String word) {
    return 'Hueco $n: $word. Toca para quitarla';
  }

  @override
  String get quizMatchHint => 'Elige la pareja de cada una';

  @override
  String get quizMatchChoose => 'Elegir';

  @override
  String get quizOrderHint => 'Ordénalas como ocurren en el texto';

  @override
  String get quizMoveUp => 'Subir';

  @override
  String get quizMoveDown => 'Bajar';

  @override
  String get quizShortHint => 'Responde con tus palabras, en el idioma que prefieras';

  @override
  String quizUnanswered(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Quedan $count preguntas sin responder: contarán como incorrectas.',
      one: 'Queda 1 pregunta sin responder: contará como incorrecta.',
    );
    return '$_temp0';
  }

  @override
  String get quizResultTitle => 'Tu resultado';

  @override
  String quizScore(int correct, int total) {
    return '$correct de $total correctas';
  }

  @override
  String quizPartial(int count) {
    return '$count en parte';
  }

  @override
  String quizPending(int count) {
    String _temp0 = intl.Intl.pluralLogic(count, locale: localeName, other: '$count respuestas se están corrigiendo…', one: '1 respuesta se está corrigiendo…');
    return '$_temp0';
  }

  @override
  String quizUngraded(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count respuestas abiertas para que las compares tú',
      one: '1 respuesta abierta para que la compares tú',
    );
    return '$_temp0';
  }

  @override
  String get quizStrengths => 'Lo que te salió bien';

  @override
  String get quizImprove => 'Para practicar';

  @override
  String get resultCORRECT => 'Correcta';

  @override
  String get resultPARTIAL => 'En parte';

  @override
  String get resultINCORRECT => 'Incorrecta';

  @override
  String get resultPENDING => 'Corrigiendo…';

  @override
  String get resultUNGRADED => 'Para autoevaluar';

  @override
  String get quizYourAnswer => 'Tu respuesta';

  @override
  String get quizSolution => 'Respuesta';

  @override
  String get quizModelAnswer => 'Respuesta modelo';

  @override
  String get quizNoAnswer => 'Sin responder';

  @override
  String get quizExplanation => 'Por qué';

  @override
  String get quizInText => 'En el texto';

  @override
  String get quizAssisted => 'Corrección asistida, con las oraciones en que se apoya';

  @override
  String get quizRule => 'Corrección automática';

  @override
  String get quizSelf => 'Autoevaluada';

  @override
  String get quizSelfPrompt => 'Compara tu respuesta con la modelo. ¿Cómo te fue?';

  @override
  String get quizRetry => 'Intentarlo otra vez';

  @override
  String get quizBackToReading => 'Volver a la lectura';

  @override
  String get skillMULTIPLE_CHOICE => 'Opciones';

  @override
  String get skillTRUE_FALSE => 'Verdadero o falso';

  @override
  String get skillCOMPLETION => 'Completar oraciones';

  @override
  String get skillMATCHING => 'Emparejar';

  @override
  String get skillORDERING => 'Ordenar los hechos';

  @override
  String get skillSHORT_ANSWER => 'Respuesta breve';

  @override
  String get skillVOCABULARY_IN_CONTEXT => 'Vocabulario en contexto';

  @override
  String get skillMAIN_IDEA => 'Idea principal';

  @override
  String get skillINFERENCE => 'Inferencia';

  @override
  String get skillDETAIL => 'Detalles del texto';

  @override
  String get skillunknown => 'Otras';

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
    String _temp0 = intl.Intl.pluralLogic(count, locale: localeName, other: '$count días', one: '1 día');
    return '$_temp0';
  }

  @override
  String get quizQueuedTitle => 'Respuestas guardadas';

  @override
  String get quizQueuedBody =>
      'No hay conexión: tus respuestas están en el dispositivo. Se enviarán y se corregirán al volver la red; el resultado lo da el servidor, no la app.';

  @override
  String get quizQueuedPending => 'Pendiente de evaluar';

  @override
  String get quizSeeResult => 'Ver el último resultado';

  @override
  String get downloadsTitle => 'Descargas';

  @override
  String get downloadAction => 'Descargar para leer sin conexión';

  @override
  String get downloadQueued => 'En espera…';

  @override
  String downloadProgress(int percent) {
    return 'Descargando… $percent %';
  }

  @override
  String get downloadDone => 'Descargada · disponible sin conexión';

  @override
  String get downloadFailed => 'La descarga falló';

  @override
  String get downloadWaitingWifi => 'Esperando una red Wi-Fi para el audio';

  @override
  String get downloadCancel => 'Cancelar la descarga';

  @override
  String get downloadRetry => 'Reintentar la descarga';

  @override
  String get downloadRemove => 'Quitar la descarga';

  @override
  String get downloadsEmpty => 'Nada descargado todavía';

  @override
  String get downloadsEmptyBody =>
      'En la ficha de una lectura, «Descargar» guarda su texto, sus traducciones, su audio y sus preguntas para leerla sin conexión.';

  @override
  String downloadsStorage(String size) {
    return 'Ocupan $size en el dispositivo';
  }

  @override
  String get downloadsWifiOnly => 'Descargar el audio solo con Wi-Fi';

  @override
  String get syncTitle => 'Sincronización';

  @override
  String syncPending(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count cambios pendientes de enviar',
      one: '1 cambio pendiente de enviar',
      zero: 'Todo está sincronizado',
    );
    return '$_temp0';
  }

  @override
  String get syncNow => 'Sincronizar ahora';

  @override
  String get syncing => 'Sincronizando…';

  @override
  String syncRejected(int count) {
    String _temp0 = intl.Intl.pluralLogic(count, locale: localeName, other: '$count cambios', one: '1 cambio');
    return 'El servidor no aceptó $_temp0';
  }

  @override
  String get syncDiscard => 'Descartar';

  @override
  String syncLast(String time) {
    return 'Última sincronización: $time';
  }

  @override
  String offlinePending(int count) {
    return 'Sin conexión · $count cambios esperan para enviarse';
  }

  @override
  String get progressTitle => 'Progreso';

  @override
  String get progressToday => 'Hoy';

  @override
  String progressTodayMinutes(int minutes, int goal) {
    return '$minutes de $goal min';
  }

  @override
  String get progressGoalMet => 'Meta de hoy cumplida. ¡Bien leído!';

  @override
  String get progressGoalOpen => 'Unos minutos bastan. Lo que leas hoy suma.';

  @override
  String get progressWeek => 'Esta semana';

  @override
  String progressWeekDays(int active, int target) {
    return '$active de $target días con lectura';
  }

  @override
  String get progressWeekMet => 'Semana cumplida';

  @override
  String progressStreak(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count semanas cumplidas seguidas',
      one: '1 semana cumplida seguida',
      zero: 'Tu primera semana cumplida está a la vuelta',
    );
    return '$_temp0';
  }

  @override
  String progressBest(int count) {
    return 'Tu mejor racha: $count';
  }

  @override
  String get progressLast28 => 'Los últimos 28 días';

  @override
  String progressDayLabel(String date, int minutes) {
    return '$date: $minutes min';
  }

  @override
  String progressDayGoal(String date, int minutes) {
    return '$date: $minutes min, meta cumplida';
  }

  @override
  String get progressReading => 'Lectura';

  @override
  String get progressVocabulary => 'Vocabulario';

  @override
  String get progressComprehension => 'Comprensión';

  @override
  String get metricStarted => 'Empezadas';

  @override
  String get metricCompleted => 'Terminadas';

  @override
  String get metricMinutes => 'Minutos leídos';

  @override
  String get metricWordsRead => 'Palabras leídas';

  @override
  String get metricMinutesWeek => 'Minutos esta semana';

  @override
  String get metricCompletedWeek => 'Terminadas esta semana';

  @override
  String get metricEncountered => 'Encontradas';

  @override
  String get metricSaved => 'Guardadas';

  @override
  String get metricLearning => 'Aprendiendo';

  @override
  String get metricMastered => 'Dominadas';

  @override
  String get metricDue => 'Para repasar';

  @override
  String get metricAnswered => 'Preguntas respondidas';

  @override
  String get metricAverage => 'Acierto medio';

  @override
  String get metricEstimated => 'estimado';

  @override
  String get metricEstimatedHint => '≈ estimado: se infiere de lo que lees y repasas; lo demás está contado.';

  @override
  String get progressGrowth => 'Palabras guardadas por semana';

  @override
  String get progressByType => 'Por tipo de pregunta';

  @override
  String get progressNoAnswers => 'Cuando respondas preguntas de comprensión, verás aquí cómo entiendes.';

  @override
  String get progressLevel => 'Tu nivel';

  @override
  String progressLevelEstimate(String level) {
    return '$level · estimado';
  }

  @override
  String get levelSignalUP => 'Tus respuestas sugieren que podrías probar lecturas un poco más exigentes.';

  @override
  String get levelSignalSTEADY => 'Tus lecturas encajan con tu nivel.';

  @override
  String get levelSignalDOWN => 'Quizá te vengan mejor lecturas un poco más sencillas por ahora.';

  @override
  String get levelSignalunknown => 'Aún no hay suficientes respuestas para decir más.';

  @override
  String get progressAchievements => 'Logros';

  @override
  String get progressSeeAll => 'Ver todos';

  @override
  String get progressWeeklySummary => 'Resumen semanal';

  @override
  String get progressGoals => 'Metas';

  @override
  String get progressEmpty => 'Tu progreso empieza con tu primera lectura';

  @override
  String get progressEmptyBody => 'Lee unos minutos y aquí verás tu semana, tus palabras y lo que entiendes. Sin castigos por los días sin leer.';

  @override
  String get goalsDaily => 'Minutos al día';

  @override
  String get goalsWeekly => 'Días por semana';

  @override
  String get goalsWeeklyHint => 'La racha cuenta semanas cumplidas, no días: un día sin leer no rompe nada.';

  @override
  String get goalsWeeklySummary => 'Mostrar un resumen de la semana';

  @override
  String get goalsReminder => 'Recordatorio diario';

  @override
  String get goalsReminderHint => 'Un aviso al día, a la hora que elijas. Nada más.';

  @override
  String goalsReminderAt(String time) {
    return 'A las $time';
  }

  @override
  String get goalsReminderDenied => 'Sin permiso para notificaciones: actívalo en los ajustes del sistema si quieres el recordatorio.';

  @override
  String get goalsReviewReminder => 'Recordarme repasar vocabulario';

  @override
  String get goalsSaved => 'Metas guardadas';

  @override
  String get reminderReadTitle => 'Un ratito de lectura';

  @override
  String get reminderReadBody => 'Tu próxima historia te espera en Lesen.';

  @override
  String get reminderReviewTitle => 'Palabras para repasar';

  @override
  String get reminderReviewBody => 'Unos minutos de repaso y vuelven cuando toca.';

  @override
  String weeklyRange(String start, String end) {
    return 'Del $start al $end';
  }

  @override
  String get weeklyPrevious => 'Semana anterior';

  @override
  String get weeklyNext => 'Semana siguiente';

  @override
  String weeklyMet(int active, int target) {
    return 'Semana cumplida: $active de $target días.';
  }

  @override
  String weeklyProgress(int active, int target) {
    return 'Llevas $active de $target días.';
  }

  @override
  String get weeklyQuiet => 'Una semana tranquila. La siguiente es nueva.';

  @override
  String get metricReadingsCompleted => 'Lecturas terminadas';

  @override
  String get metricWordsSaved => 'Palabras guardadas';

  @override
  String get metricWordsReviewed => 'Palabras repasadas';

  @override
  String get metricAssessments => 'Evaluaciones';

  @override
  String achievementProgress(int value, int threshold) {
    return '$value de $threshold';
  }

  @override
  String achievementEarned(String date) {
    return 'Conseguido el $date';
  }

  @override
  String get achFIRST_READING => 'Primera lectura terminada';

  @override
  String get achREADINGS_5 => '5 lecturas terminadas';

  @override
  String get achREADINGS_20 => '20 lecturas terminadas';

  @override
  String get achFIRST_HOUR => 'Tu primera hora leyendo';

  @override
  String get achTEN_HOURS => '10 horas leyendo';

  @override
  String get achFIRST_WORD => 'Primera palabra guardada';

  @override
  String get achWORDS_50 => '50 palabras guardadas';

  @override
  String get achFIRST_REVIEW => 'Primer repaso';

  @override
  String get achREVIEWS_100 => '100 repasos';

  @override
  String get achFIRST_ASSESSMENT => 'Primeras preguntas respondidas';

  @override
  String get achDAYS_10 => '10 días con lectura';

  @override
  String get achFIRST_WEEK => 'Primera semana cumplida';

  @override
  String get achSTREAK_4 => '4 semanas cumplidas seguidas';

  @override
  String get achUnknown => 'Logro';

  @override
  String get listsTitle => 'Mis listas';

  @override
  String get listsNew => 'Nueva lista';

  @override
  String get listsName => 'Nombre de la lista';

  @override
  String get listsCreate => 'Crear';

  @override
  String get listsAddTo => 'Añadir a una lista';

  @override
  String get listsEmpty => 'Aún no tienes listas. Crea una para agrupar lecturas a tu manera.';

  @override
  String listsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(count, locale: localeName, other: '$count lecturas', one: '1 lectura', zero: 'Vacía');
    return '$_temp0';
  }

  @override
  String get listsDuplicate => 'Ya tienes una lista con ese nombre.';

  @override
  String get listsDelete => 'Borrar la lista';

  @override
  String listsDeleteConfirm(String name) {
    return '¿Borrar la lista «$name»? Las lecturas no se borran.';
  }

  @override
  String get listsEmptyList => 'Esta lista está vacía. Añade lecturas desde su ficha.';

  @override
  String get signOutPendingTitle => 'Hay cambios sin enviar';

  @override
  String signOutPendingBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count cambios no han llegado aún al servidor.',
      one: '1 cambio no ha llegado aún al servidor.',
    );
    return '$_temp0 Si cierras sesión ahora, se perderán. Conéctate para sincronizar antes.';
  }

  @override
  String get signOutAnyway => 'Cerrar sesión igualmente';
}
