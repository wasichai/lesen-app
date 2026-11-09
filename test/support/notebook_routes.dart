import 'dart:convert';
import 'dart:io';

import 'fake_backend.dart';

/// Respuestas reales capturadas del backend local con la demo (`docs/architecture/api-integration.md` §5).
final Map<String, dynamic> notebook = (jsonDecode(File('test/fixtures/notebook.json').readAsStringSync()) as Map).cast<String, dynamic>();
final Map<String, dynamic> attemptFixture = (jsonDecode(File('test/fixtures/attempt.json').readAsStringSync()) as Map).cast<String, dynamic>();
final Map<String, dynamic> assessmentFixture = (jsonDecode(File('test/fixtures/assessment.json').readAsStringSync()) as Map).cast<String, dynamic>();

Map<String, Handler> notebookRoutes() => {
  'GET /lesen/vocabulary': (_) => notebook['vocabulary'],
  'GET /lesen/vocabulary/stats': (_) => notebook['stats'],
  'GET /lesen/vocabulary/reviews/next': (_) => notebook['reviewsNext'],
  'POST /lesen/vocabulary/reviews': (r) => {'item': (notebook['vocabulary']['content'] as List).first, 'state': 'LEARNING', 'previousStatus': 'SAVED'},
  'GET /lesen/dictionary/search': (_) => notebook['search'],
  'GET /lesen/dictionary/entries/de:licht': (_) => notebook['entry'],
  'GET /lesen/dictionary/history': (_) => notebook['history'],
  'GET /lesen/dictionary/favorites': (_) => notebook['favorites'],
  'PUT /lesen/dictionary/favorites/de:licht': (_) => null,
  'GET /lesen/readings/der-alte-leuchtturm/versions/1/assessment': (_) => assessmentFixture,
  'POST /lesen/assessments/${assessmentFixture['id']}/attempts': (_) => Reply(201, attemptFixture),
  'GET /lesen/attempts/${(attemptFixture['summary'] as Map)['id']}': (_) => attemptFixture,
};
