import 'dart:convert';

import '../networking/json.dart';

class SessionUser {
  const SessionUser({required this.id, required this.email, required this.displayName, required this.roles});

  factory SessionUser.fromJson(Json json) => SessionUser(
    id: json['id'].toString(),
    email: json.str('email'),
    displayName: json.strOrNull('displayName') ?? json.str('email'),
    roles: json.strings('roles'),
  );

  final String id;
  final String email;
  final String displayName;
  final List<String> roles;

  /// El nombre de pila para saludar, nunca el correo entero.
  String get firstName {
    final name = displayName.contains('@') ? displayName.split('@').first : displayName;
    return name.split(' ').first;
  }

  Json toJson() => {'id': id, 'email': email, 'displayName': displayName, 'roles': roles};
}

/// Lo que da el backend al entrar (`POST /api/auth/login`) más los permisos (`GET /api/auth/me/permissions`).
class Session {
  const Session({required this.token, required this.expiresAt, required this.user, required this.objects});

  factory Session.fromJson(Json json) => Session(
    token: json.str('token'),
    expiresAt: json.dateOrNull('expiresAt'),
    user: SessionUser.fromJson(json.obj('user')),
    objects: (json.objOrNull('objects') ?? const {}).map((k, v) => MapEntry(k, (v as List).map((e) => e.toString()).toSet())),
  );

  final String token;
  final DateTime? expiresAt;
  final SessionUser user;

  /// Permisos por objeto ancla: `lectura` (READ) y `cuaderno` (READ, UPDATE).
  final Map<String, Set<String>> objects;

  bool get canRead => objects['lectura']?.contains('READ') ?? false;
  bool get hasNotebook => objects['cuaderno']?.contains('READ') ?? false;
  bool get canWriteNotebook => objects['cuaderno']?.contains('UPDATE') ?? false;

  bool isExpired(DateTime now) => expiresAt != null && !now.isBefore(expiresAt!);

  Session withObjects(Map<String, Set<String>> value) => Session(token: token, expiresAt: expiresAt, user: user, objects: value);

  Json toJson() => {
    'token': token,
    'expiresAt': expiresAt?.toIso8601String(),
    'user': user.toJson(),
    'objects': objects.map((k, v) => MapEntry(k, v.toList())),
  };

  String encode() => jsonEncode(toJson());

  static Session decode(String raw) => Session.fromJson((jsonDecode(raw) as Map).cast<String, dynamic>());
}
