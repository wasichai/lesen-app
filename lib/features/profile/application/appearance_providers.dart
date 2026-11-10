import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/directions/directions.dart';
import '../../../core/networking/json.dart';
import '../../../core/storage/local_store.dart';

/// Identidad y modo claro/oscuro elegidos en el perfil (ADR-0011). Es una preferencia del dispositivo, como las del
/// lector: no pasa por la cola de operaciones porque la cuenta todavía no tiene dónde guardarla.
@immutable
class Appearance {
  const Appearance({this.direction = DesignDirection.fallback, this.themeMode = ThemeMode.system});

  /// Lo guardado; un valor que no se reconoce vuelve al de por defecto.
  factory Appearance.fromJson(Json json) => Appearance(
    direction: DesignDirection.values.asNameMap()[json['direction']] ?? DesignDirection.fallback,
    themeMode: ThemeMode.values.asNameMap()[json['themeMode']] ?? ThemeMode.system,
  );

  final DesignDirection direction;
  final ThemeMode themeMode;

  Json toJson() => {'direction': direction.name, 'themeMode': themeMode.name};

  Appearance copyWith({DesignDirection? direction, ThemeMode? themeMode}) =>
      Appearance(direction: direction ?? this.direction, themeMode: themeMode ?? this.themeMode);

  @override
  bool operator ==(Object other) => other is Appearance && other.direction == direction && other.themeMode == themeMode;

  @override
  int get hashCode => Object.hash(direction, themeMode);
}

final appearanceProvider = NotifierProvider<AppearanceController, Appearance>(AppearanceController.new);

class AppearanceController extends Notifier<Appearance> {
  static const _ns = 'prefs';
  static const _key = 'appearance';

  /// Termina cuando lo guardado ya está en el estado; `main` lo espera para no pintar antes otra identidad.
  late Future<void> loaded;

  @override
  Appearance build() {
    loaded = _load();
    return const Appearance();
  }

  Future<void> _load() async {
    try {
      final j = await ref.read(localStoreProvider).read(_ns, _key);
      if (j != null && ref.mounted) state = Appearance.fromJson(j);
    } catch (_) {
      // sin base local (o con un documento ilegible) se sigue con Musgo y el modo del sistema
    }
  }

  Future<void> update(Appearance next) async {
    state = next;
    await ref.read(localStoreProvider).write(_ns, _key, next.toJson());
  }

  Future<void> selectDirection(DesignDirection direction) => update(state.copyWith(direction: direction));

  Future<void> selectThemeMode(ThemeMode mode) => update(state.copyWith(themeMode: mode));
}
