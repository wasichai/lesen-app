import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/networking/api_client.dart';
import '../config.dart';
import '../theme/explorations/directions.dart';
import 'explore_fonts.dart';

/// El laboratorio solo existe en una compilación de depuración del entorno dev (docs/design/README.md).
bool designLabEnabled(AppConfig config) => kDebugMode && config.isDev;

/// La dirección de diseño en uso. Fuera de depuración vale siempre [DesignDirection.actual].
final designDirectionProvider = NotifierProvider<DesignDirectionController, DesignDirection>(DesignDirectionController.new);

class DesignDirectionController extends Notifier<DesignDirection> {
  /// [initial] solo sirve a las pruebas, que fijan la dirección sin pasar por el selector.
  DesignDirectionController([this.initial = DesignDirection.actual]);

  final DesignDirection initial;

  @override
  DesignDirection build() => kDebugMode ? initial : DesignDirection.actual;

  /// Cambia de dirección cuando sus fuentes ya están registradas, para no ver un salto de familia.
  Future<void> select(DesignDirection direction) async {
    if (!designLabEnabled(ref.read(appConfigProvider))) return;
    await loadExploreFonts(direction);
    state = direction;
  }
}

/// Claro, oscuro o el del sistema, para comparar las direcciones sin tocar los ajustes del dispositivo.
final designThemeModeProvider = NotifierProvider<DesignThemeModeController, ThemeMode>(DesignThemeModeController.new);

class DesignThemeModeController extends Notifier<ThemeMode> {
  DesignThemeModeController([this.initial = ThemeMode.system]);

  final ThemeMode initial;

  @override
  ThemeMode build() => kDebugMode ? initial : ThemeMode.system;

  void select(ThemeMode mode) {
    if (designLabEnabled(ref.read(appConfigProvider))) state = mode;
  }
}

/// Pone el botón del laboratorio encima de la app. [navigatorKey] da el contexto para abrir la hoja, porque el
/// `builder` de `MaterialApp` queda por encima del navegador.
class DesignLabOverlay extends StatelessWidget {
  const DesignLabOverlay({super.key, required this.navigatorKey, required this.child});

  final GlobalKey<NavigatorState> navigatorKey;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final padding = MediaQuery.paddingOf(context);
    final scheme = Theme.of(context).colorScheme;
    return Stack(
      children: [
        child,
        Positioned(
          left: 8 + padding.left,
          bottom: 96 + padding.bottom,
          child: Semantics(
            button: true,
            label: 'Laboratorio de diseño',
            excludeSemantics: true,
            child: Material(
              color: scheme.inverseSurface.withValues(alpha: 0.82),
              shape: const CircleBorder(),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: () {
                  final ctx = navigatorKey.currentContext;
                  if (ctx != null) showDesignLabSheet(ctx);
                },
                child: SizedBox.square(dimension: 44, child: Icon(Icons.palette_outlined, size: 22, color: scheme.onInverseSurface)),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// La hoja para elegir dirección y modo. Es una herramienta de desarrollo: sus textos no se traducen.
Future<void> showDesignLabSheet(BuildContext context) =>
    showModalBottomSheet<void>(context: context, isScrollControlled: true, builder: (_) => const _DesignLabSheet());

class _DesignLabSheet extends ConsumerWidget {
  const _DesignLabSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final direction = ref.watch(designDirectionProvider);
    final mode = ref.watch(designThemeModeProvider);
    final text = Theme.of(context).textTheme;
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Semantics(header: true, child: Text('Dirección de diseño', style: text.titleLarge)),
            const SizedBox(height: 8),
            for (final d in DesignDirection.values)
              ListTile(
                minTileHeight: 48,
                title: Text(d.label),
                subtitle: d == DesignDirection.actual ? const Text('Identidad de la app') : null,
                selected: d == direction,
                trailing: d == direction ? const Icon(Icons.check, semanticLabel: 'En uso') : null,
                onTap: () => ref.read(designDirectionProvider.notifier).select(d),
              ),
            const SizedBox(height: 16),
            Semantics(header: true, child: Text('Modo', style: text.titleLarge)),
            const SizedBox(height: 8),
            SegmentedButton<ThemeMode>(
              segments: const [
                ButtonSegment(value: ThemeMode.system, label: Text('Sistema'), icon: Icon(Icons.brightness_auto_outlined)),
                ButtonSegment(value: ThemeMode.light, label: Text('Claro'), icon: Icon(Icons.light_mode_outlined)),
                ButtonSegment(value: ThemeMode.dark, label: Text('Oscuro'), icon: Icon(Icons.dark_mode_outlined)),
              ],
              selected: {mode},
              onSelectionChanged: (s) => ref.read(designThemeModeProvider.notifier).select(s.first),
            ),
          ],
        ),
      ),
    );
  }
}
