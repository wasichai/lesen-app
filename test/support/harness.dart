import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:lesen/app/app.dart';
import 'package:lesen/app/config.dart';
import 'package:lesen/app/design_lab/design_lab.dart';
import 'package:lesen/app/theme/explorations/directions.dart';
import 'package:lesen/app/theme/theme.dart';
import 'package:lesen/core/audio/narration_engine.dart';
import 'package:lesen/features/audio/application/playback_controller.dart';
import 'package:lesen/core/networking/api_client.dart';
import 'package:lesen/core/notifications/reminders.dart';
import 'package:lesen/core/session/session.dart';
import 'package:lesen/core/session/session_controller.dart';
import 'package:lesen/core/session/session_store.dart';
import 'package:lesen/core/storage/files.dart';
import 'package:lesen/core/storage/local_store.dart';
import 'package:lesen/core/sync/sync.dart';
import 'package:lesen/features/downloads/application/downloads_controller.dart';
import 'package:lesen/l10n/app_localizations.dart';

import 'fake_backend.dart';

const testConfig = AppConfig(environment: 'test', apiBaseUrl: 'http://lesen.test');

Session testSession() => Session.fromJson({
  'token': 'token-de-prueba',
  'expiresAt': DateTime.now().add(const Duration(hours: 8)).toUtc().toIso8601String(),
  'user': {
    'id': 'u1',
    'email': 'lena@demo.lesen.test',
    'displayName': 'Lena',
    'roles': ['LECTOR'],
  },
  'objects': {
    'lectura': ['READ'],
    'cuaderno': ['READ', 'UPDATE'],
  },
});

List<Override> backendOverrides(
  FakeBackend backend, {
  SessionStore? store,
  LocalStore? local,
  NarrationEngine? engine,
  Directory? files,
  bool wifi = true,
  ReminderScheduler? reminders,
  AppConfig config = testConfig,
}) => [
  appConfigProvider.overrideWithValue(config),
  httpAdapterProvider.overrideWithValue(backend),
  sessionStoreProvider.overrideWithValue(store ?? MemorySessionStore()),
  localStoreProvider.overrideWithValue(local ?? MemoryLocalStore()),
  narrationEngineProvider.overrideWithValue(engine ?? FakeNarrationEngine()),
  syncIntervalProvider.overrideWithValue(null),
  filesDirProvider.overrideWith((_) async => files),
  wifiCheckProvider.overrideWithValue(() async => wifi),
  reminderSchedulerProvider.overrideWithValue(reminders ?? FakeReminderScheduler()),
];

/// Fija la dirección de diseño y el brillo sin pasar por el laboratorio; con los valores por defecto no cambia nada.
List<Override> designOverrides(DesignDirection direction, Brightness? brightness) => [
  if (direction != DesignDirection.actual) designDirectionProvider.overrideWith(() => DesignDirectionController(direction)),
  if (brightness != null)
    designThemeModeProvider.overrideWith(() => DesignThemeModeController(brightness == Brightness.dark ? ThemeMode.dark : ThemeMode.light)),
];

/// La app entera contra un [FakeBackend], en «Papel y tinta» o en la dirección de diseño [direction].
Future<ProviderContainer> pumpLesenApp(
  WidgetTester tester,
  FakeBackend backend, {
  SessionStore? store,
  LocalStore? local,
  NarrationEngine? engine,
  Directory? files,
  ReminderScheduler? reminders,
  Size size = const Size(390, 844),
  DesignDirection direction = DesignDirection.actual,
  Brightness? brightness,
  AppConfig config = testConfig,
}) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = size;
  addTearDown(tester.view.reset);
  tester.platformDispatcher.localesTestValue = const [Locale('es', 'ES')];
  tester.platformDispatcher.localeTestValue = const Locale('es', 'ES');
  addTearDown(tester.platformDispatcher.clearAllTestValues);
  final container = ProviderContainer(
    retry: (_, _) => null,
    overrides: [
      ...backendOverrides(backend, store: store, local: local, engine: engine, files: files, reminders: reminders, config: config),
      ...designOverrides(direction, brightness),
    ],
  );
  addTearDown(container.dispose);
  await tester.pumpWidget(UncontrolledProviderScope(container: container, child: const LesenApp()));
  await tester.pumpAndSettle();
  return container;
}

/// Un widget suelto con tema, localización (es) y proveedores.
Future<void> pumpWidgetUnderTest(
  WidgetTester tester,
  Widget child, {
  List<Override> overrides = const [],
  Size size = const Size(390, 844),
  Locale locale = const Locale('es'),
  DesignDirection direction = DesignDirection.actual,
  Brightness brightness = Brightness.light,
}) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = size;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    ProviderScope(
      retry: (_, _) => null,
      overrides: [
        ...(overrides.isEmpty ? [appConfigProvider.overrideWithValue(testConfig)] : overrides),
        ...designOverrides(direction, null),
      ],
      child: MaterialApp(
        theme: buildTheme(brightness, tokens: direction.tokens(brightness)),
        locale: locale,
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: Scaffold(body: child),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

/// Un contenedor sin widgets para probar repositorios contra el [FakeBackend].
ProviderContainer createContainerForTest(FakeBackend backend, {NarrationEngine? engine, LocalStore? local, Directory? files, bool wifi = true}) {
  final c = ProviderContainer(
    retry: (_, _) => null,
    overrides: backendOverrides(backend, engine: engine, local: local, files: files, wifi: wifi),
  );
  addTearDown(c.dispose);
  return c;
}

/// Desmonta la app y deja terminar sus últimos guardados (el lector guarda al salir).
Future<void> closeApp(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox());
  await tester.pump(const Duration(seconds: 30));
}
