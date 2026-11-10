// Goldens de las direcciones de diseño (docs/design/README.md): las mismas pantallas en «Papel y tinta» y en cada
// exploración, con las fuentes reales, para compararlas lado a lado. Se generan con
// `flutter test --tags design --run-skipped --update-goldens`.
@Tags(['design'])
library;

import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:lesen/app/app.dart';
import 'package:lesen/app/design_lab/explore_fonts.dart';
import 'package:lesen/app/routing/router.dart';
import 'package:lesen/app/routing/routes.dart';
import 'package:lesen/app/theme/explorations/directions.dart';
import 'package:lesen/core/audio/narration_engine.dart';
import 'package:lesen/core/session/session_store.dart';

import '../features/progress_test.dart' show progressRoutes;
import '../features/reader_test.dart' show profileRoute;
import '../support/fake_backend.dart';
import '../support/harness.dart';
import '../support/notebook_routes.dart';

const slug = 'der-alte-leuchtturm';
const phone = Size(390, 844);
const tablet = Size(1024, 768);

Future<ByteData> _file(String path) async => ByteData.sublistView(await File(path).readAsBytes());

/// Las fuentes de verdad en lugar de la de pruebas: las de serie, las de exploración y los iconos de Material.
Future<void> loadRealFonts() async {
  for (final (family, files) in [
    ('Newsreader', ['Newsreader.ttf', 'Newsreader-Italic.ttf']),
    ('SourceSans3', ['SourceSans3.ttf', 'SourceSans3-Italic.ttf']),
  ]) {
    final loader = FontLoader(family);
    for (final f in files) {
      loader.addFont(_file('assets/fonts/$f'));
    }
    await loader.load();
  }
  for (final d in DesignDirection.values) {
    await loadExploreFonts(d, load: _file);
  }
  final icons = File('${Platform.environment['FLUTTER_ROOT']}/bin/cache/artifacts/material_fonts/MaterialIcons-Regular.otf');
  if (icons.existsSync()) await (FontLoader('MaterialIcons')..addFont(_file(icons.path))).load();
}

/// Una pantalla: cómo llegar a ella desde la app ya abierta.
typedef Scene = Future<void> Function(WidgetTester tester, GoRouter router, FakeNarrationEngine engine);

Scene go(String location) => (tester, router, _) async {
  router.go(location);
  await tester.pumpAndSettle();
};

Future<void> _openWord(WidgetTester tester, GoRouter router, FakeNarrationEngine engine) async {
  await go(Routes.reader(slug))(tester, router, engine);
  await tester.tapOnText(find.textRange.ofSubstring('verbringt'));
  await tester.pumpAndSettle();
}

Future<void> _play(WidgetTester tester, GoRouter router, FakeNarrationEngine engine) async {
  await go(Routes.reader(slug))(tester, router, engine);
  await tester.tap(find.byTooltip('Escuchar'));
  await tester.pumpAndSettle();
}

final phoneScenes = <String, Scene>{
  'discover': go(Routes.discover),
  'catalog': go(Routes.catalog),
  'detail': go(Routes.reading(slug)),
  'reader': go(Routes.reader(slug)),
  'word_panel': _openWord,
  'mini_player': (tester, router, engine) async {
    await _play(tester, router, engine);
    await go(Routes.vocabulary)(tester, router, engine);
  },
  'player': (tester, router, engine) async {
    await _play(tester, router, engine);
    await go(Routes.player)(tester, router, engine);
    // A 390 dp, los siete controles de TransportRow (360 dp) no caben en los 342 dp del reproductor y la fila se
    // desborda, con cualquier dirección: es un fallo previo al laboratorio, que el golden deja a la vista.
    final overflow = tester.takeException();
    if (overflow != null) expect('$overflow', contains('overflowed'));
  },
  'vocabulary': go(Routes.vocabulary),
  'progress': go(Routes.progress),
};

final tabletScenes = <String, Scene>{'discover': go(Routes.discover), 'reader_panel': _openWord, 'progress': go(Routes.progress)};

void main() {
  setUpAll(loadRealFonts);
  final routes = {...profileRoute(), ...FakeBackend.readingRoutes(slug), ...notebookRoutes(), ...progressRoutes()};

  Future<void> shoot(WidgetTester tester, DesignDirection d, Brightness b, Size size, String name, Scene scene) async {
    final engine = FakeNarrationEngine();
    final container = await pumpLesenApp(
      tester,
      FakeBackend(routes),
      store: MemorySessionStore(testSession()),
      engine: engine,
      size: size,
      direction: d,
      brightness: b,
    );
    await scene(tester, container.read(routerProvider), engine);
    final device = size == phone ? 'phone' : 'tablet';
    await expectLater(find.byType(LesenApp), matchesGoldenFile('goldens/${d.name}/${device}_${b.name}_$name.png'));
    await closeApp(tester);
  }

  for (final d in DesignDirection.values) {
    group(d.label, () {
      for (final b in Brightness.values) {
        for (final MapEntry(key: name, value: scene) in phoneScenes.entries) {
          testWidgets('teléfono ${b.name}: $name', (tester) => shoot(tester, d, b, phone, name, scene));
        }
      }
      for (final MapEntry(key: name, value: scene) in tabletScenes.entries) {
        testWidgets('tableta light: $name', (tester) => shoot(tester, d, Brightness.light, tablet, name, scene));
      }
    });
  }
}
