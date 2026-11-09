import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/sync/sync.dart';
import '../features/profile/application/profile_providers.dart';
import '../l10n/app_localizations.dart';
import 'routing/router.dart';
import 'theme/theme.dart';

class LesenApp extends ConsumerWidget {
  const LesenApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    // la cola de operaciones se vacía sola al volver la red, al volver a primer plano y al entrar
    ref.watch(syncTriggersProvider);
    // el idioma de la interfaz es el del perfil; sin perfil, el del dispositivo (si es es o en)
    final interface = ref.watch(profileProvider.select((p) => p.value?.interfaceLanguage));
    return MaterialApp.router(
      onGenerateTitle: (context) => AppLocalizations.of(context).appName,
      debugShowCheckedModeBanner: false,
      theme: buildTheme(Brightness.light),
      darkTheme: buildTheme(Brightness.dark),
      locale: interface == null ? null : Locale(interface),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      routerConfig: router,
    );
  }
}
