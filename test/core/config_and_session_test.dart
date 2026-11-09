import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lesen/app/config.dart';
import 'package:lesen/core/networking/api_failure.dart';
import 'package:lesen/core/session/session.dart';
import 'package:lesen/core/session/session_controller.dart';
import 'package:lesen/core/session/session_store.dart';

import '../support/fake_backend.dart';
import '../support/harness.dart';

void main() {
  test('las URL relativas del backend se resuelven contra su origen', () {
    const config = AppConfig(environment: 'dev', apiBaseUrl: 'http://10.0.2.2:8095');
    expect(config.resolve('/api/lesen/public/covers/x.svg'), 'http://10.0.2.2:8095/api/lesen/public/covers/x.svg');
    expect(config.resolve('https://cdn.example/x.svg'), 'https://cdn.example/x.svg');
  });

  test('la sesión se serializa y conserva permisos', () {
    final s = testSession();
    final back = Session.decode(s.encode());
    expect(back.token, s.token);
    expect(back.user.firstName, 'Lena');
    expect(back.canRead, isTrue);
    expect(back.canWriteNotebook, isTrue);
  });

  group('SessionController', () {
    Future<ProviderContainer> container(FakeBackend backend, SessionStore store) async {
      final c = ProviderContainer(
        retry: (_, _) => null,
        overrides: backendOverrides(backend, store: store),
      );
      addTearDown(c.dispose);
      c.read(sessionControllerProvider);
      await Future<void>.delayed(Duration.zero);
      return c;
    }

    test('entra, guarda la sesión en el almacén seguro y lee los permisos', () async {
      final backend = FakeBackend();
      final store = MemorySessionStore();
      final c = await container(backend, store);
      expect(c.read(sessionControllerProvider).status, SessionStatus.signedOut);
      await c.read(sessionControllerProvider.notifier).signIn(' tomas@demo.lesen.test ', 'secreto');
      expect(c.read(sessionControllerProvider).status, SessionStatus.signedIn);
      expect((await store.read())!.hasNotebook, isTrue);
      expect(backend.requests.first.data, {'email': 'tomas@demo.lesen.test', 'password': 'secreto'});
      expect(backend.requests[1].headers['Authorization'], 'Bearer token-de-prueba');
    });

    test('credenciales malas: UnauthorizedFailure y sin sesión', () async {
      final backend = FakeBackend({
        'POST /auth/login': (_) => const Reply(401, {'status': 401, 'detail': 'Bad credentials'}),
      });
      final c = await container(backend, MemorySessionStore());
      await expectLater(c.read(sessionControllerProvider.notifier).signIn('a@b.c', 'x'), throwsA(isA<UnauthorizedFailure>()));
      expect(c.read(sessionControllerProvider).status, SessionStatus.signedOut);
    });

    test('una sesión guardada y caducada no se restaura', () async {
      final expired = Session.fromJson({...testSession().toJson(), 'expiresAt': '2020-01-01T00:00:00Z'});
      final c = await container(FakeBackend(), MemorySessionStore(expired));
      expect(c.read(sessionControllerProvider).status, SessionStatus.signedOut);
      expect(c.read(sessionControllerProvider).reason, SignOutReason.expired);
    });

    test('un 401 con sesión la cierra como caducada', () async {
      final backend = FakeBackend({'GET /lesen/discover': (_) => const Reply(401)});
      final store = MemorySessionStore(testSession());
      final c = await container(backend, store);
      expect(c.read(sessionControllerProvider).status, SessionStatus.signedIn);
      await c.read(sessionControllerProvider.notifier).expire();
      expect(c.read(sessionControllerProvider).reason, SignOutReason.expired);
      expect(await store.read(), isNull);
    });
  });
}
