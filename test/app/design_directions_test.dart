import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lesen/app/config.dart';
import 'package:lesen/app/design_lab/design_lab.dart';
import 'package:lesen/app/design_lab/explore_fonts.dart';
import 'package:lesen/app/theme/explorations/directions.dart';
import 'package:lesen/app/theme/theme.dart';
import 'package:lesen/app/theme/tokens.dart';
import 'package:lesen/core/networking/api_client.dart';
import 'package:lesen/core/session/session_store.dart';
import 'package:lesen/features/reader/domain/reader_preferences.dart';
import 'package:lesen/features/reader/presentation/reader_theme.dart';

import '../features/reader_test.dart' show profileRoute;
import '../support/fake_backend.dart';
import '../support/harness.dart';

/// Los colores de un tema resueltos como `resolveTheme` de `lesen-ui/scripts/design-directions.mjs`: las anclas de
/// `light` o `dark` y, encima, las del papel del lector.
Map<String, dynamic> resolve(Map<String, dynamic> json, String base, [String? extra]) {
  final color = json['color'] as Map<String, dynamic>;
  return {...color[base] as Map<String, dynamic>, if (extra != null) ...color[extra] as Map<String, dynamic>};
}

Color hex(Object? value) => Color(int.parse('FF${(value! as String).substring(1)}', radix: 16));

/// La primera familia de la pila CSS, sin espacios: así se llaman en Flutter (`'Source Serif 4'` → `SourceSerif4`).
String family(Object? stack) => RegExp("'([^']+)'").firstMatch(stack! as String)!.group(1)!.replaceAll(' ', '');

double px(Object? value) => double.parse((value! as String).replaceAll('px', ''));

