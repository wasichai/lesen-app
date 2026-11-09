/// Rutas de la app como constantes y constructores tipados: ninguna pantalla escribe una ruta a mano.
abstract final class Routes {
  static const splash = '/splash';
  static const login = '/login';
  static const onboarding = '/onboarding';
  static const discover = '/discover';
  static const catalog = '/discover/catalog';
  static const library = '/library';
  static const vocabulary = '/vocabulary';
  static const progress = '/progress';
  static const profile = '/profile';
  static const player = '/player';
  static const dictionary = '/dictionary';
  static const review = '/review';
  static const downloads = '/downloads';

  static String entry(String key) => '/dictionary/entries/${Uri.encodeComponent(key)}';
  static String quiz(String slug, int version) => '/read/$slug/quiz?version=$version';
  static String attempt(String id, {required String slug, required int version}) =>
      Uri(path: '/attempts/$id', queryParameters: {'slug': slug, 'version': '$version'}).toString();

  static final slugPattern = RegExp(r'^[a-z0-9][a-z0-9-]{0,119}$');

  static String reading(String slug) => '/discover/readings/$slug';
  static String reader(String slug) => '/read/$slug';

  static String catalogWith({String? topic, String? level, String? language}) =>
      Uri(path: catalog, queryParameters: {'topic': ?topic, 'level': ?level, 'language': ?language}).toString().replaceFirst(RegExp(r'\?$'), '');

  static String editProfile() => '$onboarding?edit=1';

  /// Las rutas que no exigen sesión.
  static const public = {splash, login};
}
