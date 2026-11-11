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

  /// Sin red: cada petición falla como un modo avión.
  bool offline = false;

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

  /// Las rutas del lector para una lectura capturada (`der-alte-leuchtturm` tiene todo: audio, traducciones, preguntas).
  /// Con [illustrated], el contenido lleva además sus `blocks` con ilustraciones (`test/fixtures/illustrations/`) y se
  /// sirven sus archivos.
  static Map<String, Handler> readingRoutes(String slug, {bool illustrated = false}) {
    final r = (fixtures['readings'] as Map)[slug] as Map<String, dynamic>;
    final blocks = illustrated ? illustratedBlocks(slug) : null;
    final content = {...r['content'] as Map<String, dynamic>, 'blocks': ?blocks};
    final version = content['version'];
    final entries = ((r['entries'] as Map)['es'] as Map).cast<String, dynamic>();
    final base = '/lesen/readings/$slug';
    return {
      'GET $base': (_) => r['detail'],
      'GET $base/versions/$version/content': (_) => content,
      'GET $base/versions/$version/translations': (req) =>
          ((r['translations'] as Map)['es'] as List).where((t) => (t as Map)['unit'] == req.queryParameters['unit']).toList(),
      'GET $base/progress': (_) => const Reply(404, {'status': 404}),
      'PUT $base/progress': (req) => {
        ...(req.data as Map).cast<String, dynamic>(),
        'completed': false,
        'startedAt': '2026-11-09T10:00:00Z',
        'updatedAt': DateTime.now().toUtc().toIso8601String(),
        'completedAt': null,
      },
      'GET $base/notes': (_) => <Object>[],
      'GET $base/versions/$version/audio': (_) => r['audio'] ?? const Reply(404, {'status': 404}),
      for (final b in blocks ?? const <Map<String, dynamic>>[])
        if (b['type'] == 'image') 'GET ${pathOf(RequestOptions(path: b['url'] as String))}': (_) => illustrationBytes(b['url'] as String),
      'GET /lesen/public/audio/$slug.mp3': (_) =>
          File('test/fixtures/audio/$slug.mp3').existsSync() ? File('test/fixtures/audio/$slug.mp3').readAsBytesSync() : const Reply(404),
      'GET /lesen/vocabulary/known': (_) => {'saved': <Object>[], 'encountered': <Object>[]},
      'POST /lesen/vocabulary': (req) => const Reply(201, {'id': 'v1'}),
      'GET /lesen/dictionary/lookup': (req) {
        final tokenId = req.queryParameters['token'];
        for (final p in content['paragraphs'] as List) {
          for (final s in (p as Map)['sentences'] as List) {
            for (final t in (s as Map)['tokens'] as List) {
              if ((t as Map)['id'] == tokenId) {
                final text = (s['tokens'] as List).map((x) => (x as Map)['text'].toString() + (x['space'] == true ? ' ' : '')).join().trim();
                return {
                  'token': t['text'],
                  'tokenRef': tokenId,
                  'sentenceRef': s['id'],
                  'sentence': text,
                  'translationLanguage': 'es',
                  'entry': entries[t['entry']],
                  'inflected': entries[t['entry']] != null && (entries[t['entry']] as Map)['lemma'] != t['text'],
                  'alternatives': <Object>[],
                };
              }
            }
          }
        }
        return const Reply(404, {'status': 404});
      },
    };
  }

  /// Los `blocks` de una lectura con ilustraciones (ADR-0018 del backend), de `test/fixtures/illustrations/`.
  static List<Map<String, dynamic>> illustratedBlocks(String slug) =>
      ((jsonDecode(File('test/fixtures/illustrations/$slug.blocks.json').readAsStringSync()) as Map)['blocks'] as List).cast<Map<String, dynamic>>();

  /// El archivo de una ilustración de las fixtures, por su URL pública.
  static Uint8List illustrationBytes(String url) => File('test/fixtures/illustrations/${Uri.parse(url).pathSegments.last}').readAsBytesSync();

  /// La ruta bajo `/api`, venga relativa o absoluta (portadas y audio se piden por URL completa).
  static String pathOf(RequestOptions r) {
    final path = Uri.decodeComponent(r.uri.path);
    return path.startsWith('/api/') ? path.substring(4) : path;
  }

  int count(String key) => requests.where((r) => '${r.method} ${pathOf(r)}' == key).length;

  @override
  Future<ResponseBody> fetch(RequestOptions options, Stream<Uint8List>? requestStream, Future<void>? cancelFuture) async {
    // lo que no llega al servidor (modo avión) no cuenta como petición recibida
    if (offline) {
      throw DioException(requestOptions: options, type: DioExceptionType.connectionError, error: const SocketException('modo avión'));
    }
    requests.add(options);
    final handler = routes['${options.method} ${pathOf(options)}'];
    if (handler == null) return _json(404, {'status': 404, 'detail': 'Sin ruta en FakeBackend: ${options.method} ${options.path}'});
    final result = handler(options);
    if (result is Reply) return _json(result.status, result.body);
    if (result is List<int>) {
      return ResponseBody.fromBytes(
        result,
        200,
        headers: {
          Headers.contentTypeHeader: ['audio/mpeg'],
          Headers.contentLengthHeader: ['${result.length}'],
        },
      );
    }
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