double em(Object? value) => double.parse(((value as String?) ?? '0em').replaceAll('em', ''));

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('el laboratorio', () {
    ProviderContainer containerFor(String env) {
      final c = ProviderContainer(
        overrides: [appConfigProvider.overrideWithValue(AppConfig(environment: env, apiBaseUrl: 'http://lesen.test'))],
      );
      addTearDown(c.dispose);
      return c;
    }

    test('fuera de dev no cambia nada', () async {
      final c = containerFor('staging');
      expect(designLabEnabled(c.read(appConfigProvider)), isFalse);
      await c.read(designDirectionProvider.notifier).select(DesignDirection.pulso);
      c.read(designThemeModeProvider.notifier).select(ThemeMode.dark);
      expect(c.read(designDirectionProvider), DesignDirection.actual);
      expect(c.read(designThemeModeProvider), ThemeMode.system);
    });

    test('en dev cambia de dirección y de modo, aunque falten las fuentes (caen en la de reserva)', () async {
      final c = containerFor('dev');
      await c.read(designDirectionProvider.notifier).select(DesignDirection.gaceta);
      c.read(designThemeModeProvider.notifier).select(ThemeMode.dark);
      expect(c.read(designDirectionProvider), DesignDirection.gaceta);
      expect(c.read(designThemeModeProvider), ThemeMode.dark);
    });
  });

  testWidgets('en dev, el botón del laboratorio abre la hoja y la dirección elegida llega al tema', (tester) async {
    const dev = AppConfig(environment: 'dev', apiBaseUrl: 'http://lesen.test');
    final handle = tester.ensureSemantics();
    await pumpLesenApp(tester, FakeBackend(profileRoute()), store: MemorySessionStore(testSession()), config: dev);
    expect(find.bySemanticsLabel('Laboratorio de diseño'), findsOneWidget);
    await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
    await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
    await tester.tap(find.byIcon(Icons.palette_outlined));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Atlas'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Oscuro'));
    await tester.pumpAndSettle();
    final tokens = LesenTokens.of(tester.element(find.text('Dirección de diseño')));
    expect(tokens.interfaceFont, 'Geist');
    expect(tokens.surface, DesignDirection.atlas.tokens(Brightness.dark).surface);
    handle.dispose();
    await closeApp(tester);
  });

  testWidgets('fuera de dev no hay botón', (tester) async {
    await pumpLesenApp(tester, FakeBackend(profileRoute()), store: MemorySessionStore(testSession()));
    expect(find.bySemanticsLabel('Laboratorio de diseño'), findsNothing);
    await closeApp(tester);
  });

  test('«Papel y tinta» sigue igual: buildTheme sin tokens es el de la dirección actual', () {
    for (final b in Brightness.values) {
      expect(DesignDirection.actual.tokens(b), same(b == Brightness.light ? LesenTokens.light : LesenTokens.dark));
      expect(buildTheme(b).extension<LesenTokens>(), buildTheme(b, tokens: DesignDirection.actual.tokens(b)).extension<LesenTokens>());
    }
    for (final theme in ReaderTheme.values) {
      expect(ReaderPalette.of(theme).paper, ReaderPalette.of(theme, direction: DesignDirection.actual).paper);
      expect(ReaderPalette.of(theme).tokens, isNull);
    }
  });

  test('copyWith cambia solo lo que se le pide', () {
    final t = LesenTokens.light.copyWith(brand: const Color(0xFF000000), buttonRadius: 9999, readingFont: 'Literata');
    expect(t.brand, const Color(0xFF000000));
    expect(t.buttonRadius, 9999);
    expect(t.readingFont, 'Literata');
    expect(t.ink, LesenTokens.light.ink);
    expect(t.radiusCard, LesenTokens.light.radiusCard);
  });

  for (final direction in DesignDirection.values.where((d) => d != DesignDirection.actual)) {
    group('paridad con test/fixtures/design/${direction.name}.json', () {
      final json = jsonDecode(File('test/fixtures/design/${direction.name}.json').readAsStringSync()) as Map<String, dynamic>;

      for (final (base, brightness) in [('light', Brightness.light), ('dark', Brightness.dark)]) {
        test('tokens $base', () {
          final c = resolve(json, base);
          final t = direction.tokens(brightness);
          expect(t.surface, hex(c['surface']));
          expect(t.surfaceMuted, hex(c['surface-muted']));
          expect(t.surfaceRaised, hex(c['surface-raised']));
          expect(t.ink, hex(c['ink']));
          expect(t.inkMuted, hex(c['ink-muted']));
          expect(t.brand, hex(c['brand']));
          expect(t.brandStrong, hex(c['brand-strong']));
          expect(t.brandSoft, hex(c['brand-soft']));
          expect(t.onBrand, hex(c['on-brand']));
          expect(t.focus, hex(c['focus']));
          expect(t.markSaved, hex(c['mark-saved']));
          expect(t.markNew, hex(c['mark-new']));
          expect(t.markSentence, hex(c['mark-sentence']));
          expect(t.tones, [
            for (final k in ['sea', 'sage', 'ochre', 'plum']) hex(c[k]),
          ]);
        });
      }

      for (final (theme, base, extra) in [
        (ReaderTheme.light, 'light', 'reader-light'),
        (ReaderTheme.sepia, 'light', 'reader-sepia'),
        (ReaderTheme.dark, 'dark', 'reader-dark'),
      ]) {
        test('lector ${theme.name}', () {
          final c = resolve(json, base, extra);
          final p = ReaderPalette.of(theme, direction: direction);
          expect(p.paper, hex(c['surface']));
          expect(p.ink, hex(c['ink']));
          expect(p.inkMuted, hex(c['ink-muted']));
          expect(p.brand, hex(c['brand']));
          expect(p.saved, hex(c['mark-saved']));
          expect(p.sentence, hex(c['mark-sentence']));
          expect(p.active, hex(c['brand-soft']));
          expect(p.brightness, base == 'dark' ? Brightness.dark : Brightness.light);
        });
      }

      test('familias, forma y escala tipográfica', () {
        final font = json['font'] as Map<String, dynamic>;
        final shape = json['shape'] as Map<String, dynamic>;
        final radius = shape['radius'] as Map<String, dynamic>;
        final type = json['type'] as Map<String, dynamic>;
        for (final t in [direction.tokens(Brightness.light), direction.tokens(Brightness.dark)]) {
          expect((t.displayFont, t.readingFont, t.interfaceFont), (family(font['display']), family(font['read']), family(font['sans'])));
          expect(
            [t.radiusSm, t.radiusMd, t.radiusLg, t.radiusXl, t.radiusCard],
            [
              for (final k in ['sm', 'md', 'lg', 'xl', 'card']) px(radius[k]),
            ],
          );
          expect((t.buttonRadius, t.chipRadius), (px(shape['button']), px(shape['chip'])));
          final s = t.typeScale;
          for (final (key, step) in [('display', s.display), ('h1', s.h1), ('h2', s.h2), ('h3', s.h3), ('h4', s.h4), ('label', s.label)]) {
            final spec = type[key] as Map<String, dynamic>;
            expect(step.weight.value, spec['weight'], reason: key);
            expect(step.tracking, em(spec['tracking']), reason: key);
          }
        }
        // cada familia que no viene de serie tiene sus archivos en assets/fonts/explore/
        for (final f in direction.extraFonts) {
          expect(exploreFontFiles[f], isNotNull, reason: f);
          for (final file in exploreFontFiles[f]!) {
            expect(File('assets/fonts/explore/$file').existsSync(), isTrue, reason: file);
          }
        }
      });
    });
  }
}
