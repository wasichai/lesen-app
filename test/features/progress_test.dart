import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lesen/app/routing/router.dart';
import 'package:lesen/app/routing/routes.dart';
import 'package:lesen/core/networking/json.dart';
import 'package:lesen/core/notifications/reminders.dart';
import 'package:lesen/core/session/session_store.dart';
import 'package:lesen/features/progress/data/progress_repository.dart';
import 'package:lesen/features/progress/domain/progress.dart';

import '../support/fake_backend.dart';
import '../support/harness.dart';
import 'reader_test.dart' show profileRoute;

/// Respuestas reales del panel capturadas del backend local.
final Map<String, dynamic> progress = (jsonDecode(File('test/fixtures/progress.json').readAsStringSync()) as Map).cast<String, dynamic>();

Map<String, Handler> progressRoutes() => {
  'GET /lesen/progress/dashboard': (_) => progress['dashboard'],
  'GET /lesen/progress/weekly': (_) => progress['weekly'],
  'GET /lesen/progress/achievements': (_) => progress['achievements'],
  'GET /lesen/progress/goals': (_) => progress['goals'],
  'PUT /lesen/progress/goals': (r) => {...(progress['goals'] as Map).cast<String, dynamic>(), ...(r.data as Map).cast<String, dynamic>()},
  'GET /lesen/lists': (_) => <Object>[],
  'POST /lesen/lists': (r) => Reply(201, {'id': 'l1', 'name': (r.data as Map)['name'], 'updatedAt': '2026-11-09T00:00:00Z', 'readings': <Object>[]}),
  'PUT /lesen/lists/l1/readings/der-alte-leuchtturm': (_) => null,
};

void main() {
  test('el panel real: lo medido y lo estimado separados, 28 días, racha semanal', () {
    final d = ProgressRepository.parseDashboard(progress['dashboard'] as Json);
    expect(d.days, hasLength(28));
    expect(d.reading['wordsRead']!.estimated, isTrue);
    expect(d.reading['minutes']!.estimated, isFalse);
    expect(d.vocabulary['learning']!.estimated, isTrue);
    expect(d.vocabulary['saved']!.asInt, 1);
    expect(d.streak.target, 3);
    expect(d.levelKind, MetricKind.ESTIMATED);
    expect(d.recentAchievements.map((a) => a.code), containsAll(['FIRST_WORD', 'FIRST_REVIEW']));
    final w = ProgressRepository.parseWeekly(progress['weekly'] as Json);
    expect(w.days, hasLength(7));
    expect(w.metrics['wordsSaved']!.asInt, 1);
    final all = (progress['achievements'] as List).map((a) => ProgressRepository.achievement(a as Json)).toList();
    expect(all, hasLength(13));
    expect(all.firstWhere((a) => a.code == 'READINGS_5').fraction, 0);
  });

  test('el recordatorio diario cae en la próxima hora local elegida', () {
    final now = DateTime(2026, 11, 9, 20, 30);
    DateTime local(DateTime t) => DateTime.fromMillisecondsSinceEpoch(t.millisecondsSinceEpoch);
    final later = local(nextOccurrence(now, 21, 0));
    expect((later.day, later.hour), (9, 21));
    final tomorrow = local(nextOccurrence(now, 19, 0));
    expect((tomorrow.day, tomorrow.hour), (10, 19));
  });

  Future<(FakeBackend, dynamic)> open(WidgetTester tester, String location, {ReminderScheduler? reminders}) async {
    final backend = FakeBackend({...profileRoute(), ...FakeBackend.readingRoutes('der-alte-leuchtturm'), ...progressRoutes()});
    final container = await pumpLesenApp(tester, backend, store: MemorySessionStore(testSession()), reminders: reminders);
    container.read(routerProvider).go(location);
    await tester.pumpAndSettle();
    return (backend, container);
  }

  testWidgets('el panel dice lo de hoy y la semana sin castigar, y marca lo estimado', (tester) async {
    await open(tester, Routes.progress);
    expect(find.text('0 de 10 min'), findsOneWidget);
    expect(find.text('Unos minutos bastan. Lo que leas hoy suma.'), findsOneWidget);
    expect(find.text('1 de 3 días con lectura'), findsOneWidget);
    expect(find.textContaining('perd'), findsNothing);
    await tester.scrollUntilVisible(find.text('≈ 0'), 300, scrollable: find.byType(Scrollable).last);
    expect(find.text('estimado'), findsWidgets);
  });

  testWidgets('cambiar la meta la envía al backend; el recordatorio pide permiso al activarse', (tester) async {
    final reminders = FakeReminderScheduler();
    final (backend, _) = await open(tester, Routes.progress, reminders: reminders);
    await tester.tap(find.byTooltip('Metas'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(ChoiceChip, '15 min'));
    await tester.pumpAndSettle();
    final put = backend.requests.lastWhere((r) => r.method == 'PUT' && r.path.endsWith('/progress/goals'));
    expect(put.data, {'dailyMinutes': 15});
    expect(reminders.scheduled, isEmpty);
    await tester.scrollUntilVisible(find.text('Recordatorio diario'), 200, scrollable: find.byType(Scrollable).last);
    await tester.tap(find.text('Recordatorio diario'));
    await tester.pumpAndSettle();
    expect(reminders.scheduled.keys, [1]);
    expect(reminders.scheduled[1]!.hour, 19);
  });

  testWidgets('sin permiso de notificaciones, el recordatorio no se programa y se explica', (tester) async {
    final reminders = FakeReminderScheduler()..grant = false;
    await open(tester, Routes.progress, reminders: reminders);
    await tester.tap(find.byTooltip('Metas'));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(find.text('Recordatorio diario'), 200, scrollable: find.byType(Scrollable).last);
    await tester.tap(find.text('Recordatorio diario'));
    await tester.pumpAndSettle();
    expect(reminders.scheduled, isEmpty);
    expect(find.textContaining('Sin permiso para notificaciones'), findsOneWidget);
  });

  testWidgets('los logros: lo conseguido primero, lo demás con su avance', (tester) async {
    await open(tester, Routes.achievements);
    expect(find.text('Primera palabra guardada'), findsOneWidget);
    expect(find.text('0 de 1'), findsWidgets);
  });

  testWidgets('crear una lista desde la ficha y añadir la lectura', (tester) async {
    final (backend, _) = await open(tester, Routes.reading('der-alte-leuchtturm'));
    await tester.ensureVisible(find.text('Añadir a una lista'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Añadir a una lista'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Nueva lista'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Mar');
    await tester.tap(find.text('Crear'));
    await tester.pumpAndSettle();
    expect(backend.requests.where((r) => r.method == 'POST' && r.path == '/lesen/lists').single.data, {'name': 'Mar'});
    expect(backend.count('PUT /lesen/lists/l1/readings/der-alte-leuchtturm'), 1);
  });
}
