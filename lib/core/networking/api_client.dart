import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/config.dart';
import '../session/session_controller.dart';
import 'api_failure.dart';
import 'json.dart';

final appConfigProvider = Provider<AppConfig>((ref) => AppConfig.fromEnvironment());

/// Transporte HTTP; las pruebas lo sustituyen por uno que sirve fixtures capturadas del backend.
final httpAdapterProvider = Provider<HttpClientAdapter?>((ref) => null);

/// El único cliente HTTP de la app (ADR-0004).
final dioProvider = Provider<Dio>((ref) {
  final config = ref.watch(appConfigProvider);
  final dio = Dio(
    BaseOptions(
      baseUrl: '${config.apiBaseUrl}/api',
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 20),
      sendTimeout: const Duration(seconds: 20),
      headers: {'Accept': 'application/json, application/problem+json'},
      responseType: ResponseType.json,
    ),
  );
  final adapter = ref.watch(httpAdapterProvider);
  if (adapter != null) dio.httpClientAdapter = adapter;
  dio.interceptors.add(
    SessionInterceptor(
      token: () => ref.read(sessionControllerProvider).session?.token,
      onUnauthorized: () => ref.read(sessionControllerProvider.notifier).expire(),
    ),
  );
  dio.interceptors.add(RetryInterceptor(dio));
  return dio;
});

final apiProvider = Provider<Api>((ref) => Api(ref.watch(dioProvider)));

/// Añade el Bearer y, ante un 401 con sesión, la cierra (no hay refresco de token en el backend).
class SessionInterceptor extends Interceptor {
  SessionInterceptor({required this.token, required this.onUnauthorized});

  final String? Function() token;
  final void Function() onUnauthorized;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final t = token();
    if (t != null && !options.path.startsWith('/auth/login')) {
      options.headers['Authorization'] = 'Bearer $t';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final sentToken = err.requestOptions.headers['Authorization'] != null;
    if (err.response?.statusCode == 401 && sentToken) onUnauthorized();
    handler.next(err);
  }
}

/// Reintenta solo errores de red en llamadas idempotentes, como mucho dos veces y con espera creciente.
class RetryInterceptor extends Interceptor {
  RetryInterceptor(this.dio, {this.retries = 2, this.baseDelay = const Duration(milliseconds: 400)});

  final Dio dio;
  final int retries;
  final Duration baseDelay;

  static const _idempotent = {'GET', 'HEAD', 'PUT', 'DELETE'};

  @override
  Future<void> onError(DioException err, ErrorInterceptorHandler handler) async {
    final options = err.requestOptions;
    final attempt = (options.extra['retry'] as int?) ?? 0;
    final network = err.type == DioExceptionType.connectionError || err.type == DioExceptionType.connectionTimeout;
    final allowed = _idempotent.contains(options.method.toUpperCase()) || options.extra['idempotent'] == true;
    if (!network || !allowed || attempt >= retries || options.cancelToken?.isCancelled == true) {
      return handler.next(err);
    }
    await Future<void>.delayed(baseDelay * (1 << attempt));
    options.extra['retry'] = attempt + 1;
    try {
      handler.resolve(await dio.fetch<dynamic>(options));
    } on DioException catch (e) {
      handler.next(e);
    }
  }
}

/// Fachada fina sobre dio: rutas relativas a `/api`, errores como [ApiFailure] y 404 como `null` cuando se pide.
class Api {
  Api(this.dio);

  final Dio dio;

  Future<Json> getJson(String path, {Map<String, dynamic>? query, CancelToken? cancel}) async {
    final data = await _run(() => dio.get<dynamic>(path, queryParameters: query, cancelToken: cancel));
    return _asJson(data, path);
  }

  Future<List<dynamic>> getList(String path, {Map<String, dynamic>? query, CancelToken? cancel}) async {
    final data = await _run(() => dio.get<dynamic>(path, queryParameters: query, cancelToken: cancel));
    if (data is List) return data;
    throw ContractException('$path: se esperaba una lista');
  }

  /// GET que devuelve `null` con 404: «todavía no hay» (perfil, progreso, audio…).
  Future<Json?> getJsonOrNull(String path, {Map<String, dynamic>? query, CancelToken? cancel}) async {
    try {
      return await getJson(path, query: query, cancel: cancel);
    } on NotFoundFailure {
      return null;
    }
  }

  Future<Json?> send(String method, String path, {Object? body, Map<String, dynamic>? query}) async {
    final data = await _run(
      () => dio.request<dynamic>(
        path,
        data: body,
        queryParameters: query,
        options: Options(method: method),
      ),
    );
    if (data == null || (data is String && data.isEmpty)) return null;
    return _asJson(data, path);
  }

  Future<dynamic> _run(Future<Response<dynamic>> Function() call) async {
    try {
      return (await call()).data;
    } catch (e) {
      throw ApiFailure.from(e);
    }
  }

  Json _asJson(Object? data, String path) {
    if (data is Map) return data.cast<String, dynamic>();
    throw ContractException('$path: se esperaba un objeto');
  }
}
