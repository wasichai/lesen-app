import 'api_failure.dart';

/// Lectura defensiva de JSON: falla con [ContractException] si falta lo que el cliente usa y tolera lo nuevo.
typedef Json = Map<String, dynamic>;

extension JsonRead on Json {
  T req<T>(String key) {
    final value = this[key];
    if (value is T) return value;
    if (T == double && value is num) return value.toDouble() as T;
    throw ContractException('"$key": se esperaba $T y llegó ${value.runtimeType}');
  }

  T? opt<T>(String key) {
    final value = this[key];
    if (value == null) return null;
    if (value is T) return value;
    if (T == double && value is num) return value.toDouble() as T;
    throw ContractException('"$key": se esperaba $T? y llegó ${value.runtimeType}');
  }

  String str(String key) => req<String>(key);
  String? strOrNull(String key) => opt<String>(key);
  int integer(String key) => req<num>(key).toInt();
  int? integerOrNull(String key) => opt<num>(key)?.toInt();
  bool boolean(String key, {bool fallback = false}) => opt<bool>(key) ?? fallback;
  DateTime date(String key) => DateTime.parse(str(key));
  DateTime? dateOrNull(String key) {
    final v = strOrNull(key);
    return v == null ? null : DateTime.parse(v);
  }

  Json obj(String key) => req<Map>(key).cast<String, dynamic>();
  Json? objOrNull(String key) => opt<Map>(key)?.cast<String, dynamic>();

  List<T> list<T>(String key, T Function(Json) parse) =>
      (opt<List>(key) ?? const []).map((e) => parse((e as Map).cast<String, dynamic>())).toList(growable: false);

  List<String> strings(String key) => (opt<List>(key) ?? const []).map((e) => e.toString()).toList(growable: false);

  Map<String, String> stringMap(String key) => (opt<Map>(key) ?? const {}).map((k, v) => MapEntry(k.toString(), v.toString()));
}

/// Página del backend: `{content, page, size, totalElements, totalPages}`, `page` desde 0.
class PageOf<T> {
  const PageOf({required this.content, required this.page, required this.size, required this.totalElements, required this.totalPages});

  factory PageOf.fromJson(Json json, T Function(Json) parse) => PageOf(
    content: json.list('content', parse),
    page: json.integer('page'),
    size: json.integer('size'),
    totalElements: json.integer('totalElements'),
    totalPages: json.integer('totalPages'),
  );

  final List<T> content;
  final int page;
  final int size;
  final int totalElements;
  final int totalPages;

  bool get hasNext => page + 1 < totalPages;
}

/// Una enumeración del backend leída con tolerancia: un valor nuevo no rompe la pantalla.
T enumByName<T extends Enum>(List<T> values, String? name, T fallback) {
  for (final v in values) {
    if (v.name == name) return v;
  }
  return fallback;
}
