import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';

/// Fixtures capturadas del backend real por `lesen-ui` (`e2e/fixtures/capture.mjs`), copiadas en `test/fixtures/`.
final Map<String, dynamic> fixtures = (jsonDecode(File('test/fixtures/lesen.json').readAsStringSync()) as Map).cast<String, dynamic>();

List<Map<String, dynamic>> fixtureCards() => (fixtures['cards'] as List).cast<Map<String, dynamic>>();

/// `discover` compuesto con tarjetas reales, como hace la API simulada de la web.
Map<String, dynamic> fixtureDiscover() {
  final cards = fixtureCards();
  return {
    'continueReading': <Object>[],
    'featured': cards.where((c) => c['featured'] == true).toList(),
    'recommended': [
      for (final c in cards.take(3))
        {
          'reading': c,
          'reasons': ['LEVEL'],
        },
    ],
    'thisWeek': <Object>[],
    'fresh': cards.take(4).toList(),
    'collections': <Object>[],
    'topics': [
      {'slug': 'nature', 'readings': 3},
    ],
  };
}

typedef Handler = Object? Function(RequestOptions request);

/// Respuesta con código distinto de 200.
class Reply {
  const Reply(this.status, [this.body]);

  final int status;
  final Object? body;
}

/// Un backend en memoria: rutas exactas («GET /lesen/discover») y registro de lo recibido.
class FakeBackend implements HttpClientAdapter {
  FakeBackend([Map<String, Handler>? routes]) : routes = {...defaults(), ...?routes};

  final Map<String, Handler> routes;
  final List<RequestOptions> requests = [];

  static Map<String, Handler> defaults() => {
    'POST /auth/login': (_) => {
      'token': 'token-de-prueba',
      'expiresAt': DateTime.now().add(const Duration(hours: 8)).toUtc().toIso8601String(),
      'user': {
        'id': 'u1',
        'email': 'tomas@demo.lesen.test',
        'displayName': 'Tomás',
        'organizationId': 'o1',
        'roles': ['LECTOR'],
      },
    },
    'GET /auth/me/permissions': (_) => {
      'admin': false,
      'capabilities': <Object>[],
      'objects': {
        'lectura': ['READ'],
        'cuaderno': ['READ', 'UPDATE'],
      },
    },
    'GET /lesen/public/languages': (_) => fixtures['languages'],
    'GET /lesen/public/topics': (_) => fixtures['topics'],
    'GET /lesen/learner/profile': (_) => const Reply(404, {'status': 404, 'detail': 'No learner profile yet'}),
    'GET /lesen/discover': (_) => fixtureDiscover(),
    'GET /lesen/readings': (_) {
      final cards = fixtureCards();
      return {'content': cards, 'page': 0, 'size': 12, 'totalElements': cards.length, 'totalPages': 1};
    },
  };

  int count(String key) => requests.where((r) => '${r.method} ${r.path}' == key).length;

  @override
  Future<ResponseBody> fetch(RequestOptions options, Stream<Uint8List>? requestStream, Future<void>? cancelFuture) async {
    requests.add(options);
    final handler = routes['${options.method} ${options.path}'];
    if (handler == null) return _json(404, {'status': 404, 'detail': 'Sin ruta en FakeBackend: ${options.method} ${options.path}'});
    final result = handler(options);
    if (result is Reply) return _json(result.status, result.body);
    if (result == null) return ResponseBody.fromString('', 204);
    return _json(200, result);
  }

  ResponseBody _json(int status, Object? body) => ResponseBody.fromString(
    jsonEncode(body),
    status,
    headers: {
      Headers.contentTypeHeader: [status >= 400 ? 'application/problem+json' : Headers.jsonContentType],
    },
  );

  @override
  void close({bool force = false}) {}
}
