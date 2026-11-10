import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app.dart';
import 'app/config.dart';
import 'core/audio/just_audio_engine.dart';
import 'core/audio/narration_engine.dart';
import 'core/networking/api_client.dart';
import 'features/audio/application/playback_controller.dart';
import 'features/profile/application/appearance_providers.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  NarrationEngine engine;
  try {
    // la sesión de audio del sistema: segundo plano, pantalla de bloqueo, auriculares (ADR-0006)
    engine = await LesenAudioHandler.start();
  } catch (_) {
    // sin servicio del sistema (p. ej. la compilación web de desarrollo) la narración suena igual, sin esos controles
    engine = LesenAudioHandler();
  }
  final container = ProviderContainer(
    // los fallos se muestran con su botón de reintento; Riverpod no reintenta por su cuenta
    retry: (_, _) => null,
    overrides: [appConfigProvider.overrideWithValue(AppConfig.fromEnvironment()), narrationEngineProvider.overrideWithValue(engine)],
  );
  // la identidad guardada se lee antes del primer fotograma, para no pintar Musgo y saltar a la elegida
  await container.read(appearanceProvider.notifier).loaded;
  runApp(UncontrolledProviderScope(container: container, child: const LesenApp()));
}
