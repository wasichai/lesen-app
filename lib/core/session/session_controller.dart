import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../networking/api_client.dart';
import '../networking/api_failure.dart';
import '../networking/json.dart';
import '../storage/local_store.dart';
import 'session.dart';
import 'session_store.dart';

enum SessionStatus { restoring, signedOut, signedIn }

enum SignOutReason { none, expired, manual }

class SessionState {
  const SessionState._(this.status, this.session, this.reason);

  const SessionState.restoring() : this._(SessionStatus.restoring, null, SignOutReason.none);
  const SessionState.signedOut([SignOutReason reason = SignOutReason.none]) : this._(SessionStatus.signedOut, null, reason);
  const SessionState.signedIn(Session session) : this._(SessionStatus.signedIn, session, SignOutReason.none);

  final SessionStatus status;
  final Session? session;
  final SignOutReason reason;
}

final sessionStoreProvider = Provider<SessionStore>((ref) => SecureSessionStore());

/// Cliente HTTP sin interceptor de sesión, solo para entrar (evita la dependencia circular con `dioProvider`).
final authDioProvider = Provider<Dio>((ref) {
  final config = ref.watch(appConfigProvider);
  final dio = Dio(BaseOptions(baseUrl: '${config.apiBaseUrl}/api', connectTimeout: const Duration(seconds: 10), receiveTimeout: const Duration(seconds: 20)));
  final adapter = ref.watch(httpAdapterProvider);
  if (adapter != null) dio.httpClientAdapter = adapter;
  return dio;
});

final sessionControllerProvider = NotifierProvider<SessionController, SessionState>(SessionController.new);

class SessionController extends Notifier<SessionState> {
  DateTime Function() now = DateTime.now;

  @override
  SessionState build() {
    _restore();
    return const SessionState.restoring();
  }

  Future<void> _restore() async {
    final stored = await ref.read(sessionStoreProvider).read();
    if (stored == null) {
      state = const SessionState.signedOut();
    } else if (stored.isExpired(now())) {
      await ref.read(sessionStoreProvider).clear();
      state = const SessionState.signedOut(SignOutReason.expired);
    } else {
      state = SessionState.signedIn(stored);
    }
  }

  /// `POST /api/auth/login` y luego `GET /api/auth/me/permissions`. Lanza [ApiFailure].
  Future<void> signIn(String email, String password) async {
    final dio = ref.read(authDioProvider);
    try {
      final login = await dio.post<Map<String, dynamic>>('/auth/login', data: {'email': email.trim(), 'password': password});
      var session = Session.fromJson(login.data!);
      final perms = await dio.get<Map<String, dynamic>>('/auth/me/permissions', options: Options(headers: {'Authorization': 'Bearer ${session.token}'}));
      final objects = (perms.data ?? const {}).cast<String, dynamic>().objOrNull('objects') ?? const {};
      session = session.withObjects(objects.map((k, v) => MapEntry(k, (v as List).map((e) => e.toString()).toSet())));
      await ref.read(sessionStoreProvider).write(session);
      state = SessionState.signedIn(session);
    } catch (e) {
      throw ApiFailure.from(e);
    }
  }

  /// La sesión caducó o el servidor la rechazó: se vuelve al login conservando lo pendiente.
  Future<void> expire() async {
    if (state.status != SessionStatus.signedIn) return;
    await ref.read(sessionStoreProvider).clear();
    state = const SessionState.signedOut(SignOutReason.expired);
  }

  /// Espacios locales con datos de quien lee; el contenido publicado (público e inmutable) se conserva.
  static const personalNamespaces = ['progress', 'prefs'];

  Future<void> signOut() async {
    await ref.read(sessionStoreProvider).clear();
    await ref.read(localStoreProvider).clearNamespaces(personalNamespaces);
    state = const SessionState.signedOut(SignOutReason.manual);
  }
}
