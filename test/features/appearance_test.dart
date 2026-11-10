import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lesen/app/routing/router.dart';
import 'package:lesen/app/routing/routes.dart';
import 'package:lesen/app/theme/directions/directions.dart';
import 'package:lesen/app/theme/tokens.dart';
import 'package:lesen/core/session/session_store.dart';
import 'package:lesen/core/storage/local_store.dart';
import 'package:lesen/features/profile/application/appearance_providers.dart';

import '../support/fake_backend.dart';
import '../support/harness.dart';
import 'reader_test.dart' show profileRoute;

void main() {
  group('apariencia guardada', () {
    test('sin nada guardado: Musgo y el modo del sistema', () async {
      final c = createContainerForTest(FakeBackend({}));
      await c.read(appearanceProvider.notifier).loaded;
      expect(c.read(appearanceProvider), const Appearance(direction: DesignDirection.musgo, themeMode: ThemeMode.system));
    });

    test('lo elegido se guarda en el dispositivo y se recupera', () async {
      final local = MemoryLocalStore();
      final c = createContainerForTest(FakeBackend({}), local: local);
      await c.read(appearanceProvider.notifier).loaded;
      await c.read(appearanceProvider.notifier).selectDirection(DesignDirection.gaceta);
      await c.read(appearanceProvider.notifier).selectThemeMode(ThemeMode.dark);
      expect(await local.read('prefs', 'appearance'), {'direction': 'gaceta', 'themeMode': 'dark'});

      final again = createContainerForTest(FakeBackend({}), local: local);
      await again.read(appearanceProvider.notifier).loaded;
      expect(again.read(appearanceProvider), const Appearance(direction: DesignDirection.gaceta, themeMode: ThemeMode.dark));
    });

    test('un valor roto vuelve al de por defecto', () async {
      final local = MemoryLocalStore();
      await local.write('prefs', 'appearance', {'direction': 'botanica', 'themeMode': 42});
      final c = createContainerForTest(FakeBackend({}), local: local);
      await c.read(appearanceProvider.notifier).loaded;
      expect(c.read(appearanceProvider), const Appearance());
      expect(c.read(appearanceProvider).direction, DesignDirection.musgo);
    });
  });

  testWidgets('en el perfil, elegir Gaceta cambia el tema; cada opción mide 48 dp y dice si está elegida', (tester) async {
    final handle = tester.ensureSemantics();
    final local = MemoryLocalStore();
    final container = await pumpLesenApp(tester, FakeBackend(profileRoute()), store: MemorySessionStore(testSession()), local: local);
    container.read(routerProvider).go(Routes.profile);
    await tester.pumpAndSettle();

    LesenTokens tokens() => LesenTokens.of(tester.element(find.text('Apariencia')));
    expect(tokens().surface, DesignDirection.musgo.tokens(Brightness.light).surface);

    final gaceta = find.byWidgetPredicate((w) => w is Semantics && (w.properties.label?.startsWith('Gaceta.') ?? false));
    await tester.scrollUntilVisible(gaceta, 200, scrollable: find.byType(Scrollable).first);
    expect(tester.getSize(gaceta).height, greaterThanOrEqualTo(LesenTokens.target));
    expect(tester.getSemantics(gaceta), isSemantics(isButton: true, isSelected: false));
    await tester.tap(gaceta);
    await tester.pumpAndSettle();

    expect(tokens().surface, DesignDirection.gaceta.tokens(Brightness.light).surface);
    expect(tokens().displayFont, 'Fraunces');
    expect(tester.getSemantics(gaceta), isSemantics(isButton: true, isSelected: true));
    expect(await local.read('prefs', 'appearance'), {'direction': 'gaceta', 'themeMode': 'system'});

    await tester.scrollUntilVisible(find.text('Oscuro'), 200, scrollable: find.byType(Scrollable).first);
    await tester.tap(find.text('Oscuro'));
    await tester.pumpAndSettle();
    expect(tokens().surface, DesignDirection.gaceta.tokens(Brightness.dark).surface);

    await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
    await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
    handle.dispose();
    await closeApp(tester);
  });
}
