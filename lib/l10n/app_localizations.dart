import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[Locale('en'), Locale('es')];

  /// No description provided for @appName.
  ///
  /// In es, this message translates to:
  /// **'Lesen'**
  String get appName;

  /// No description provided for @commonRetry.
  ///
  /// In es, this message translates to:
  /// **'Reintentar'**
  String get commonRetry;

  /// No description provided for @commonBack.
  ///
  /// In es, this message translates to:
  /// **'Atrás'**
  String get commonBack;

  /// No description provided for @commonContinue.
  ///
  /// In es, this message translates to:
  /// **'Continuar'**
  String get commonContinue;

  /// No description provided for @commonCancel.
  ///
  /// In es, this message translates to:
  /// **'Cancelar'**
  String get commonCancel;

  /// No description provided for @commonSave.
  ///
  /// In es, this message translates to:
  /// **'Guardar'**
  String get commonSave;

  /// No description provided for @commonClose.
  ///
  /// In es, this message translates to:
  /// **'Cerrar'**
  String get commonClose;

  /// No description provided for @commonSeeAll.
  ///
  /// In es, this message translates to:
  /// **'Ver todo'**
  String get commonSeeAll;

  /// No description provided for @errorOffline.
  ///
  /// In es, this message translates to:
  /// **'Sin conexión. Lo que ya está en el dispositivo sigue disponible.'**
  String get errorOffline;

  /// No description provided for @errorTimeout.
  ///
  /// In es, this message translates to:
  /// **'El servidor tarda en responder.'**
  String get errorTimeout;

  /// No description provided for @errorForbidden.
  ///
  /// In es, this message translates to:
  /// **'Tu cuenta no tiene acceso a esto.'**
  String get errorForbidden;

  /// No description provided for @errorNotFound.
  ///
  /// In es, this message translates to:
  /// **'No encontramos lo que buscas.'**
  String get errorNotFound;

  /// No description provided for @errorServer.
  ///
  /// In es, this message translates to:
  /// **'Algo falló en el servidor. Inténtalo de nuevo en un momento.'**
  String get errorServer;

  /// No description provided for @errorContract.
  ///
  /// In es, this message translates to:
  /// **'La respuesta del servidor no es la esperada. Puede que haga falta actualizar la app.'**
  String get errorContract;

  /// No description provided for @errorGeneric.
  ///
  /// In es, this message translates to:
  /// **'Algo no salió bien.'**
  String get errorGeneric;

  /// No description provided for @offlineBanner.
  ///
  /// In es, this message translates to:
  /// **'Sin conexión: puedes seguir con lo que ya está en el dispositivo.'**
  String get offlineBanner;

  /// No description provided for @loginTitle.
  ///
  /// In es, this message translates to:
  /// **'Aprende un idioma leyendo'**
  String get loginTitle;

  /// No description provided for @loginLead.
  ///
  /// In es, this message translates to:
  /// **'Historias a tu nivel, con cada palabra a un toque.'**
  String get loginLead;

  /// No description provided for @loginEmail.
  ///
  /// In es, this message translates to:
  /// **'Correo electrónico'**
  String get loginEmail;

  /// No description provided for @loginPassword.
  ///
  /// In es, this message translates to:
  /// **'Contraseña'**
  String get loginPassword;

  /// No description provided for @loginShowPassword.
  ///
  /// In es, this message translates to:
  /// **'Mostrar contraseña'**
  String get loginShowPassword;

  /// No description provided for @loginHidePassword.
  ///
  /// In es, this message translates to:
  /// **'Ocultar contraseña'**
  String get loginHidePassword;

  /// No description provided for @loginSubmit.
  ///
  /// In es, this message translates to:
  /// **'Entrar'**
  String get loginSubmit;

  /// No description provided for @loginInvalid.
  ///
  /// In es, this message translates to:
  /// **'El correo o la contraseña no son correctos.'**
  String get loginInvalid;

  /// No description provided for @loginTooMany.
  ///
  /// In es, this message translates to:
  /// **'Demasiados intentos. Espera un momento antes de volver a probar.'**
  String get loginTooMany;

  /// No description provided for @loginEmailRequired.
  ///
  /// In es, this message translates to:
  /// **'Escribe tu correo.'**
  String get loginEmailRequired;

  /// No description provided for @loginPasswordRequired.
  ///
  /// In es, this message translates to:
  /// **'Escribe tu contraseña.'**
  String get loginPasswordRequired;

  /// No description provided for @loginNoAccount.
  ///
  /// In es, this message translates to:
  /// **'Tu cuenta la crea quien administra Lesen en tu organización.'**
  String get loginNoAccount;

  /// No description provided for @sessionExpired.
  ///
  /// In es, this message translates to:
  /// **'Tu sesión terminó. Vuelve a entrar; lo que tenías pendiente se conserva.'**
  String get sessionExpired;

  /// No description provided for @navDiscover.
  ///
  /// In es, this message translates to:
  /// **'Descubrir'**
  String get navDiscover;

  /// No description provided for @navLibrary.
  ///
  /// In es, this message translates to:
  /// **'Mis lecturas'**
  String get navLibrary;

  /// No description provided for @navVocabulary.
  ///
  /// In es, this message translates to:
  /// **'Vocabulario'**
  String get navVocabulary;

  /// No description provided for @navProgress.
  ///
  /// In es, this message translates to:
  /// **'Progreso'**
  String get navProgress;

  /// No description provided for @navProfile.
  ///
  /// In es, this message translates to:
  /// **'Perfil'**
  String get navProfile;

  /// No description provided for @navSearch.
  ///
  /// In es, this message translates to:
  /// **'Buscar'**
  String get navSearch;

  /// No description provided for @onboardingStep.
  ///
  /// In es, this message translates to:
  /// **'Paso {current} de {total}'**
  String onboardingStep(int current, int total);

  /// No description provided for @onboardingFinish.
  ///
  /// In es, this message translates to:
  /// **'Empezar a leer'**
  String get onboardingFinish;

  /// No description provided for @onboardingSaving.
  ///
  /// In es, this message translates to:
  /// **'Guardando…'**
  String get onboardingSaving;

  /// No description provided for @onboardingError.
  ///
  /// In es, this message translates to:
  /// **'No pudimos guardar tu perfil. Inténtalo de nuevo.'**
  String get onboardingError;

  /// No description provided for @onboardingWelcomeEyebrow.
  ///
  /// In es, this message translates to:
  /// **'Hola'**
  String get onboardingWelcomeEyebrow;

  /// No description provided for @onboardingWelcomeHeading.
  ///
  /// In es, this message translates to:
  /// **'Aprende un idioma leyendo historias que te gustan'**
  String get onboardingWelcomeHeading;

  /// No description provided for @onboardingWelcomeBody.
  ///
  /// In es, this message translates to:
  /// **'Lee, toca cualquier palabra que no conozcas y guárdala para después. Primero, ¿en qué idioma quieres usar la app?'**
  String get onboardingWelcomeBody;

  /// No description provided for @onboardingTargetHeading.
  ///
  /// In es, this message translates to:
  /// **'¿Qué idioma quieres leer?'**
  String get onboardingTargetHeading;

  /// No description provided for @onboardingTargetBody.
  ///
  /// In es, this message translates to:
  /// **'Podrás cambiarlo más adelante en tu perfil.'**
  String get onboardingTargetBody;

  /// No description provided for @onboardingLevelHeading.
  ///
  /// In es, this message translates to:
  /// **'¿Cómo lees en {language} hoy?'**
  String onboardingLevelHeading(String language);

  /// No description provided for @onboardingLevelBody.
  ///
  /// In es, this message translates to:
  /// **'Elige lo que mejor te describa. Puedes cambiarlo cuando quieras.'**
  String get onboardingLevelBody;

  /// No description provided for @onboardingLevelUnsure.
  ///
  /// In es, this message translates to:
  /// **'No estoy segura o seguro'**
  String get onboardingLevelUnsure;

  /// No description provided for @onboardingLevelUnsureBody.
  ///
  /// In es, this message translates to:
  /// **'Empezamos por A2 y ajustas sobre la marcha. Es una estimación, no una nota.'**
  String get onboardingLevelUnsureBody;

  /// No description provided for @onboardingInterestsHeading.
  ///
  /// In es, this message translates to:
  /// **'¿Qué te gustaría leer?'**
  String get onboardingInterestsHeading;

  /// No description provided for @onboardingInterestsBody.
  ///
  /// In es, this message translates to:
  /// **'Elige lo que te llame. Así recomendamos mejor.'**
  String get onboardingInterestsBody;

  /// No description provided for @onboardingGoals.
  ///
  /// In es, this message translates to:
  /// **'Para qué aprendes'**
  String get onboardingGoals;

  /// No description provided for @onboardingTopics.
  ///
  /// In es, this message translates to:
  /// **'Temas'**
  String get onboardingTopics;

  /// No description provided for @onboardingHabitHeading.
  ///
  /// In es, this message translates to:
  /// **'Un ritmo que te siente bien'**
  String get onboardingHabitHeading;

  /// No description provided for @onboardingHabitBody.
  ///
  /// In es, this message translates to:
  /// **'Unos minutos al día bastan. Sin rachas que castiguen: si un día no lees, no pasa nada.'**
  String get onboardingHabitBody;

  /// No description provided for @onboardingDaily.
  ///
  /// In es, this message translates to:
  /// **'Minutos al día'**
  String get onboardingDaily;

  /// No description provided for @onboardingDifficulty.
  ///
  /// In es, this message translates to:
  /// **'Dificultad de las lecturas'**
  String get onboardingDifficulty;

  /// No description provided for @minutesShort.
  ///
  /// In es, this message translates to:
  /// **'{count} min'**
  String minutesShort(int count);

  /// No description provided for @minutesRead.
  ///
  /// In es, this message translates to:
  /// **'{count, plural, =1{1 minuto de lectura} other{{count} minutos de lectura}}'**
  String minutesRead(int count);

  /// No description provided for @wordsCount.
  ///
  /// In es, this message translates to:
  /// **'{count} palabras'**
  String wordsCount(int count);

  /// No description provided for @paragraphsCount.
  ///
  /// In es, this message translates to:
  /// **'{count, plural, =1{1 párrafo} other{{count} párrafos}}'**
  String paragraphsCount(int count);

  /// No description provided for @readingsCount.
  ///
  /// In es, this message translates to:
  /// **'{count, plural, =1{1 lectura} other{{count} lecturas}}'**
  String readingsCount(int count);

  /// No description provided for @readersThisWeek.
  ///
  /// In es, this message translates to:
  /// **'{count, plural, =1{1 persona la terminó} other{{count} personas la terminaron}}'**
  String readersThisWeek(int count);

  /// No description provided for @levelA1.
  ///
  /// In es, this message translates to:
  /// **'Entiendo palabras sueltas y frases muy básicas.'**
  String get levelA1;

  /// No description provided for @levelA2.
  ///
  /// In es, this message translates to:
  /// **'Sigo textos cortos y sencillos sobre temas cotidianos.'**
  String get levelA2;

  /// No description provided for @levelB1.
  ///
  /// In es, this message translates to:
  /// **'Entiendo lo esencial de textos claros sobre temas conocidos.'**
  String get levelB1;

  /// No description provided for @levelB2.
  ///
  /// In es, this message translates to:
  /// **'Leo artículos y relatos con bastante soltura.'**
  String get levelB2;

  /// No description provided for @levelC1.
  ///
  /// In es, this message translates to:
  /// **'Leo textos largos y exigentes y capto lo implícito.'**
  String get levelC1;

  /// No description provided for @levelC2.
  ///
  /// In es, this message translates to:
  /// **'Leo casi cualquier cosa con facilidad.'**
  String get levelC2;

  /// No description provided for @goalTRAVEL.
  ///
  /// In es, this message translates to:
  /// **'Viajar'**
  String get goalTRAVEL;

  /// No description provided for @goalWORK.
  ///
  /// In es, this message translates to:
  /// **'Trabajo'**
  String get goalWORK;

  /// No description provided for @goalSTUDY.
  ///
  /// In es, this message translates to:
  /// **'Estudios'**
  String get goalSTUDY;

  /// No description provided for @goalCULTURE.
  ///
  /// In es, this message translates to:
  /// **'Cultura'**
  String get goalCULTURE;

  /// No description provided for @goalFAMILY.
  ///
  /// In es, this message translates to:
  /// **'Familia y amistades'**
  String get goalFAMILY;

  /// No description provided for @goalFUN.
  ///
  /// In es, this message translates to:
  /// **'Por gusto'**
  String get goalFUN;

  /// No description provided for @goalEXAM.
  ///
  /// In es, this message translates to:
  /// **'Un examen'**
  String get goalEXAM;

  /// No description provided for @difficultyCOMFORTABLE.
  ///
  /// In es, this message translates to:
  /// **'Cómoda'**
  String get difficultyCOMFORTABLE;

  /// No description provided for @difficultyBALANCED.
  ///
  /// In es, this message translates to:
  /// **'Equilibrada'**
  String get difficultyBALANCED;

  /// No description provided for @difficultyCHALLENGING.
  ///
  /// In es, this message translates to:
  /// **'Un reto'**
  String get difficultyCHALLENGING;

  /// No description provided for @difficultyCOMFORTABLEBody.
  ///
  /// In es, this message translates to:
  /// **'Lecturas que entiendes casi enteras.'**
  String get difficultyCOMFORTABLEBody;

  /// No description provided for @difficultyBALANCEDBody.
  ///
  /// In es, this message translates to:
  /// **'Algunas palabras nuevas en cada párrafo.'**
  String get difficultyBALANCEDBody;

  /// No description provided for @difficultyCHALLENGINGBody.
  ///
  /// In es, this message translates to:
  /// **'Un poco por encima de tu nivel.'**
  String get difficultyCHALLENGINGBody;

  /// No description provided for @greetingMorning.
  ///
  /// In es, this message translates to:
  /// **'Buenos días'**
  String get greetingMorning;

  /// No description provided for @greetingAfternoon.
  ///
  /// In es, this message translates to:
  /// **'Buenas tardes'**
  String get greetingAfternoon;

  /// No description provided for @greetingEvening.
  ///
  /// In es, this message translates to:
  /// **'Buenas noches'**
  String get greetingEvening;

  /// No description provided for @greetingNamed.
  ///
  /// In es, this message translates to:
  /// **'{greeting}, {name}'**
  String greetingNamed(String greeting, String name);

  /// No description provided for @discoverLead.
  ///
  /// In es, this message translates to:
  /// **'Hoy toca leer en {language}. Tu meta: {minutes} minutos, a tu ritmo.'**
  String discoverLead(String language, int minutes);

  /// No description provided for @discoverFeatured.
  ///
  /// In es, this message translates to:
  /// **'Destacada'**
  String get discoverFeatured;

  /// No description provided for @discoverContinue.
  ///
  /// In es, this message translates to:
  /// **'Sigue donde lo dejaste'**
  String get discoverContinue;

  /// No description provided for @discoverRecommended.
  ///
  /// In es, this message translates to:
  /// **'Para ti'**
  String get discoverRecommended;

  /// No description provided for @discoverRecommendedLead.
  ///
  /// In es, this message translates to:
  /// **'Elegidas por tu nivel y lo que te interesa.'**
  String get discoverRecommendedLead;

  /// No description provided for @discoverThisWeek.
  ///
  /// In es, this message translates to:
  /// **'Lo que se lee esta semana'**
  String get discoverThisWeek;

  /// No description provided for @discoverFresh.
  ///
  /// In es, this message translates to:
  /// **'Recién publicadas'**
  String get discoverFresh;

  /// No description provided for @discoverCollections.
  ///
  /// In es, this message translates to:
  /// **'Colecciones'**
  String get discoverCollections;

  /// No description provided for @discoverTopics.
  ///
  /// In es, this message translates to:
  /// **'Explora por temas'**
  String get discoverTopics;

  /// No description provided for @discoverLevels.
  ///
  /// In es, this message translates to:
  /// **'Explora por nivel'**
  String get discoverLevels;

  /// No description provided for @discoverCatalog.
  ///
  /// In es, this message translates to:
  /// **'Ver todo el catálogo'**
  String get discoverCatalog;

  /// No description provided for @discoverEmpty.
  ///
  /// In es, this message translates to:
  /// **'Aún no hay lecturas en {language}'**
  String discoverEmpty(String language);

  /// No description provided for @discoverEmptyBody.
  ///
  /// In es, this message translates to:
  /// **'Pronto llegarán. Mientras, mira el catálogo en otros idiomas.'**
  String get discoverEmptyBody;

  /// No description provided for @reasonLEVEL.
  ///
  /// In es, this message translates to:
  /// **'A tu nivel'**
  String get reasonLEVEL;

  /// No description provided for @reasonCOMPREHENSION.
  ///
  /// In es, this message translates to:
  /// **'Por cómo entiendes'**
  String get reasonCOMPREHENSION;

  /// No description provided for @reasonTOPIC.
  ///
  /// In es, this message translates to:
  /// **'De tus temas'**
  String get reasonTOPIC;

  /// No description provided for @reasonHISTORY.
  ///
  /// In es, this message translates to:
  /// **'Como lo que leíste'**
  String get reasonHISTORY;

  /// No description provided for @reasonNEW.
  ///
  /// In es, this message translates to:
  /// **'Nueva'**
  String get reasonNEW;

  /// No description provided for @reasonTRENDING.
  ///
  /// In es, this message translates to:
  /// **'Se lee esta semana'**
  String get reasonTRENDING;

  /// No description provided for @catalogTitle.
  ///
  /// In es, this message translates to:
  /// **'Catálogo'**
  String get catalogTitle;

  /// No description provided for @catalogSearch.
  ///
  /// In es, this message translates to:
  /// **'Buscar lecturas'**
  String get catalogSearch;

  /// No description provided for @catalogSearchHint.
  ///
  /// In es, this message translates to:
  /// **'Título, tema o idea…'**
  String get catalogSearchHint;

  /// No description provided for @catalogLanguage.
  ///
  /// In es, this message translates to:
  /// **'Idioma'**
  String get catalogLanguage;

  /// No description provided for @catalogAllLanguages.
  ///
  /// In es, this message translates to:
  /// **'Todos'**
  String get catalogAllLanguages;

  /// No description provided for @catalogLevel.
  ///
  /// In es, this message translates to:
  /// **'Nivel'**
  String get catalogLevel;

  /// No description provided for @catalogTopic.
  ///
  /// In es, this message translates to:
  /// **'Tema'**
  String get catalogTopic;

  /// No description provided for @catalogAllTopics.
  ///
  /// In es, this message translates to:
  /// **'Todos los temas'**
  String get catalogAllTopics;

  /// No description provided for @catalogDuration.
  ///
  /// In es, this message translates to:
  /// **'Duración'**
  String get catalogDuration;

  /// No description provided for @catalogDurationShort.
  ///
  /// In es, this message translates to:
  /// **'Hasta 3 min'**
  String get catalogDurationShort;

  /// No description provided for @catalogDurationMedium.
  ///
  /// In es, this message translates to:
  /// **'4–6 min'**
  String get catalogDurationMedium;

  /// No description provided for @catalogDurationLong.
  ///
  /// In es, this message translates to:
  /// **'7 min o más'**
  String get catalogDurationLong;

  /// No description provided for @catalogSort.
  ///
  /// In es, this message translates to:
  /// **'Ordenar'**
  String get catalogSort;

  /// No description provided for @sortRECENT.
  ///
  /// In es, this message translates to:
  /// **'Más recientes'**
  String get sortRECENT;

  /// No description provided for @sortPOPULAR.
  ///
  /// In es, this message translates to:
  /// **'Más leídas'**
  String get sortPOPULAR;

  /// No description provided for @sortLEVEL.
  ///
  /// In es, this message translates to:
  /// **'Por nivel'**
  String get sortLEVEL;

  /// No description provided for @sortDURATION.
  ///
  /// In es, this message translates to:
  /// **'Más cortas primero'**
  String get sortDURATION;

  /// No description provided for @sortTITLE.
  ///
  /// In es, this message translates to:
  /// **'Por título'**
  String get sortTITLE;

  /// No description provided for @catalogFilters.
  ///
  /// In es, this message translates to:
  /// **'Filtros'**
  String get catalogFilters;

  /// No description provided for @catalogFiltersCount.
  ///
  /// In es, this message translates to:
  /// **'Filtros ({count})'**
  String catalogFiltersCount(int count);

  /// No description provided for @catalogClear.
  ///
  /// In es, this message translates to:
  /// **'Quitar filtros'**
  String get catalogClear;

  /// No description provided for @catalogApply.
  ///
  /// In es, this message translates to:
  /// **'Ver resultados'**
  String get catalogApply;

  /// No description provided for @catalogResults.
  ///
  /// In es, this message translates to:
  /// **'{count, plural, =0{Ninguna lectura} =1{1 lectura} other{{count} lecturas}}'**
  String catalogResults(int count);

  /// No description provided for @catalogEmpty.
  ///
  /// In es, this message translates to:
  /// **'Nada coincide con estos filtros'**
  String get catalogEmpty;

  /// No description provided for @catalogEmptyBody.
  ///
  /// In es, this message translates to:
  /// **'Prueba con otro nivel o quita algún filtro.'**
  String get catalogEmptyBody;

  /// No description provided for @statusNOT_STARTED.
  ///
  /// In es, this message translates to:
  /// **'Sin empezar'**
  String get statusNOT_STARTED;

  /// No description provided for @statusIN_PROGRESS.
  ///
  /// In es, this message translates to:
  /// **'En curso'**
  String get statusIN_PROGRESS;

  /// No description provided for @statusCOMPLETED.
  ///
  /// In es, this message translates to:
  /// **'Terminada'**
  String get statusCOMPLETED;

  /// No description provided for @statusBOOKMARKED.
  ///
  /// In es, this message translates to:
  /// **'Guardada'**
  String get statusBOOKMARKED;

  /// No description provided for @cardProgress.
  ///
  /// In es, this message translates to:
  /// **'{percent} % leído'**
  String cardProgress(int percent);

  /// No description provided for @cardCompleted.
  ///
  /// In es, this message translates to:
  /// **'Terminada'**
  String get cardCompleted;

  /// No description provided for @cardSemantics.
  ///
  /// In es, this message translates to:
  /// **'{title}. {language}, nivel {level}, {minutes} minutos.'**
  String cardSemantics(String title, String language, String level, int minutes);

  /// No description provided for @detailStart.
  ///
  /// In es, this message translates to:
  /// **'Empezar a leer'**
  String get detailStart;

  /// No description provided for @detailContinue.
  ///
  /// In es, this message translates to:
  /// **'Seguir leyendo'**
  String get detailContinue;

  /// No description provided for @detailReadAgain.
  ///
  /// In es, this message translates to:
  /// **'Leer otra vez'**
  String get detailReadAgain;

  /// No description provided for @detailBookmark.
  ///
  /// In es, this message translates to:
  /// **'Guardar para después'**
  String get detailBookmark;

  /// No description provided for @detailBookmarked.
  ///
  /// In es, this message translates to:
  /// **'Guardada'**
  String get detailBookmarked;

  /// No description provided for @detailRelated.
  ///
  /// In es, this message translates to:
  /// **'Si te gusta esta, prueba'**
  String get detailRelated;

  /// No description provided for @detailInCollections.
  ///
  /// In es, this message translates to:
  /// **'En las colecciones'**
  String get detailInCollections;

  /// No description provided for @detailReaders.
  ///
  /// In es, this message translates to:
  /// **'{count, plural, =0{Aún nadie la abrió} =1{1 persona la abrió} other{{count} personas la abrieron}}'**
  String detailReaders(int count);

  /// No description provided for @profileTitle.
  ///
  /// In es, this message translates to:
  /// **'Tu perfil'**
  String get profileTitle;

  /// No description provided for @profileInterface.
  ///
  /// In es, this message translates to:
  /// **'Idioma de la app'**
  String get profileInterface;

  /// No description provided for @profileTarget.
  ///
  /// In es, this message translates to:
  /// **'Idioma que lees'**
  String get profileTarget;

  /// No description provided for @profileLevel.
  ///
  /// In es, this message translates to:
  /// **'Nivel'**
  String get profileLevel;

  /// No description provided for @profileLevelEstimated.
  ///
  /// In es, this message translates to:
  /// **'estimado'**
  String get profileLevelEstimated;

  /// No description provided for @profileDaily.
  ///
  /// In es, this message translates to:
  /// **'Meta diaria'**
  String get profileDaily;

  /// No description provided for @profileEdit.
  ///
  /// In es, this message translates to:
  /// **'Editar preferencias'**
  String get profileEdit;

  /// No description provided for @profileSignOut.
  ///
  /// In es, this message translates to:
  /// **'Cerrar sesión'**
  String get profileSignOut;

  /// No description provided for @profileSignedInAs.
  ///
  /// In es, this message translates to:
  /// **'Has entrado como {email}'**
  String profileSignedInAs(String email);

  /// No description provided for @profileAbout.
  ///
  /// In es, this message translates to:
  /// **'Acerca de Lesen'**
  String get profileAbout;

  /// No description provided for @profileVersion.
  ///
  /// In es, this message translates to:
  /// **'Versión {version} · {env}'**
  String profileVersion(String version, String env);

  /// No description provided for @catalogStatus.
  ///
  /// In es, this message translates to:
  /// **'Estado'**
  String get catalogStatus;

  /// No description provided for @detailBookmarkFailed.
  ///
  /// In es, this message translates to:
  /// **'No pudimos guardar el cambio. Inténtalo de nuevo.'**
  String get detailBookmarkFailed;

  /// No description provided for @profileTopics.
  ///
  /// In es, this message translates to:
  /// **'Temas'**
  String get profileTopics;

  /// No description provided for @profileGoals.
  ///
  /// In es, this message translates to:
  /// **'Metas'**
  String get profileGoals;

  /// No description provided for @profileDifficulty.
  ///
  /// In es, this message translates to:
  /// **'Dificultad'**
  String get profileDifficulty;

  /// No description provided for @readerBack.
  ///
  /// In es, this message translates to:
  /// **'Salir de la lectura'**
  String get readerBack;

  /// No description provided for @readerSettings.
  ///
  /// In es, this message translates to:
  /// **'Texto y ayudas'**
  String get readerSettings;

  /// No description provided for @readerNotes.
  ///
  /// In es, this message translates to:
  /// **'Notas'**
  String get readerNotes;

  /// No description provided for @readerFocus.
  ///
  /// In es, this message translates to:
  /// **'Modo sin distracciones'**
  String get readerFocus;

  /// No description provided for @readerFocusExit.
  ///
  /// In es, this message translates to:
  /// **'Mostrar los controles'**
  String get readerFocusExit;

  /// No description provided for @readerRemaining.
  ///
  /// In es, this message translates to:
  /// **'Quedan {count} min'**
  String readerRemaining(int count);

  /// No description provided for @readerAlmostDone.
  ///
  /// In es, this message translates to:
  /// **'Casi terminas'**
  String get readerAlmostDone;

  /// No description provided for @readerProgress.
  ///
  /// In es, this message translates to:
  /// **'Avance de la lectura: {percent} %'**
  String readerProgress(int percent);

  /// No description provided for @readerHint.
  ///
  /// In es, this message translates to:
  /// **'Toca cualquier palabra para ver qué significa.'**
  String get readerHint;

  /// No description provided for @readerOldVersion.
  ///
  /// In es, this message translates to:
  /// **'Estás leyendo la versión {version}, la que empezaste. Hay una versión más reciente.'**
  String readerOldVersion(int version);

  /// No description provided for @readerTranslateParagraph.
  ///
  /// In es, this message translates to:
  /// **'Traducir el párrafo'**
  String get readerTranslateParagraph;

  /// No description provided for @readerHideParagraph.
  ///
  /// In es, this message translates to:
  /// **'Ocultar la traducción'**
  String get readerHideParagraph;

  /// No description provided for @readerNoParagraphTranslation.
  ///
  /// In es, this message translates to:
  /// **'Este párrafo aún no tiene traducción.'**
  String get readerNoParagraphTranslation;

  /// No description provided for @readerSavePending.
  ///
  /// In es, this message translates to:
  /// **'Guardado en el dispositivo; se enviará al volver la conexión.'**
  String get readerSavePending;

  /// No description provided for @readerFinish.
  ///
  /// In es, this message translates to:
  /// **'Terminé de leer'**
  String get readerFinish;

  /// No description provided for @readerFinishing.
  ///
  /// In es, this message translates to:
  /// **'Guardando…'**
  String get readerFinishing;

  /// No description provided for @wordLoading.
  ///
  /// In es, this message translates to:
  /// **'Buscando la palabra…'**
  String get wordLoading;

  /// No description provided for @wordTitle.
  ///
  /// In es, this message translates to:
  /// **'La palabra «{word}»'**
  String wordTitle(String word);

  /// No description provided for @wordNoEntry.
  ///
  /// In es, this message translates to:
  /// **'Todavía no tenemos esta palabra en el diccionario.'**
  String get wordNoEntry;

  /// No description provided for @wordNoEntryBody.
  ///
  /// In es, this message translates to:
  /// **'Preferimos decirlo antes que inventar una traducción.'**
  String get wordNoEntryBody;

  /// No description provided for @wordFormOf.
  ///
  /// In es, this message translates to:
  /// **'«{form}» es una forma de «{lemma}».'**
  String wordFormOf(String form, String lemma);

  /// No description provided for @wordDefinition.
  ///
  /// In es, this message translates to:
  /// **'Definición'**
  String get wordDefinition;

  /// No description provided for @wordExamples.
  ///
  /// In es, this message translates to:
  /// **'Ejemplos'**
  String get wordExamples;

  /// No description provided for @wordSynonyms.
  ///
  /// In es, this message translates to:
  /// **'Sinónimos'**
  String get wordSynonyms;

  /// No description provided for @wordAntonyms.
  ///
  /// In es, this message translates to:
  /// **'Antónimos'**
  String get wordAntonyms;

  /// No description provided for @wordRelated.
  ///
  /// In es, this message translates to:
  /// **'Relacionadas'**
  String get wordRelated;

  /// No description provided for @wordForms.
  ///
  /// In es, this message translates to:
  /// **'Formas'**
  String get wordForms;

  /// No description provided for @wordGrammar.
  ///
  /// In es, this message translates to:
  /// **'Gramática'**
  String get wordGrammar;

  /// No description provided for @wordNote.
  ///
  /// In es, this message translates to:
  /// **'Ten en cuenta'**
  String get wordNote;

  /// No description provided for @wordAlternatives.
  ///
  /// In es, this message translates to:
  /// **'También puede ser'**
  String get wordAlternatives;

  /// No description provided for @wordSave.
  ///
  /// In es, this message translates to:
  /// **'Guardar en mi vocabulario'**
  String get wordSave;

  /// No description provided for @wordSaving.
  ///
  /// In es, this message translates to:
  /// **'Guardando…'**
  String get wordSaving;

  /// No description provided for @wordSaved.
  ///
  /// In es, this message translates to:
  /// **'En tu vocabulario'**
  String get wordSaved;

  /// No description provided for @wordSaveFailed.
  ///
  /// In es, this message translates to:
  /// **'No pudimos guardar la palabra. Inténtalo de nuevo.'**
  String get wordSaveFailed;

  /// No description provided for @wordMore.
  ///
  /// In es, this message translates to:
  /// **'Ver todo'**
  String get wordMore;

  /// No description provided for @wordLess.
  ///
  /// In es, this message translates to:
  /// **'Ver menos'**
  String get wordLess;

  /// No description provided for @wordInContext.
  ///
  /// In es, this message translates to:
  /// **'En esta oración'**
  String get wordInContext;

  /// No description provided for @wordTranslateSentence.
  ///
  /// In es, this message translates to:
  /// **'Traducir la oración'**
  String get wordTranslateSentence;

  /// No description provided for @wordHideSentence.
  ///
  /// In es, this message translates to:
  /// **'Ocultar la traducción'**
  String get wordHideSentence;

  /// No description provided for @wordSentenceUnavailable.
  ///
  /// In es, this message translates to:
  /// **'Esta oración aún no tiene traducción.'**
  String get wordSentenceUnavailable;

  /// No description provided for @wordSaveSentence.
  ///
  /// In es, this message translates to:
  /// **'Guardar la oración en mis notas'**
  String get wordSaveSentence;

  /// No description provided for @wordSentenceSaved.
  ///
  /// In es, this message translates to:
  /// **'Oración guardada en tus notas'**
  String get wordSentenceSaved;

  /// No description provided for @wordCopySentence.
  ///
  /// In es, this message translates to:
  /// **'Copiar la oración'**
  String get wordCopySentence;

  /// No description provided for @wordCopied.
  ///
  /// In es, this message translates to:
  /// **'Copiada'**
  String get wordCopied;

  /// No description provided for @wordAddNote.
  ///
  /// In es, this message translates to:
  /// **'Añadir una nota (opcional)'**
  String get wordAddNote;

  /// No description provided for @wordPronunciation.
  ///
  /// In es, this message translates to:
  /// **'Pronunciación'**
  String get wordPronunciation;

  /// No description provided for @settingsSize.
  ///
  /// In es, this message translates to:
  /// **'Tamaño de letra'**
  String get settingsSize;

  /// No description provided for @settingsSmaller.
  ///
  /// In es, this message translates to:
  /// **'Letra más pequeña'**
  String get settingsSmaller;

  /// No description provided for @settingsLarger.
  ///
  /// In es, this message translates to:
  /// **'Letra más grande'**
  String get settingsLarger;

  /// No description provided for @settingsLeading.
  ///
  /// In es, this message translates to:
  /// **'Interlineado'**
  String get settingsLeading;

  /// No description provided for @leadingcompact.
  ///
  /// In es, this message translates to:
  /// **'Junto'**
  String get leadingcompact;

  /// No description provided for @leadingcomfortable.
  ///
  /// In es, this message translates to:
  /// **'Cómodo'**
  String get leadingcomfortable;

  /// No description provided for @leadingairy.
  ///
  /// In es, this message translates to:
  /// **'Amplio'**
  String get leadingairy;

  /// No description provided for @settingsWidth.
  ///
  /// In es, this message translates to:
  /// **'Ancho del texto'**
  String get settingsWidth;

  /// No description provided for @widthnarrow.
  ///
  /// In es, this message translates to:
  /// **'Estrecho'**
  String get widthnarrow;

  /// No description provided for @widthmedium.
  ///
  /// In es, this message translates to:
  /// **'Medio'**
  String get widthmedium;

  /// No description provided for @widthwide.
  ///
  /// In es, this message translates to:
  /// **'Ancho'**
  String get widthwide;

  /// No description provided for @settingsTheme.
  ///
  /// In es, this message translates to:
  /// **'Tema de lectura'**
  String get settingsTheme;

  /// No description provided for @themelight.
  ///
  /// In es, this message translates to:
  /// **'Claro'**
  String get themelight;

  /// No description provided for @themesepia.
  ///
  /// In es, this message translates to:
  /// **'Sepia'**
  String get themesepia;

  /// No description provided for @themedark.
  ///
  /// In es, this message translates to:
  /// **'Oscuro'**
  String get themedark;

  /// No description provided for @settingsAssistance.
  ///
  /// In es, this message translates to:
  /// **'Ayudas'**
  String get settingsAssistance;

  /// No description provided for @settingsHighlightSaved.
  ///
  /// In es, this message translates to:
  /// **'Resaltar las palabras que guardaste'**
  String get settingsHighlightSaved;

  /// No description provided for @settingsHighlightNew.
  ///
  /// In es, this message translates to:
  /// **'Marcar las palabras nuevas para ti'**
  String get settingsHighlightNew;

  /// No description provided for @settingsHighlightNewHint.
  ///
  /// In es, this message translates to:
  /// **'Las que no aparecieron en ninguna lectura que terminaste ni guardaste.'**
  String get settingsHighlightNewHint;

  /// No description provided for @settingsHighlightLearned.
  ///
  /// In es, this message translates to:
  /// **'Marcar las palabras que ya aprendiste'**
  String get settingsHighlightLearned;

  /// No description provided for @settingsParagraphTranslations.
  ///
  /// In es, this message translates to:
  /// **'Mostrar la traducción de cada párrafo'**
  String get settingsParagraphTranslations;

  /// No description provided for @settingsParagraphTranslationsHint.
  ///
  /// In es, this message translates to:
  /// **'Mejor apagada: intenta entender primero y traduce solo lo que necesites.'**
  String get settingsParagraphTranslationsHint;

  /// No description provided for @settingsResume.
  ///
  /// In es, this message translates to:
  /// **'Volver a donde lo dejé al abrir'**
  String get settingsResume;

  /// No description provided for @notesTitle.
  ///
  /// In es, this message translates to:
  /// **'Tus notas'**
  String get notesTitle;

  /// No description provided for @notesEmpty.
  ///
  /// In es, this message translates to:
  /// **'Aún no guardaste oraciones de esta lectura. Toca una palabra y elige «Guardar la oración».'**
  String get notesEmpty;

  /// No description provided for @notesRemove.
  ///
  /// In es, this message translates to:
  /// **'Borrar la nota'**
  String get notesRemove;

  /// No description provided for @notesGo.
  ///
  /// In es, this message translates to:
  /// **'Ir a la oración'**
  String get notesGo;

  /// No description provided for @endTitle.
  ///
  /// In es, this message translates to:
  /// **'¡Lectura terminada!'**
  String get endTitle;

  /// No description provided for @endBody.
  ///
  /// In es, this message translates to:
  /// **'Leíste {words} palabras en {language}.'**
  String endBody(int words, String language);

  /// No description provided for @endTime.
  ///
  /// In es, this message translates to:
  /// **'{count, plural, =1{Le dedicaste 1 minuto.} other{Le dedicaste {count} minutos.}}'**
  String endTime(int count);

  /// No description provided for @endSaved.
  ///
  /// In es, this message translates to:
  /// **'{count, plural, =0{No guardaste palabras esta vez.} =1{Guardaste 1 palabra.} other{Guardaste {count} palabras.}}'**
  String endSaved(int count);

  /// No description provided for @endDiscover.
  ///
  /// In es, this message translates to:
  /// **'Volver a Descubrir'**
  String get endDiscover;

  /// No description provided for @endLibrary.
  ///
  /// In es, this message translates to:
  /// **'Ver mis lecturas'**
  String get endLibrary;

  /// No description provided for @endFailed.
  ///
  /// In es, this message translates to:
  /// **'No pudimos marcarla como terminada. Inténtalo de nuevo.'**
  String get endFailed;

  /// No description provided for @libraryInProgress.
  ///
  /// In es, this message translates to:
  /// **'Leyendo'**
  String get libraryInProgress;

  /// No description provided for @libraryBookmarked.
  ///
  /// In es, this message translates to:
  /// **'Guardadas para después'**
  String get libraryBookmarked;

  /// No description provided for @libraryCompleted.
  ///
  /// In es, this message translates to:
  /// **'Terminadas'**
  String get libraryCompleted;

  /// No description provided for @libraryEmptyTitle.
  ///
  /// In es, this message translates to:
  /// **'Tu biblioteca está esperando'**
  String get libraryEmptyTitle;

  /// No description provided for @libraryEmptyBody.
  ///
  /// In es, this message translates to:
  /// **'Lo que empieces, guardes o termines aparecerá aquí.'**
  String get libraryEmptyBody;

  /// No description provided for @librarySearch.
  ///
  /// In es, this message translates to:
  /// **'Buscar en mis lecturas'**
  String get librarySearch;

  /// No description provided for @audioLabel.
  ///
  /// In es, this message translates to:
  /// **'Audio de la lectura'**
  String get audioLabel;

  /// No description provided for @audioPlay.
  ///
  /// In es, this message translates to:
  /// **'Escuchar'**
  String get audioPlay;

  /// No description provided for @audioPause.
  ///
  /// In es, this message translates to:
  /// **'Pausar'**
  String get audioPause;

  /// No description provided for @audioBack.
  ///
  /// In es, this message translates to:
  /// **'Retroceder 5 segundos'**
  String get audioBack;

  /// No description provided for @audioForward.
  ///
  /// In es, this message translates to:
  /// **'Avanzar 5 segundos'**
  String get audioForward;

  /// No description provided for @audioPreviousSentence.
  ///
  /// In es, this message translates to:
  /// **'Oración anterior'**
  String get audioPreviousSentence;

  /// No description provided for @audioNextSentence.
  ///
  /// In es, this message translates to:
  /// **'Oración siguiente'**
  String get audioNextSentence;

  /// No description provided for @audioPreviousParagraph.
  ///
  /// In es, this message translates to:
  /// **'Párrafo anterior'**
  String get audioPreviousParagraph;

  /// No description provided for @audioNextParagraph.
  ///
  /// In es, this message translates to:
  /// **'Párrafo siguiente'**
  String get audioNextParagraph;

  /// No description provided for @audioPosition.
  ///
  /// In es, this message translates to:
  /// **'Posición del audio'**
  String get audioPosition;

  /// No description provided for @audioPositionValue.
  ///
  /// In es, this message translates to:
  /// **'{current} de {total}'**
  String audioPositionValue(String current, String total);

  /// No description provided for @audioRate.
  ///
  /// In es, this message translates to:
  /// **'Velocidad'**
  String get audioRate;

  /// No description provided for @audioRateValue.
  ///
  /// In es, this message translates to:
  /// **'Velocidad {rate}×'**
  String audioRateValue(String rate);

  /// No description provided for @audioFollow.
  ///
  /// In es, this message translates to:
  /// **'Seguir la lectura'**
  String get audioFollow;

  /// No description provided for @audioFollowBack.
  ///
  /// In es, this message translates to:
  /// **'Volver a lo que suena'**
  String get audioFollowBack;

  /// No description provided for @audioLoading.
  ///
  /// In es, this message translates to:
  /// **'Cargando el audio…'**
  String get audioLoading;

  /// No description provided for @audioVoice.
  ///
  /// In es, this message translates to:
  /// **'Voz: {voice}'**
  String audioVoice(String voice);

  /// No description provided for @audioError.
  ///
  /// In es, this message translates to:
  /// **'No pudimos cargar el audio. Puedes seguir leyendo igual.'**
  String get audioError;

  /// No description provided for @audioFromHere.
  ///
  /// In es, this message translates to:
  /// **'Escuchar desde aquí'**
  String get audioFromHere;

  /// No description provided for @audioParagraph.
  ///
  /// In es, this message translates to:
  /// **'Escuchar este párrafo'**
  String get audioParagraph;

  /// No description provided for @audioOpenReading.
  ///
  /// In es, this message translates to:
  /// **'Abrir la lectura'**
  String get audioOpenReading;

  /// No description provided for @audioClose.
  ///
  /// In es, this message translates to:
  /// **'Cerrar el reproductor'**
  String get audioClose;

  /// No description provided for @audioExpand.
  ///
  /// In es, this message translates to:
  /// **'Abrir el reproductor'**
  String get audioExpand;

  /// No description provided for @audioNowPlaying.
  ///
  /// In es, this message translates to:
  /// **'Ahora suena'**
  String get audioNowPlaying;

  /// No description provided for @audioTapToPlayHint.
  ///
  /// In es, this message translates to:
  /// **'Mientras suena, toca una palabra para escuchar desde ella.'**
  String get audioTapToPlayHint;

  /// No description provided for @vocabTitle.
  ///
  /// In es, this message translates to:
  /// **'Vocabulario'**
  String get vocabTitle;

  /// No description provided for @vocabSearch.
  ///
  /// In es, this message translates to:
  /// **'Buscar en tu vocabulario'**
  String get vocabSearch;

  /// No description provided for @vocabAll.
  ///
  /// In es, this message translates to:
  /// **'Todas'**
  String get vocabAll;

  /// No description provided for @statusSAVED.
  ///
  /// In es, this message translates to:
  /// **'Guardada'**
  String get statusSAVED;

  /// No description provided for @statusLEARNING.
  ///
  /// In es, this message translates to:
  /// **'Aprendiendo'**
  String get statusLEARNING;

  /// No description provided for @statusFAMILIAR.
  ///
  /// In es, this message translates to:
  /// **'Familiar'**
  String get statusFAMILIAR;

  /// No description provided for @statusMASTERED.
  ///
  /// In es, this message translates to:
  /// **'Dominada'**
  String get statusMASTERED;

  /// No description provided for @vocabEmptyTitle.
  ///
  /// In es, this message translates to:
  /// **'Tu cuaderno está en blanco'**
  String get vocabEmptyTitle;

  /// No description provided for @vocabEmptyBody.
  ///
  /// In es, this message translates to:
  /// **'Toca una palabra mientras lees y guárdala: aparecerá aquí, con la oración donde la encontraste.'**
  String get vocabEmptyBody;

  /// No description provided for @vocabNoResults.
  ///
  /// In es, this message translates to:
  /// **'Ninguna palabra coincide.'**
  String get vocabNoResults;

  /// No description provided for @vocabReview.
  ///
  /// In es, this message translates to:
  /// **'Repasar'**
  String get vocabReview;

  /// No description provided for @vocabReviewDue.
  ///
  /// In es, this message translates to:
  /// **'{count, plural, =0{Nada que repasar ahora} =1{Repasar 1 palabra} other{Repasar {count} palabras}}'**
  String vocabReviewDue(int count);

  /// No description provided for @vocabStatsTotal.
  ///
  /// In es, this message translates to:
  /// **'{count, plural, =1{1 palabra} other{{count} palabras}}'**
  String vocabStatsTotal(int count);

  /// No description provided for @vocabStatsToday.
  ///
  /// In es, this message translates to:
  /// **'{count} repasadas hoy'**
  String vocabStatsToday(int count);

  /// No description provided for @vocabStatsEncountered.
  ///
  /// In es, this message translates to:
  /// **'{count} encontradas al leer'**
  String vocabStatsEncountered(int count);

  /// No description provided for @vocabFrom.
  ///
  /// In es, this message translates to:
  /// **'De «{title}»'**
  String vocabFrom(String title);

  /// No description provided for @vocabDueNow.
  ///
  /// In es, this message translates to:
  /// **'Toca repasarla'**
  String get vocabDueNow;

  /// No description provided for @vocabDueOn.
  ///
  /// In es, this message translates to:
  /// **'Próximo repaso: {date}'**
  String vocabDueOn(String date);

  /// No description provided for @vocabReviews.
  ///
  /// In es, this message translates to:
  /// **'{count, plural, =0{Sin repasos todavía} =1{1 repaso} other{{count} repasos}}'**
  String vocabReviews(int count);

  /// No description provided for @vocabNote.
  ///
  /// In es, this message translates to:
  /// **'Tu nota'**
  String get vocabNote;

  /// No description provided for @vocabNoteHint.
  ///
  /// In es, this message translates to:
  /// **'Algo que te ayude a recordarla'**
  String get vocabNoteHint;

  /// No description provided for @vocabRemove.
  ///
  /// In es, this message translates to:
  /// **'Quitar del cuaderno'**
  String get vocabRemove;

  /// No description provided for @vocabRemoveConfirm.
  ///
  /// In es, this message translates to:
  /// **'¿Quitar «{word}» de tu cuaderno?'**
  String vocabRemoveConfirm(String word);

  /// No description provided for @vocabOpenReading.
  ///
  /// In es, this message translates to:
  /// **'Abrir la lectura'**
  String get vocabOpenReading;

  /// No description provided for @vocabOpenEntry.
  ///
  /// In es, this message translates to:
  /// **'Abrir en el diccionario'**
  String get vocabOpenEntry;

  /// No description provided for @reviewTitle.
  ///
  /// In es, this message translates to:
  /// **'Repaso'**
  String get reviewTitle;

  /// No description provided for @reviewProgress.
  ///
  /// In es, this message translates to:
  /// **'{current} de {total}'**
  String reviewProgress(int current, int total);

  /// No description provided for @reviewShow.
  ///
  /// In es, this message translates to:
  /// **'Mostrar la respuesta'**
  String get reviewShow;

  /// No description provided for @reviewPromptMeaning.
  ///
  /// In es, this message translates to:
  /// **'¿Qué significa?'**
  String get reviewPromptMeaning;

  /// No description provided for @reviewPromptWord.
  ///
  /// In es, this message translates to:
  /// **'¿Cómo se dice en {language}?'**
  String reviewPromptWord(String language);

  /// No description provided for @reviewPromptContext.
  ///
  /// In es, this message translates to:
  /// **'¿Qué palabra falta?'**
  String get reviewPromptContext;

  /// No description provided for @reviewHowWell.
  ///
  /// In es, this message translates to:
  /// **'¿Qué tal la recordaste?'**
  String get reviewHowWell;

  /// No description provided for @ratingAGAIN.
  ///
  /// In es, this message translates to:
  /// **'Otra vez'**
  String get ratingAGAIN;

  /// No description provided for @ratingHARD.
  ///
  /// In es, this message translates to:
  /// **'Difícil'**
  String get ratingHARD;

  /// No description provided for @ratingGOOD.
  ///
  /// In es, this message translates to:
  /// **'Bien'**
  String get ratingGOOD;

  /// No description provided for @ratingEASY.
  ///
  /// In es, this message translates to:
  /// **'Fácil'**
  String get ratingEASY;

  /// No description provided for @reviewIn.
  ///
  /// In es, this message translates to:
  /// **'en {when}'**
  String reviewIn(String when);

  /// No description provided for @reviewDoneTitle.
  ///
  /// In es, this message translates to:
  /// **'¡Repaso hecho!'**
  String get reviewDoneTitle;

  /// No description provided for @reviewDoneBody.
  ///
  /// In es, this message translates to:
  /// **'{count, plural, =1{Repasaste 1 palabra.} other{Repasaste {count} palabras.}} Cada una vuelve cuando toca, ni antes ni después.'**
  String reviewDoneBody(int count);

  /// No description provided for @reviewNothing.
  ///
  /// In es, this message translates to:
  /// **'Nada que repasar ahora'**
  String get reviewNothing;

  /// No description provided for @reviewNothingBody.
  ///
  /// In es, this message translates to:
  /// **'Las palabras vuelven cuando toca. Sigue leyendo y guarda las que quieras aprender.'**
  String get reviewNothingBody;

  /// No description provided for @reviewNext.
  ///
  /// In es, this message translates to:
  /// **'Siguiente repaso: {date}'**
  String reviewNext(String date);

  /// No description provided for @reviewFailed.
  ///
  /// In es, this message translates to:
  /// **'No se pudo guardar este repaso. Se reintentará.'**
  String get reviewFailed;

  /// No description provided for @dictTitle.
  ///
  /// In es, this message translates to:
  /// **'Diccionario'**
  String get dictTitle;

  /// No description provided for @dictSearchHint.
  ///
  /// In es, this message translates to:
  /// **'Busca en {target} o en {interface}'**
  String dictSearchHint(String target, String interface);

  /// No description provided for @dictHistory.
  ///
  /// In es, this message translates to:
  /// **'Búsquedas recientes'**
  String get dictHistory;

  /// No description provided for @dictClearHistory.
  ///
  /// In es, this message translates to:
  /// **'Borrar el historial'**
  String get dictClearHistory;

  /// No description provided for @dictFavorites.
  ///
  /// In es, this message translates to:
  /// **'Favoritas'**
  String get dictFavorites;

  /// No description provided for @dictNoResults.
  ///
  /// In es, this message translates to:
  /// **'No encontramos «{query}» en el diccionario.'**
  String dictNoResults(String query);

  /// No description provided for @dictEmptyBody.
  ///
  /// In es, this message translates to:
  /// **'Busca una palabra en cualquiera de tus dos idiomas.'**
  String get dictEmptyBody;

  /// No description provided for @dictFavorite.
  ///
  /// In es, this message translates to:
  /// **'Añadir a favoritas'**
  String get dictFavorite;

  /// No description provided for @dictUnfavorite.
  ///
  /// In es, this message translates to:
  /// **'Quitar de favoritas'**
  String get dictUnfavorite;

  /// No description provided for @dictAppearsIn.
  ///
  /// In es, this message translates to:
  /// **'Aparece en'**
  String get dictAppearsIn;

  /// No description provided for @dictOccurrences.
  ///
  /// In es, this message translates to:
  /// **'{count, plural, =1{1 vez} other{{count} veces}}'**
  String dictOccurrences(int count);

  /// No description provided for @dictMeanings.
  ///
  /// In es, this message translates to:
  /// **'Significados'**
  String get dictMeanings;

  /// No description provided for @quizTitle.
  ///
  /// In es, this message translates to:
  /// **'Comprensión'**
  String get quizTitle;

  /// No description provided for @quizStart.
  ///
  /// In es, this message translates to:
  /// **'Comprueba lo que entendiste ({count} preguntas)'**
  String quizStart(int count);

  /// No description provided for @quizLastResult.
  ///
  /// In es, this message translates to:
  /// **'Último intento: {correct} de {total}'**
  String quizLastResult(int correct, int total);

  /// No description provided for @quizQuestion.
  ///
  /// In es, this message translates to:
  /// **'Pregunta {current} de {total}'**
  String quizQuestion(int current, int total);

  /// No description provided for @quizNext.
  ///
  /// In es, this message translates to:
  /// **'Siguiente'**
  String get quizNext;

  /// No description provided for @quizPrevious.
  ///
  /// In es, this message translates to:
  /// **'Anterior'**
  String get quizPrevious;

  /// No description provided for @quizSubmit.
  ///
  /// In es, this message translates to:
  /// **'Enviar respuestas'**
  String get quizSubmit;

  /// No description provided for @quizSubmitting.
  ///
  /// In es, this message translates to:
  /// **'Enviando…'**
  String get quizSubmitting;

  /// No description provided for @quizTrue.
  ///
  /// In es, this message translates to:
  /// **'Verdadero'**
  String get quizTrue;

  /// No description provided for @quizFalse.
  ///
  /// In es, this message translates to:
  /// **'Falso'**
  String get quizFalse;

  /// No description provided for @quizChooseMany.
  ///
  /// In es, this message translates to:
  /// **'Elige todas las que correspondan'**
  String get quizChooseMany;

  /// No description provided for @quizBank.
  ///
  /// In es, this message translates to:
  /// **'Palabras para completar'**
  String get quizBank;

  /// No description provided for @quizBlankEmpty.
  ///
  /// In es, this message translates to:
  /// **'Hueco {n}, vacío'**
  String quizBlankEmpty(int n);

  /// No description provided for @quizBlankFilled.
  ///
  /// In es, this message translates to:
  /// **'Hueco {n}: {word}. Toca para quitarla'**
  String quizBlankFilled(int n, String word);

  /// No description provided for @quizMatchHint.
  ///
  /// In es, this message translates to:
  /// **'Elige la pareja de cada una'**
  String get quizMatchHint;

  /// No description provided for @quizMatchChoose.
  ///
  /// In es, this message translates to:
  /// **'Elegir'**
  String get quizMatchChoose;

  /// No description provided for @quizOrderHint.
  ///
  /// In es, this message translates to:
  /// **'Ordénalas como ocurren en el texto'**
  String get quizOrderHint;

  /// No description provided for @quizMoveUp.
  ///
  /// In es, this message translates to:
  /// **'Subir'**
  String get quizMoveUp;

  /// No description provided for @quizMoveDown.
  ///
  /// In es, this message translates to:
  /// **'Bajar'**
  String get quizMoveDown;

  /// No description provided for @quizShortHint.
  ///
  /// In es, this message translates to:
  /// **'Responde con tus palabras, en el idioma que prefieras'**
  String get quizShortHint;

  /// No description provided for @quizUnanswered.
  ///
  /// In es, this message translates to:
  /// **'{count, plural, =1{Queda 1 pregunta sin responder: contará como incorrecta.} other{Quedan {count} preguntas sin responder: contarán como incorrectas.}}'**
  String quizUnanswered(int count);

  /// No description provided for @quizResultTitle.
  ///
  /// In es, this message translates to:
  /// **'Tu resultado'**
  String get quizResultTitle;

  /// No description provided for @quizScore.
  ///
  /// In es, this message translates to:
  /// **'{correct} de {total} correctas'**
  String quizScore(int correct, int total);

  /// No description provided for @quizPartial.
  ///
  /// In es, this message translates to:
  /// **'{count} en parte'**
  String quizPartial(int count);

  /// No description provided for @quizPending.
  ///
  /// In es, this message translates to:
  /// **'{count, plural, =1{1 respuesta se está corrigiendo…} other{{count} respuestas se están corrigiendo…}}'**
  String quizPending(int count);

  /// No description provided for @quizUngraded.
  ///
  /// In es, this message translates to:
  /// **'{count, plural, =1{1 respuesta abierta para que la compares tú} other{{count} respuestas abiertas para que las compares tú}}'**
  String quizUngraded(int count);

  /// No description provided for @quizStrengths.
  ///
  /// In es, this message translates to:
  /// **'Lo que te salió bien'**
  String get quizStrengths;

  /// No description provided for @quizImprove.
  ///
  /// In es, this message translates to:
  /// **'Para practicar'**
  String get quizImprove;

  /// No description provided for @resultCORRECT.
  ///
  /// In es, this message translates to:
  /// **'Correcta'**
  String get resultCORRECT;

  /// No description provided for @resultPARTIAL.
  ///
  /// In es, this message translates to:
  /// **'En parte'**
  String get resultPARTIAL;

  /// No description provided for @resultINCORRECT.
  ///
  /// In es, this message translates to:
  /// **'Incorrecta'**
  String get resultINCORRECT;

  /// No description provided for @resultPENDING.
  ///
  /// In es, this message translates to:
  /// **'Corrigiendo…'**
  String get resultPENDING;

  /// No description provided for @resultUNGRADED.
  ///
  /// In es, this message translates to:
  /// **'Para autoevaluar'**
  String get resultUNGRADED;

  /// No description provided for @quizYourAnswer.
  ///
  /// In es, this message translates to:
  /// **'Tu respuesta'**
  String get quizYourAnswer;

  /// No description provided for @quizSolution.
  ///
  /// In es, this message translates to:
  /// **'Respuesta'**
  String get quizSolution;

  /// No description provided for @quizModelAnswer.
  ///
  /// In es, this message translates to:
  /// **'Respuesta modelo'**
  String get quizModelAnswer;

  /// No description provided for @quizNoAnswer.
  ///
  /// In es, this message translates to:
  /// **'Sin responder'**
  String get quizNoAnswer;

  /// No description provided for @quizExplanation.
  ///
  /// In es, this message translates to:
  /// **'Por qué'**
  String get quizExplanation;

  /// No description provided for @quizInText.
  ///
  /// In es, this message translates to:
  /// **'En el texto'**
  String get quizInText;

  /// No description provided for @quizAssisted.
  ///
  /// In es, this message translates to:
  /// **'Corrección asistida, con las oraciones en que se apoya'**
  String get quizAssisted;

  /// No description provided for @quizRule.
  ///
  /// In es, this message translates to:
  /// **'Corrección automática'**
  String get quizRule;

  /// No description provided for @quizSelf.
  ///
  /// In es, this message translates to:
  /// **'Autoevaluada'**
  String get quizSelf;

  /// No description provided for @quizSelfPrompt.
  ///
  /// In es, this message translates to:
  /// **'Compara tu respuesta con la modelo. ¿Cómo te fue?'**
  String get quizSelfPrompt;

  /// No description provided for @quizRetry.
  ///
  /// In es, this message translates to:
  /// **'Intentarlo otra vez'**
  String get quizRetry;

  /// No description provided for @quizBackToReading.
  ///
  /// In es, this message translates to:
  /// **'Volver a la lectura'**
  String get quizBackToReading;

  /// No description provided for @skillMULTIPLE_CHOICE.
  ///
  /// In es, this message translates to:
  /// **'Opciones'**
  String get skillMULTIPLE_CHOICE;

  /// No description provided for @skillTRUE_FALSE.
  ///
  /// In es, this message translates to:
  /// **'Verdadero o falso'**
  String get skillTRUE_FALSE;

  /// No description provided for @skillCOMPLETION.
  ///
  /// In es, this message translates to:
  /// **'Completar oraciones'**
  String get skillCOMPLETION;

  /// No description provided for @skillMATCHING.
  ///
  /// In es, this message translates to:
  /// **'Emparejar'**
  String get skillMATCHING;

  /// No description provided for @skillORDERING.
  ///
  /// In es, this message translates to:
  /// **'Ordenar los hechos'**
  String get skillORDERING;

  /// No description provided for @skillSHORT_ANSWER.
  ///
  /// In es, this message translates to:
  /// **'Respuesta breve'**
  String get skillSHORT_ANSWER;

  /// No description provided for @skillVOCABULARY_IN_CONTEXT.
  ///
  /// In es, this message translates to:
  /// **'Vocabulario en contexto'**
  String get skillVOCABULARY_IN_CONTEXT;

  /// No description provided for @skillMAIN_IDEA.
  ///
  /// In es, this message translates to:
  /// **'Idea principal'**
  String get skillMAIN_IDEA;

  /// No description provided for @skillINFERENCE.
  ///
  /// In es, this message translates to:
  /// **'Inferencia'**
  String get skillINFERENCE;

  /// No description provided for @skillDETAIL.
  ///
  /// In es, this message translates to:
  /// **'Detalles del texto'**
  String get skillDETAIL;

  /// No description provided for @skillunknown.
  ///
  /// In es, this message translates to:
  /// **'Otras'**
  String get skillunknown;

  /// No description provided for @durMinutes.
  ///
  /// In es, this message translates to:
  /// **'{count} min'**
  String durMinutes(int count);

  /// No description provided for @durHours.
  ///
  /// In es, this message translates to:
  /// **'{count} h'**
  String durHours(int count);

  /// No description provided for @durDays.
  ///
  /// In es, this message translates to:
  /// **'{count, plural, =1{1 día} other{{count} días}}'**
  String durDays(int count);

  /// No description provided for @quizQueuedTitle.
  ///
  /// In es, this message translates to:
  /// **'Respuestas guardadas'**
  String get quizQueuedTitle;

  /// No description provided for @quizQueuedBody.
  ///
  /// In es, this message translates to:
  /// **'No hay conexión: tus respuestas están en el dispositivo. Se enviarán y se corregirán al volver la red; el resultado lo da el servidor, no la app.'**
  String get quizQueuedBody;

  /// No description provided for @quizQueuedPending.
  ///
  /// In es, this message translates to:
  /// **'Pendiente de evaluar'**
  String get quizQueuedPending;

  /// No description provided for @quizSeeResult.
  ///
  /// In es, this message translates to:
  /// **'Ver el último resultado'**
  String get quizSeeResult;

  /// No description provided for @downloadsTitle.
  ///
  /// In es, this message translates to:
  /// **'Descargas'**
  String get downloadsTitle;

  /// No description provided for @downloadAction.
  ///
  /// In es, this message translates to:
  /// **'Descargar para leer sin conexión'**
  String get downloadAction;

  /// No description provided for @downloadQueued.
  ///
  /// In es, this message translates to:
  /// **'En espera…'**
  String get downloadQueued;

  /// No description provided for @downloadProgress.
  ///
  /// In es, this message translates to:
  /// **'Descargando… {percent} %'**
  String downloadProgress(int percent);

  /// No description provided for @downloadDone.
  ///
  /// In es, this message translates to:
  /// **'Descargada · disponible sin conexión'**
  String get downloadDone;

  /// No description provided for @downloadFailed.
  ///
  /// In es, this message translates to:
  /// **'La descarga falló'**
  String get downloadFailed;

  /// No description provided for @downloadWaitingWifi.
  ///
  /// In es, this message translates to:
  /// **'Esperando una red Wi-Fi para el audio'**
  String get downloadWaitingWifi;

  /// No description provided for @downloadCancel.
  ///
  /// In es, this message translates to:
  /// **'Cancelar la descarga'**
  String get downloadCancel;

  /// No description provided for @downloadRetry.
  ///
  /// In es, this message translates to:
  /// **'Reintentar la descarga'**
  String get downloadRetry;

  /// No description provided for @downloadRemove.
  ///
  /// In es, this message translates to:
  /// **'Quitar la descarga'**
  String get downloadRemove;

  /// No description provided for @downloadsEmpty.
  ///
  /// In es, this message translates to:
  /// **'Nada descargado todavía'**
  String get downloadsEmpty;

  /// No description provided for @downloadsEmptyBody.
  ///
  /// In es, this message translates to:
  /// **'En la ficha de una lectura, «Descargar» guarda su texto, sus traducciones, su audio y sus preguntas para leerla sin conexión.'**
  String get downloadsEmptyBody;

  /// No description provided for @downloadsStorage.
  ///
  /// In es, this message translates to:
  /// **'Ocupan {size} en el dispositivo'**
  String downloadsStorage(String size);

  /// No description provided for @downloadsWifiOnly.
  ///
  /// In es, this message translates to:
  /// **'Descargar el audio solo con Wi-Fi'**
  String get downloadsWifiOnly;

  /// No description provided for @syncTitle.
  ///
  /// In es, this message translates to:
  /// **'Sincronización'**
  String get syncTitle;

  /// No description provided for @syncPending.
  ///
  /// In es, this message translates to:
  /// **'{count, plural, =0{Todo está sincronizado} =1{1 cambio pendiente de enviar} other{{count} cambios pendientes de enviar}}'**
  String syncPending(int count);

  /// No description provided for @syncNow.
  ///
  /// In es, this message translates to:
  /// **'Sincronizar ahora'**
  String get syncNow;

  /// No description provided for @syncing.
  ///
  /// In es, this message translates to:
  /// **'Sincronizando…'**
  String get syncing;

  /// No description provided for @syncRejected.
  ///
  /// In es, this message translates to:
  /// **'El servidor no aceptó {count, plural, =1{1 cambio} other{{count} cambios}}'**
  String syncRejected(int count);

  /// No description provided for @syncDiscard.
  ///
  /// In es, this message translates to:
  /// **'Descartar'**
  String get syncDiscard;

  /// No description provided for @syncLast.
  ///
  /// In es, this message translates to:
  /// **'Última sincronización: {time}'**
  String syncLast(String time);

  /// No description provided for @offlinePending.
  ///
  /// In es, this message translates to:
  /// **'Sin conexión · {count} cambios esperan para enviarse'**
  String offlinePending(int count);

  /// No description provided for @progressTitle.
  ///
  /// In es, this message translates to:
  /// **'Progreso'**
  String get progressTitle;

  /// No description provided for @progressToday.
  ///
  /// In es, this message translates to:
  /// **'Hoy'**
  String get progressToday;

  /// No description provided for @progressTodayMinutes.
  ///
  /// In es, this message translates to:
  /// **'{minutes} de {goal} min'**
  String progressTodayMinutes(int minutes, int goal);

  /// No description provided for @progressGoalMet.
  ///
  /// In es, this message translates to:
  /// **'Meta de hoy cumplida. ¡Bien leído!'**
  String get progressGoalMet;

  /// No description provided for @progressGoalOpen.
  ///
  /// In es, this message translates to:
  /// **'Unos minutos bastan. Lo que leas hoy suma.'**
  String get progressGoalOpen;

  /// No description provided for @progressWeek.
  ///
  /// In es, this message translates to:
  /// **'Esta semana'**
  String get progressWeek;

  /// No description provided for @progressWeekDays.
  ///
  /// In es, this message translates to:
  /// **'{active} de {target} días con lectura'**
  String progressWeekDays(int active, int target);

  /// No description provided for @progressWeekMet.
  ///
  /// In es, this message translates to:
  /// **'Semana cumplida'**
  String get progressWeekMet;

  /// No description provided for @progressStreak.
  ///
  /// In es, this message translates to:
  /// **'{count, plural, =0{Tu primera semana cumplida está a la vuelta} =1{1 semana cumplida seguida} other{{count} semanas cumplidas seguidas}}'**
  String progressStreak(int count);

  /// No description provided for @progressBest.
  ///
  /// In es, this message translates to:
  /// **'Tu mejor racha: {count}'**
  String progressBest(int count);

  /// No description provided for @progressLast28.
  ///
  /// In es, this message translates to:
  /// **'Los últimos 28 días'**
  String get progressLast28;

  /// No description provided for @progressDayLabel.
  ///
  /// In es, this message translates to:
  /// **'{date}: {minutes} min'**
  String progressDayLabel(String date, int minutes);

  /// No description provided for @progressDayGoal.
  ///
  /// In es, this message translates to:
  /// **'{date}: {minutes} min, meta cumplida'**
  String progressDayGoal(String date, int minutes);

  /// No description provided for @progressReading.
  ///
  /// In es, this message translates to:
  /// **'Lectura'**
  String get progressReading;

  /// No description provided for @progressVocabulary.
  ///
  /// In es, this message translates to:
  /// **'Vocabulario'**
  String get progressVocabulary;

  /// No description provided for @progressComprehension.
  ///
  /// In es, this message translates to:
  /// **'Comprensión'**
  String get progressComprehension;

  /// No description provided for @metricStarted.
  ///
  /// In es, this message translates to:
  /// **'Empezadas'**
  String get metricStarted;

  /// No description provided for @metricCompleted.
  ///
  /// In es, this message translates to:
  /// **'Terminadas'**
  String get metricCompleted;

  /// No description provided for @metricMinutes.
  ///
  /// In es, this message translates to:
  /// **'Minutos leídos'**
  String get metricMinutes;

  /// No description provided for @metricWordsRead.
  ///
  /// In es, this message translates to:
  /// **'Palabras leídas'**
  String get metricWordsRead;

  /// No description provided for @metricMinutesWeek.
  ///
  /// In es, this message translates to:
  /// **'Minutos esta semana'**
  String get metricMinutesWeek;

  /// No description provided for @metricCompletedWeek.
  ///
  /// In es, this message translates to:
  /// **'Terminadas esta semana'**
  String get metricCompletedWeek;

  /// No description provided for @metricEncountered.
  ///
  /// In es, this message translates to:
  /// **'Encontradas'**
  String get metricEncountered;

  /// No description provided for @metricSaved.
  ///
  /// In es, this message translates to:
  /// **'Guardadas'**
  String get metricSaved;

  /// No description provided for @metricLearning.
  ///
  /// In es, this message translates to:
  /// **'Aprendiendo'**
  String get metricLearning;

  /// No description provided for @metricMastered.
  ///
  /// In es, this message translates to:
  /// **'Dominadas'**
  String get metricMastered;

  /// No description provided for @metricDue.
  ///
  /// In es, this message translates to:
  /// **'Para repasar'**
  String get metricDue;

  /// No description provided for @metricAnswered.
  ///
  /// In es, this message translates to:
  /// **'Preguntas respondidas'**
  String get metricAnswered;

  /// No description provided for @metricAverage.
  ///
  /// In es, this message translates to:
  /// **'Acierto medio'**
  String get metricAverage;

  /// No description provided for @metricEstimated.
  ///
  /// In es, this message translates to:
  /// **'estimado'**
  String get metricEstimated;

  /// No description provided for @metricEstimatedHint.
  ///
  /// In es, this message translates to:
  /// **'≈ estimado: se infiere de lo que lees y repasas; lo demás está contado.'**
  String get metricEstimatedHint;

  /// No description provided for @progressGrowth.
  ///
  /// In es, this message translates to:
  /// **'Palabras guardadas por semana'**
  String get progressGrowth;

  /// No description provided for @progressByType.
  ///
  /// In es, this message translates to:
  /// **'Por tipo de pregunta'**
  String get progressByType;

  /// No description provided for @progressNoAnswers.
  ///
  /// In es, this message translates to:
  /// **'Cuando respondas preguntas de comprensión, verás aquí cómo entiendes.'**
  String get progressNoAnswers;

  /// No description provided for @progressLevel.
  ///
  /// In es, this message translates to:
  /// **'Tu nivel'**
  String get progressLevel;

  /// No description provided for @progressLevelEstimate.
  ///
  /// In es, this message translates to:
  /// **'{level} · estimado'**
  String progressLevelEstimate(String level);

  /// No description provided for @levelSignalUP.
  ///
  /// In es, this message translates to:
  /// **'Tus respuestas sugieren que podrías probar lecturas un poco más exigentes.'**
  String get levelSignalUP;

  /// No description provided for @levelSignalSTEADY.
  ///
  /// In es, this message translates to:
  /// **'Tus lecturas encajan con tu nivel.'**
  String get levelSignalSTEADY;

  /// No description provided for @levelSignalDOWN.
  ///
  /// In es, this message translates to:
  /// **'Quizá te vengan mejor lecturas un poco más sencillas por ahora.'**
  String get levelSignalDOWN;

  /// No description provided for @levelSignalunknown.
  ///
  /// In es, this message translates to:
  /// **'Aún no hay suficientes respuestas para decir más.'**
  String get levelSignalunknown;

  /// No description provided for @progressAchievements.
  ///
  /// In es, this message translates to:
  /// **'Logros'**
  String get progressAchievements;

  /// No description provided for @progressSeeAll.
  ///
  /// In es, this message translates to:
  /// **'Ver todos'**
  String get progressSeeAll;

  /// No description provided for @progressWeeklySummary.
  ///
  /// In es, this message translates to:
  /// **'Resumen semanal'**
  String get progressWeeklySummary;

  /// No description provided for @progressGoals.
  ///
  /// In es, this message translates to:
  /// **'Metas'**
  String get progressGoals;

  /// No description provided for @progressEmpty.
  ///
  /// In es, this message translates to:
  /// **'Tu progreso empieza con tu primera lectura'**
  String get progressEmpty;

  /// No description provided for @progressEmptyBody.
  ///
  /// In es, this message translates to:
  /// **'Lee unos minutos y aquí verás tu semana, tus palabras y lo que entiendes. Sin castigos por los días sin leer.'**
  String get progressEmptyBody;

  /// No description provided for @goalsDaily.
  ///
  /// In es, this message translates to:
  /// **'Minutos al día'**
  String get goalsDaily;

  /// No description provided for @goalsWeekly.
  ///
  /// In es, this message translates to:
  /// **'Días por semana'**
  String get goalsWeekly;

  /// No description provided for @goalsWeeklyHint.
  ///
  /// In es, this message translates to:
  /// **'La racha cuenta semanas cumplidas, no días: un día sin leer no rompe nada.'**
  String get goalsWeeklyHint;

  /// No description provided for @goalsWeeklySummary.
  ///
  /// In es, this message translates to:
  /// **'Mostrar un resumen de la semana'**
  String get goalsWeeklySummary;

  /// No description provided for @goalsReminder.
  ///
  /// In es, this message translates to:
  /// **'Recordatorio diario'**
  String get goalsReminder;

  /// No description provided for @goalsReminderHint.
  ///
  /// In es, this message translates to:
  /// **'Un aviso al día, a la hora que elijas. Nada más.'**
  String get goalsReminderHint;

  /// No description provided for @goalsReminderAt.
  ///
  /// In es, this message translates to:
  /// **'A las {time}'**
  String goalsReminderAt(String time);

  /// No description provided for @goalsReminderDenied.
  ///
  /// In es, this message translates to:
  /// **'Sin permiso para notificaciones: actívalo en los ajustes del sistema si quieres el recordatorio.'**
  String get goalsReminderDenied;

  /// No description provided for @goalsReviewReminder.
  ///
  /// In es, this message translates to:
  /// **'Recordarme repasar vocabulario'**
  String get goalsReviewReminder;

  /// No description provided for @goalsSaved.
  ///
  /// In es, this message translates to:
  /// **'Metas guardadas'**
  String get goalsSaved;

  /// No description provided for @reminderReadTitle.
  ///
  /// In es, this message translates to:
  /// **'Un ratito de lectura'**
  String get reminderReadTitle;

  /// No description provided for @reminderReadBody.
  ///
  /// In es, this message translates to:
  /// **'Tu próxima historia te espera en Lesen.'**
  String get reminderReadBody;

  /// No description provided for @reminderReviewTitle.
  ///
  /// In es, this message translates to:
  /// **'Palabras para repasar'**
  String get reminderReviewTitle;

  /// No description provided for @reminderReviewBody.
  ///
  /// In es, this message translates to:
  /// **'Unos minutos de repaso y vuelven cuando toca.'**
  String get reminderReviewBody;

  /// No description provided for @weeklyRange.
  ///
  /// In es, this message translates to:
  /// **'Del {start} al {end}'**
  String weeklyRange(String start, String end);

  /// No description provided for @weeklyPrevious.
  ///
  /// In es, this message translates to:
  /// **'Semana anterior'**
  String get weeklyPrevious;

  /// No description provided for @weeklyNext.
  ///
  /// In es, this message translates to:
  /// **'Semana siguiente'**
  String get weeklyNext;

  /// No description provided for @weeklyMet.
  ///
  /// In es, this message translates to:
  /// **'Semana cumplida: {active} de {target} días.'**
  String weeklyMet(int active, int target);

  /// No description provided for @weeklyProgress.
  ///
  /// In es, this message translates to:
  /// **'Llevas {active} de {target} días.'**
  String weeklyProgress(int active, int target);

  /// No description provided for @weeklyQuiet.
  ///
  /// In es, this message translates to:
  /// **'Una semana tranquila. La siguiente es nueva.'**
  String get weeklyQuiet;

  /// No description provided for @metricReadingsCompleted.
  ///
  /// In es, this message translates to:
  /// **'Lecturas terminadas'**
  String get metricReadingsCompleted;

  /// No description provided for @metricWordsSaved.
  ///
  /// In es, this message translates to:
  /// **'Palabras guardadas'**
  String get metricWordsSaved;

  /// No description provided for @metricWordsReviewed.
  ///
  /// In es, this message translates to:
  /// **'Palabras repasadas'**
  String get metricWordsReviewed;

  /// No description provided for @metricAssessments.
  ///
  /// In es, this message translates to:
  /// **'Evaluaciones'**
  String get metricAssessments;

  /// No description provided for @achievementProgress.
  ///
  /// In es, this message translates to:
  /// **'{value} de {threshold}'**
  String achievementProgress(int value, int threshold);

  /// No description provided for @achievementEarned.
  ///
  /// In es, this message translates to:
  /// **'Conseguido el {date}'**
  String achievementEarned(String date);

  /// No description provided for @achFIRST_READING.
  ///
  /// In es, this message translates to:
  /// **'Primera lectura terminada'**
  String get achFIRST_READING;

  /// No description provided for @achREADINGS_5.
  ///
  /// In es, this message translates to:
  /// **'5 lecturas terminadas'**
  String get achREADINGS_5;

  /// No description provided for @achREADINGS_20.
  ///
  /// In es, this message translates to:
  /// **'20 lecturas terminadas'**
  String get achREADINGS_20;

  /// No description provided for @achFIRST_HOUR.
  ///
  /// In es, this message translates to:
  /// **'Tu primera hora leyendo'**
  String get achFIRST_HOUR;

  /// No description provided for @achTEN_HOURS.
  ///
  /// In es, this message translates to:
  /// **'10 horas leyendo'**
  String get achTEN_HOURS;

  /// No description provided for @achFIRST_WORD.
  ///
  /// In es, this message translates to:
  /// **'Primera palabra guardada'**
  String get achFIRST_WORD;

  /// No description provided for @achWORDS_50.
  ///
  /// In es, this message translates to:
  /// **'50 palabras guardadas'**
  String get achWORDS_50;

  /// No description provided for @achFIRST_REVIEW.
  ///
  /// In es, this message translates to:
  /// **'Primer repaso'**
  String get achFIRST_REVIEW;

  /// No description provided for @achREVIEWS_100.
  ///
  /// In es, this message translates to:
  /// **'100 repasos'**
  String get achREVIEWS_100;

  /// No description provided for @achFIRST_ASSESSMENT.
  ///
  /// In es, this message translates to:
  /// **'Primeras preguntas respondidas'**
  String get achFIRST_ASSESSMENT;

  /// No description provided for @achDAYS_10.
  ///
  /// In es, this message translates to:
  /// **'10 días con lectura'**
  String get achDAYS_10;

  /// No description provided for @achFIRST_WEEK.
  ///
  /// In es, this message translates to:
  /// **'Primera semana cumplida'**
  String get achFIRST_WEEK;

  /// No description provided for @achSTREAK_4.
  ///
  /// In es, this message translates to:
  /// **'4 semanas cumplidas seguidas'**
  String get achSTREAK_4;

  /// No description provided for @achUnknown.
  ///
  /// In es, this message translates to:
  /// **'Logro'**
  String get achUnknown;

  /// No description provided for @listsTitle.
  ///
  /// In es, this message translates to:
  /// **'Mis listas'**
  String get listsTitle;

  /// No description provided for @listsNew.
  ///
  /// In es, this message translates to:
  /// **'Nueva lista'**
  String get listsNew;

  /// No description provided for @listsName.
  ///
  /// In es, this message translates to:
  /// **'Nombre de la lista'**
  String get listsName;

  /// No description provided for @listsCreate.
  ///
  /// In es, this message translates to:
  /// **'Crear'**
  String get listsCreate;

  /// No description provided for @listsAddTo.
  ///
  /// In es, this message translates to:
  /// **'Añadir a una lista'**
  String get listsAddTo;

  /// No description provided for @listsEmpty.
  ///
  /// In es, this message translates to:
  /// **'Aún no tienes listas. Crea una para agrupar lecturas a tu manera.'**
  String get listsEmpty;

  /// No description provided for @listsCount.
  ///
  /// In es, this message translates to:
  /// **'{count, plural, =0{Vacía} =1{1 lectura} other{{count} lecturas}}'**
  String listsCount(int count);

  /// No description provided for @listsDuplicate.
  ///
  /// In es, this message translates to:
  /// **'Ya tienes una lista con ese nombre.'**
  String get listsDuplicate;

  /// No description provided for @listsDelete.
  ///
  /// In es, this message translates to:
  /// **'Borrar la lista'**
  String get listsDelete;

  /// No description provided for @listsDeleteConfirm.
  ///
  /// In es, this message translates to:
  /// **'¿Borrar la lista «{name}»? Las lecturas no se borran.'**
  String listsDeleteConfirm(String name);

  /// No description provided for @listsEmptyList.
  ///
  /// In es, this message translates to:
  /// **'Esta lista está vacía. Añade lecturas desde su ficha.'**
  String get listsEmptyList;

  /// No description provided for @signOutPendingTitle.
  ///
  /// In es, this message translates to:
  /// **'Hay cambios sin enviar'**
  String get signOutPendingTitle;

  /// No description provided for @signOutPendingBody.
  ///
  /// In es, this message translates to:
  /// **'{count, plural, =1{1 cambio no ha llegado aún al servidor.} other{{count} cambios no han llegado aún al servidor.}} Si cierras sesión ahora, se perderán. Conéctate para sincronizar antes.'**
  String signOutPendingBody(int count);

  /// No description provided for @signOutAnyway.
  ///
  /// In es, this message translates to:
  /// **'Cerrar sesión igualmente'**
  String get signOutAnyway;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'es'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
