import 'package:flutter_test/flutter_test.dart';
import 'package:lesen/core/networking/api_failure.dart';
import 'package:lesen/core/networking/json.dart';
import 'package:lesen/features/catalog/data/catalog_dto.dart';
import 'package:lesen/features/catalog/domain/catalog_query.dart';
import 'package:lesen/features/catalog/domain/reading.dart';
import 'package:lesen/features/profile/data/profile_repository.dart';
import 'package:lesen/features/profile/domain/learner_profile.dart';

import '../support/fake_backend.dart';

/// Contrato: las respuestas reales capturadas del backend se leen sin perder nada que la app use.
void main() {
  test('todas las tarjetas capturadas se leen', () {
    final cards = fixtureCards().map(CatalogDto.card).toList();
    expect(cards, hasLength(11));
    final lisbon = cards.firstWhere((c) => c.slug == 'a-morning-in-lisbon');
    expect(lisbon.level, CefrLevel.A2);
    expect(lisbon.cover, '/api/lesen/public/covers/a-morning-in-lisbon.svg');
    expect(lisbon.progress, isNull);
  });

  test('la ficha, los idiomas y el árbol de temas', () {
    final detail = CatalogDto.detail((fixtures['readings'] as Map)['der-alte-leuchtturm']['detail'] as Json);
    expect(detail.reading.title, 'Der alte Leuchtturm');
    expect(detail.paragraphs, greaterThan(0));

    final langs = CatalogDto.languages(fixtures['languages'] as Json);
    expect(langs.interfaceLanguages.map((l) => l.code), ['es', 'en']);
    expect(langs.studyLanguages.map((l) => l.code), ['en', 'de']);
    expect(langs.wordsPerMinute[CefrLevel.A1], 60);

    final topics = (fixtures['topics'] as List).map((t) => CatalogDto.topic(t as Json)).toList();
    expect(topics.first.label('es'), 'Ciencia');
    expect(topics.first.children.first.slug, 'science/space');
  });

  test('un motivo de recomendación nuevo no rompe Descubrir', () {
    final json = fixtureDiscover();
    (json['recommended'] as List).first['reasons'] = ['SOMETHING_NEW'];
    final d = CatalogDto.discover(json);
    expect(d.recommended.first.reasons, [RecommendationReason.unknown]);
  });

  test('un nivel desconocido es un fallo de contrato explícito', () {
    final card = {...fixtureCards().first, 'level': 'Z9'};
    expect(() => CatalogDto.card(card), throwsA(isA<ContractException>()));
  });

  test('el perfil va y vuelve con los nombres del backend', () {
    const p = LearnerProfile(
      interfaceLanguage: 'es',
      targetLanguage: 'de',
      level: CefrLevel.B1,
      levelEstimated: false,
      goals: {LearningGoal.WORK, LearningGoal.TRAVEL},
      topics: ['nature'],
      dailyMinutes: 15,
      difficulty: ReadingDifficulty.CHALLENGING,
    );
    final json = ProfileRepository.toJson(p);
    expect(json['goals'], ['TRAVEL', 'WORK']);
    expect(json['level'], 'B1');
    final back = ProfileRepository.parse(json);
    expect(back.goals, p.goals);
    expect(back.difficulty, ReadingDifficulty.CHALLENGING);
  });

  test('los filtros del catálogo se traducen a la consulta del backend', () {
    const q = CatalogQuery(language: 'de', levels: {CefrLevel.B1, CefrLevel.A2}, topic: 'nature', duration: DurationRange.medium, q: '  faro ');
    expect(q.toQuery(page: 2), {
      'language': 'de',
      'level': ['A2', 'B1'],
      'topic': 'nature',
      'minMinutes': 4,
      'maxMinutes': 6,
      'q': 'faro',
      'sort': 'RECENT',
      'page': 2,
      'size': 12,
    });
    expect(q.activeFilters, 4);
    expect(q.cleared().activeFilters, 0);
    expect(q.cleared().q, '  faro ');
    expect(const CatalogQuery(levels: {CefrLevel.A1, CefrLevel.B1}), const CatalogQuery(levels: {CefrLevel.B1, CefrLevel.A1}));
  });
}
