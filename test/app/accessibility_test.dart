import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lesen/app/routing/router.dart';
import 'package:lesen/app/routing/routes.dart';
import 'package:lesen/app/theme/directions/directions.dart';
import 'package:lesen/core/session/session_store.dart';
import 'package:lesen/features/reader/domain/reader_preferences.dart';
import 'package:lesen/features/reader/presentation/reader_theme.dart';

import '../features/progress_test.dart' show progressRoutes;
import '../features/reader_test.dart' show profileRoute;
import '../support/fake_backend.dart';
import '../support/harness.dart';
import '../support/notebook_routes.dart';

/// Contraste WCAG 2.x entre dos colores opacos.
double contrast(Color a, Color b) {
  double lum(Color c) {
    double ch(double v) => v <= 0.03928 ? v / 12.92 : math.pow((v + 0.055) / 1.055, 2.4).toDouble();
    return 0.2126 * ch(c.r) + 0.7152 * ch(c.g) + 0.0722 * ch(c.b);
  }

  final (l1, l2) = (lum(a), lum(b));
  return (math.max(l1, l2) + 0.05) / (math.min(l1, l2) + 0.05);
}

void main() {
  // las cinco identidades (ADR-0011) cumplen los mismos umbrales
  for (final direction in DesignDirection.values) {
    group('contraste AA de los tokens, ${direction.label} (como lesen-ui/src/theme/lesen.test.ts)', () {
      for (final (name, t) in [('claro', direction.tokens(Brightness.light)), ('oscuro', direction.tokens(Brightness.dark))]) {
        test(name, () {
          expect(contrast(t.ink, t.surface), greaterThanOrEqualTo(7), reason: 'tinta sobre papel');
          expect(contrast(t.inkMuted, t.surface), greaterThanOrEqualTo(4.5), reason: 'texto secundario');
          expect(contrast(t.brand, t.surface), greaterThanOrEqualTo(4.5), reason: 'acento como texto');
          expect(contrast(t.ink, t.markSaved), greaterThanOrEqualTo(4.5), reason: 'palabra guardada');
          expect(contrast(t.brandStrong, t.brandSoft), greaterThanOrEqualTo(4.5), reason: 'insignias');
        });
      }
      for (final theme in ReaderTheme.values) {
        test('lector ${theme.name}', () {
          final p = ReaderPalette.of(theme, direction: direction);
          expect(contrast(p.ink, p.paper), greaterThanOrEqualTo(7));
          expect(contrast(p.inkMuted, p.paper), greaterThanOrEqualTo(4.5));
          expect(contrast(p.ink, p.saved), greaterThanOrEqualTo(4.5));
          expect(contrast(p.ink, p.active), greaterThanOrEqualTo(4.5));
          expect(contrast(p.ink, p.sentence), greaterThanOrEqualTo(4.5));
        });
      }
    });
  }

  final routes = {...profileRoute(), ...FakeBackend.readingRoutes('der-alte-leuchtturm'), ...notebookRoutes(), ...progressRoutes()};

  for (final direction in DesignDirection.values) {
    final suffix = direction == DesignDirection.papel ? '' : ' (${direction.label})';
    for (final (name, location) in [
      ('Descubrir', Routes.discover),
      ('catálogo', Routes.catalog),
      ('ficha', Routes.reading('der-alte-leuchtturm')),
      ('lector', Routes.reader('der-alte-leuchtturm')),
      ('vocabulario', Routes.vocabulary),
      ('progreso', Routes.progress),
    ]) {
      testWidgets('$name$suffix: objetivos táctiles y etiquetas', (tester) async {
        final handle = tester.ensureSemantics();
        final container = await pumpLesenApp(tester, FakeBackend(routes), store: MemorySessionStore(testSession()), direction: direction);
        container.read(routerProvider).go(location);
        await tester.pumpAndSettle();
        await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
        await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
        await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
        handle.dispose();
        await closeApp(tester);
      });

      testWidgets('$name$suffix: con el texto al 200 % nada se desborda', (tester) async {
        tester.platformDispatcher.textScaleFactorTestValue = 2;
        addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
        final container = await pumpLesenApp(tester, FakeBackend(routes), store: MemorySessionStore(testSession()), direction: direction);
        container.read(routerProvider).go(location);
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        await closeApp(tester);
      });
    }
  }
}
