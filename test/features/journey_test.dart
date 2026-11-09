import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lesen/core/session/session_store.dart';

import '../support/fake_backend.dart';
import '../support/harness.dart';

void main() {
  testWidgets('entrar, completar el onboarding y llegar a Descubrir', (tester) async {
    Map<String, dynamic>? saved;
    final backend = FakeBackend({
      'PUT /lesen/learner/profile': (r) {
        saved = (r.data as Map).cast<String, dynamic>();
        return {...saved!, 'createdAt': '2026-11-09T00:00:00Z', 'updatedAt': '2026-11-09T00:00:00Z'};
      },
    });
    await pumpLesenApp(tester, backend);

    expect(find.text('Aprende un idioma leyendo'), findsOneWidget);
    await tester.enterText(find.byType(TextFormField).at(0), 'tomas@demo.lesen.test');
    await tester.enterText(find.byType(TextFormField).at(1), 'secreto');
    await tester.tap(find.text('Entrar'));
    await tester.pumpAndSettle();

    // paso 1: idioma de la interfaz
    expect(find.text('Paso 1 de 5'), findsOneWidget);
    await tester.tap(find.text('Continuar'));
    await tester.pumpAndSettle();
    // paso 2: idioma de estudio (sin el de la interfaz)
    expect(find.text('Español'), findsNothing);
    await tester.tap(find.text('Deutsch'));
    await tester.tap(find.text('Continuar'));
    await tester.pumpAndSettle();
    // paso 3: nivel
    expect(find.text('¿Cómo lees en Deutsch hoy?'), findsOneWidget);
    await tester.tap(find.text('B1'));
    await tester.tap(find.text('Continuar'));
    await tester.pumpAndSettle();
    // paso 4: metas y temas
    await tester.tap(find.text('Viajar'));
    await tester.pump();
    await tester.tap(find.text('Naturaleza'));
    await tester.tap(find.text('Continuar'));
    await tester.pumpAndSettle();
    // paso 5: ritmo
    await tester.tap(find.text('15 min'));
    await tester.tap(find.text('Empezar a leer'));
    await tester.pumpAndSettle();

    expect(saved, isNotNull);
    expect(saved!['interfaceLanguage'], 'es');
    expect(saved!['targetLanguage'], 'de');
    expect(saved!['level'], 'B1');
    expect(saved!['levelEstimated'], false);
    expect(saved!['goals'], ['TRAVEL']);
    expect(saved!['topics'], ['nature']);
    expect(saved!['dailyMinutes'], 15);

    expect(find.textContaining(', Tomás'), findsOneWidget);
    expect(find.text('DESTACADA'), findsOneWidget);
    expect(find.byType(NavigationBar), findsOneWidget);
    expect(backend.requests.where((r) => r.path == '/lesen/discover').every((r) => r.headers['Authorization'] == 'Bearer token-de-prueba'), isTrue);
  });

  testWidgets('con perfil, Descubrir; en tableta, raíl de navegación', (tester) async {
    final backend = FakeBackend({
      'GET /lesen/learner/profile': (_) => {
        'interfaceLanguage': 'en',
        'targetLanguage': 'de',
        'level': 'A2',
        'levelEstimated': false,
        'goals': <String>[],
        'topics': <String>[],
        'dailyMinutes': 10,
        'difficulty': 'BALANCED',
      },
    });
    await pumpLesenApp(tester, backend, store: MemorySessionStore(testSession()), size: const Size(1024, 768));
    expect(find.byType(NavigationRail), findsOneWidget);
    expect(find.byType(NavigationBar), findsNothing);
    // la interfaz sigue el idioma del perfil
    expect(find.text('FEATURED'), findsOneWidget);
    expect(find.text('Discover'), findsWidgets);
  });

  testWidgets('el catálogo pide la consulta y muestra el total', (tester) async {
    final backend = FakeBackend({
      'GET /lesen/learner/profile': (_) => {
        'interfaceLanguage': 'es',
        'targetLanguage': 'de',
        'level': 'A2',
        'levelEstimated': false,
        'goals': <String>[],
        'topics': <String>[],
        'dailyMinutes': 10,
        'difficulty': 'BALANCED',
      },
    });
    await pumpLesenApp(tester, backend, store: MemorySessionStore(testSession()));
    await tester.tap(find.byTooltip('Buscar'));
    await tester.pumpAndSettle();
    expect(find.text('11 lecturas'), findsOneWidget);
    await tester.tap(find.widgetWithText(FilterChip, 'A1'));
    await tester.pumpAndSettle();
    final last = backend.requests.lastWhere((r) => r.path == '/lesen/readings');
    expect(last.queryParameters['level'], ['A1']);
    expect(last.queryParameters['page'], 0);
  });

  testWidgets('sin red, Descubrir lo dice y ofrece reintentar', (tester) async {
    final backend = FakeBackend({
      'GET /lesen/learner/profile': (_) => {
        'interfaceLanguage': 'es',
        'targetLanguage': 'de',
        'level': 'A2',
        'levelEstimated': false,
        'goals': <String>[],
        'topics': <String>[],
        'dailyMinutes': 10,
        'difficulty': 'BALANCED',
      },
      'GET /lesen/discover': (_) => const Reply(503, {'status': 503}),
    });
    await pumpLesenApp(tester, backend, store: MemorySessionStore(testSession()));
    expect(find.textContaining('Algo falló en el servidor'), findsOneWidget);
    expect(find.text('Reintentar'), findsOneWidget);
  });
}
