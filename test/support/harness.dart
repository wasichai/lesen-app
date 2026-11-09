import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:lesen/app/app.dart';
import 'package:lesen/app/config.dart';
import 'package:lesen/app/theme/theme.dart';
import 'package:lesen/core/audio/narration_engine.dart';
import 'package:lesen/features/audio/application/playback_controller.dart';
import 'package:lesen/core/networking/api_client.dart';
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

List<Override> backendOverrides(FakeBackend backend, {SessionStore? store, LocalStore? local, NarrationEngine? engine, Directory? files, bool wifi = true}) => [
  appConfigProvider.overrideWithValue(testConfig),
  httpAdapterProvider.overrideWithValue(backend),
  sessionStoreProvider.overrideWithValue(store ?? MemorySessionStore()),
  localStoreProvider.overrideWithValue(local ?? MemoryLocalStore()),
  narrationEngineProvider.overrideWithValue(engine ?? FakeNarrationEngine()),
  syncIntervalProvider.overrideWithValue(null),
  filesDirProvider.overrideWith((_) async => files),
  wifiCheckProvider.overrideWithValue(() async => wifi),
];

/// La app entera contra un [FakeBackend].
Future<ProviderContainer> pumpLesenApp(
  WidgetTester tester,
  FakeBackend backend, {
  SessionStore? store,
  LocalStore? local,
  NarrationEngine? engine,
  Directory? files,
  Size size = const Size(390, 844),
}) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = size;
  addTearDown(tester.view.reset);
  tester.platformDispatcher.localesTestValue = const [Locale('es', 'ES')];
  tester.platformDispatcher.localeTestValue = const Locale('es', 'ES');
  addTearDown(tester.platformDispatcher.clearAllTestValues);
  final container = ProviderContainer(
    retry: (_, _) => null,
    overrides: backendOverrides(backend, store: store, local: local, engine: engine, files: files),
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
}) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = size;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    ProviderScope(
      retry: (_, _) => null,
      overrides: overrides.isEmpty ? [appConfigProvider.overrideWithValue(testConfig)] : overrides,
      child: MaterialApp(
        theme: buildTheme(Brightness.light),
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
