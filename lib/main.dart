import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app.dart';
import 'app/config.dart';
import 'core/networking/api_client.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    ProviderScope(
      // los fallos se muestran con su botón de reintento; Riverpod no reintenta por su cuenta
      retry: (_, _) => null,
      overrides: [appConfigProvider.overrideWithValue(AppConfig.fromEnvironment())],
      child: const LesenApp(),
    ),
  );
}
