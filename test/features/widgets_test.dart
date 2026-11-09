import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lesen/features/catalog/data/catalog_dto.dart';
import 'package:lesen/features/catalog/presentation/widgets/reading_card_view.dart';

import '../support/fake_backend.dart';
import '../support/harness.dart';

void main() {
  testWidgets('la tarjeta muestra nivel, minutos y progreso, y se anuncia entera', (tester) async {
    final card = CatalogDto.card({
      ...fixtureCards().first,
      'progress': {'percent': 40, 'version': 1, 'completed': false, 'updatedAt': '2026-11-09T10:00:00Z'},
    });
    var tapped = false;
    await pumpWidgetUnderTest(
      tester,
      SizedBox(
        width: 260,
        child: ReadingCardView(reading: card, onTap: () => tapped = true),
      ),
      overrides: backendOverrides(FakeBackend()),
    );
    expect(find.text(card.level.name), findsOneWidget);
    expect(find.text('${card.minutes} min'), findsOneWidget);
    expect(find.text('40 % leído'), findsOneWidget);
    expect(find.bySemanticsLabel(RegExp('^${RegExp.escape(card.title)}\\. .*nivel ${card.level.name}')), findsOneWidget);
    await tester.tap(find.byType(ReadingCardView));
    expect(tapped, isTrue);
  });

  test('es y en tienen las mismas claves', () {
    Set<String> keys(String f) => (jsonDecode(File(f).readAsStringSync()) as Map).keys.cast<String>().where((k) => !k.startsWith('@')).toSet();
    expect(keys('lib/l10n/app_en.arb'), keys('lib/l10n/app_es.arb'));
  });
}
