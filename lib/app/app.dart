import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/networking/api_client.dart';
import '../core/sync/sync.dart';
import '../features/profile/application/profile_providers.dart';
import '../l10n/app_localizations.dart';
import 'design_lab/design_lab.dart';
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
    // la dirección de diseño y el modo solo cambian desde el laboratorio (dev y depuración); si no, «Papel y tinta»
    final direction = ref.watch(designDirectionProvider);
    final lab = designLabEnabled(ref.watch(appConfigProvider));
    return MaterialApp.router(
      onGenerateTitle: (context) => AppLocalizations.of(context).appName,
      debugShowCheckedModeBanner: false,
      theme: buildTheme(Brightness.light, tokens: direction.tokens(Brightness.light)),
      darkTheme: buildTheme(Brightness.dark, tokens: direction.tokens(Brightness.dark)),
      themeMode: ref.watch(designThemeModeProvider),
      locale: interface == null ? null : Locale(interface),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      routerConfig: router,
      builder: lab ? (context, child) => DesignLabOverlay(navigatorKey: router.routerDelegate.navigatorKey, child: child!) : null,
    );
  }
}
