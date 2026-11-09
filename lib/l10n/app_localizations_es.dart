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
  String get readerComingSoon => 'El lector inmersivo llega en la próxima versión de la app.';

  @override
  String get libraryComingSoon => 'Aquí verás lo que estás leyendo, lo que guardaste y lo que terminaste.';

  @override
  String get vocabularyComingSoon => 'Aquí vivirán las palabras que guardes al leer, listas para repasar.';

  @override
  String get progressComingSoon => 'Aquí verás tu progreso: lo medido y lo estimado, sin castigos.';

  @override
  String get comingSoonTitle => 'Muy pronto';

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
}
