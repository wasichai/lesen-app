import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lesen/app/routing/router.dart';
import 'package:lesen/app/routing/routes.dart';
import 'package:lesen/core/session/session_store.dart';

import '../support/fake_backend.dart';
import '../support/harness.dart';
import '../support/notebook_routes.dart';
import 'reader_test.dart' show profileRoute;

void main() {
  Future<(FakeBackend, dynamic)> open(WidgetTester tester, String location, {Map<String, Handler> extra = const {}}) async {
    final backend = FakeBackend({...profileRoute(), ...FakeBackend.readingRoutes('der-alte-leuchtturm'), ...notebookRoutes(), ...extra});
    final container = await pumpLesenApp(tester, backend, store: MemorySessionStore(testSession()));
    container.read(routerProvider).go(location);
    await tester.pumpAndSettle();
    return (backend, container);
  }

  testWidgets('el cuaderno muestra la palabra con su oración y cuántas tocan', (tester) async {
    await open(tester, Routes.vocabulary);
    expect(find.text('verbringen'), findsOneWidget);
    expect(find.text('pasar (tiempo)'), findsOneWidget);
    expect(find.textContaining('Mia verbringt den Sommer'), findsOneWidget);
    expect(find.text('Repasar 1 palabra'), findsOneWidget);
  });

  testWidgets('repasar: mostrar, responder «Bien» y el backend recibe la nota con un clientId', (tester) async {
    final (backend, _) = await open(tester, Routes.review);
    expect(find.text('verbringen'), findsOneWidget);
    expect(find.text('pasar (tiempo)'), findsNothing);
    await tester.tap(find.text('Mostrar la respuesta'));
    await tester.pumpAndSettle();
    expect(find.text('pasar (tiempo)'), findsOneWidget);
    await tester.tap(find.text('Bien'));
    await tester.pumpAndSettle();
    final post = backend.requests.lastWhere((r) => r.path == '/lesen/vocabulary/reviews');
    final body = (post.data as Map).cast<String, dynamic>();
    expect(body['rating'], 'GOOD');
    expect(body['vocabularyId'], '8e7cbcbc-b7c6-499b-b4a7-ffde2dd9ed8a');
    expect(body['clientId'], matches(RegExp(r'^[0-9a-f-]{36}$')));
    expect(find.text('¡Repaso hecho!'), findsOneWidget);
  });

  testWidgets('el diccionario busca y abre la entrada, que se puede marcar como favorita', (tester) async {
    final (backend, _) = await open(tester, Routes.dictionary);
    await tester.enterText(find.byType(TextField), 'licht');
    await tester.pumpAndSettle(const Duration(milliseconds: 400));
    expect(find.text('Licht'), findsOneWidget);
    await tester.tap(find.text('Licht'));
    await tester.pumpAndSettle();
    expect(find.text('1. luz'), findsOneWidget);
    expect(find.text('gender: n'), findsOneWidget);
    await tester.tap(find.byTooltip('Añadir a favoritas'));
    await tester.pumpAndSettle();
    expect(backend.count('PUT /lesen/dictionary/favorites/de:licht'), 1);
  });

  testWidgets('comprensión: responder, enviar y ver cada respuesta explicada con su oración', (tester) async {
    final (backend, _) = await open(tester, Routes.quiz('der-alte-leuchtturm', 1));
    // 1: opción
    expect(find.text('¿Por qué hoy el faro ya no necesita farero?'), findsOneWidget);
    await tester.tap(find.text('Porque la lámpara funciona automáticamente'));
    await tester.pump();
    await tester.tap(find.text('Siguiente'));
    await tester.pumpAndSettle();
    // 2: verdadero o falso
    await tester.tap(find.text('Verdadero'));
    await tester.pump();
    await tester.tap(find.text('Siguiente'));
    await tester.pumpAndSettle();
    // 3: vocabulario en contexto
    await tester.tap(find.text('una llave'));
    await tester.tap(find.text('Siguiente'));
    await tester.pumpAndSettle();
    // 4: completar tocando el banco
    await tester.tap(find.widgetWithText(ActionChip, 'zählt'));
    await tester.pump();
    await tester.tap(find.widgetWithText(ActionChip, 'Stufen'));
    await tester.pump();
    for (var i = 0; i < 3; i++) {
      await tester.tap(find.text('Siguiente'));
      await tester.pumpAndSettle();
    }
    await tester.enterText(find.byType(TextField), 'Mia enciende la luz.');
    await tester.tap(find.text('Enviar respuestas'));
    await tester.pumpAndSettle();
    // quedan dos sin responder (emparejar y ordenar con el orden inicial cuenta como respuesta)
    if (find.byType(AlertDialog).evaluate().isNotEmpty) {
      await tester.tap(find.descendant(of: find.byType(AlertDialog), matching: find.text('Enviar respuestas')));
      await tester.pumpAndSettle();
    }
    final post = backend.requests.lastWhere((r) => r.method == 'POST' && r.path.endsWith('/attempts'));
    final answers = ((post.data as Map)['answers'] as List).cast<Map<String, dynamic>>();
    expect(answers.firstWhere((a) => a['questionId'] == 'q1')['options'], ['b']);
    expect(answers.firstWhere((a) => a['questionId'] == 'q2')['value'], true);
    expect(answers.firstWhere((a) => a['questionId'] == 'q4')['blanks'], {'p2s4t2': 'zählt', 'p2s4t4': 'Stufen'});
    expect(answers.firstWhere((a) => a['questionId'] == 'q7')['text'], 'Mia enciende la luz.');

    // el resultado (el del intento capturado del backend)
    expect(find.text('2 de 7 correctas'), findsOneWidget);
    expect(find.textContaining('la lámpara funciona sola'), findsOneWidget);
    expect(find.textContaining('Heute braucht man keinen Wärter mehr'), findsWidgets);
    await tester.scrollUntilVisible(find.text('Para autoevaluar'), 300, scrollable: find.byType(Scrollable).last);
    expect(find.text('Para autoevaluar'), findsOneWidget);
  });
}
