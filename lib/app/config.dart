/// Configuración del entorno, fijada al compilar con `--dart-define-from-file=config/<entorno>.json`.
class AppConfig {
  const AppConfig({required this.environment, required this.apiBaseUrl, this.version = '0.1.0'});

  factory AppConfig.fromEnvironment() {
    const env = String.fromEnvironment('APP_ENV', defaultValue: 'dev');
    const base = String.fromEnvironment('API_BASE_URL', defaultValue: 'http://localhost:8095');
    return AppConfig(environment: env, apiBaseUrl: _trimSlash(base));
  }

  final String environment;

  /// Origen del backend, sin `/api` y sin barra final.
  final String apiBaseUrl;
  final String version;

  bool get isDev => environment == 'dev';

  /// Resuelve una URL relativa del backend (portadas, audio) contra su origen. Las absolutas se devuelven tal cual.
  String resolve(String url) {
    final uri = Uri.parse(url);
    if (uri.hasScheme) return url;
    return Uri.parse(apiBaseUrl).resolveUri(uri).toString();
  }

  static String _trimSlash(String value) => value.endsWith('/') ? value.substring(0, value.length - 1) : value;
}
