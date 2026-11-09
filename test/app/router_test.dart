import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lesen/app/routing/router.dart';
import 'package:lesen/app/routing/routes.dart';
import 'package:lesen/core/session/session_controller.dart';
import 'package:lesen/features/catalog/domain/reading.dart';

void main() {
  String? go(SessionStatus s, AsyncValue<Object?> p, String location) => decideRedirect(session: s, profile: p, location: Uri.parse(location));

  test('sin sesión todo lleva al login, recordando a dónde se iba', () {
    expect(
      go(SessionStatus.signedOut, const AsyncData(null), Routes.reading('der-alte-leuchtturm')),
      '/login?from=%2Fdiscover%2Freadings%2Fder-alte-leuchtturm',
    );
    expect(go(SessionStatus.signedOut, const AsyncData(null), Routes.login), isNull);
  });

  test('con sesión y sin perfil, al onboarding', () {
    expect(go(SessionStatus.signedIn, const AsyncData(null), Routes.discover), Routes.onboarding);
    expect(go(SessionStatus.signedIn, const AsyncData(null), Routes.onboarding), isNull);
  });

  test('con perfil, el login vuelve a la ruta pedida y el onboarding solo en modo edición', () {
    const p = AsyncData<Object?>('perfil');
    expect(go(SessionStatus.signedIn, p, '/login?from=%2Fdiscover%2Fcatalog'), Routes.catalog);
    expect(go(SessionStatus.signedIn, p, Routes.onboarding), Routes.discover);
    expect(go(SessionStatus.signedIn, p, Routes.editProfile()), isNull);
  });

  test('nunca redirige fuera de la app', () {
    expect(go(SessionStatus.signedIn, const AsyncData<Object?>('p'), '/login?from=%2F%2Fevil.example'), Routes.discover);
    expect(go(SessionStatus.signedIn, const AsyncData<Object?>('p'), '/login?from=https%3A%2F%2Fevil.example'), Routes.discover);
  });

  test('mientras se restaura la sesión o carga el perfil, la pantalla de arranque', () {
    expect(go(SessionStatus.restoring, const AsyncLoading(), Routes.discover), startsWith(Routes.splash));
    expect(go(SessionStatus.signedIn, const AsyncLoading(), Routes.discover), startsWith(Routes.splash));
  });

  test('un enlace profundo lesen://app/… se trata como su ruta y pasa por las mismas guardas', () {
    final uri = Uri.parse('lesen://app/discover/readings/der-alte-leuchtturm');
    expect(uri.path, Routes.reading('der-alte-leuchtturm'));
    expect(go(SessionStatus.signedOut, const AsyncData(null), uri.toString()), startsWith('/login?from='));
  });

  test('filtros desde la URL y slugs válidos', () {
    final q = catalogQueryFrom(Uri.parse(Routes.catalogWith(level: 'B1', language: 'de')));
    expect(q.levels, {CefrLevel.B1});
    expect(q.language, 'de');
    expect(Routes.slugPattern.hasMatch('der-alte-leuchtturm'), isTrue);
    expect(Routes.slugPattern.hasMatch('../etc/passwd'), isFalse);
  });
}
