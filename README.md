# Lesen — app móvil

Cliente Flutter (iOS y Android, teléfono y tableta) de Lesen: aprender idiomas leyendo, con audio sincronizado palabra
a palabra, diccionario en contexto, cuaderno con repaso espaciado, comprensión lectora y lectura sin conexión.

- Backend: [`wasichai/lesen`](https://github.com/wasichai/lesen) · Web: [`wasichai/lesen-ui`](https://github.com/wasichai/lesen-ui)
- Requisitos: [`docs/product/requirements.md`](docs/product/requirements.md) · Hoja de ruta:
  [`docs/product/roadmap.md`](docs/product/roadmap.md)
- Arquitectura: [`docs/architecture/overview.md`](docs/architecture/overview.md) · Decisiones: [`docs/adr/`](docs/adr/README.md)

## Desarrollo

Requisitos: Flutter estable (la versión exacta está en `pubspec.yaml`, `environment.flutter`), Android Studio o Xcode
para los emuladores, y un backend de Lesen en marcha (`wasichai/lesen`, README «Desarrollo local»: API en el 8095 y demo
con `model/apply.py --demo`).

```bash
flutter pub get
```

```bash
flutter run --dart-define-from-file=config/dev.json
```

En el emulador de Android, `localhost` es el propio emulador: usa `API_BASE_URL=http://10.0.2.2:8095`, por ejemplo con
un `config/dev.local.json` (no se versiona). Las cuentas de demostración son `lena@demo.lesen.test` (con perfil) y
`tomas@demo.lesen.test` (sin perfil: entra al onboarding), con la contraseña que diste a `LESEN_DEMO_PASSWORD`.

Para revisar el diseño sin emulador, la compilación web (solo para desarrollo):

```bash
flutter build web --dart-define-from-file=config/dev.json --no-web-resources-cdn
```

### Comprobaciones (Definition of Done)

```bash
dart format --set-exit-if-changed lib test
```

```bash
flutter analyze
```

```bash
flutter test
```

```bash
yarn install && yarn format:check
```

Las pruebas usan respuestas reales del backend capturadas por `lesen-ui` (`test/fixtures/`), servidas por un adaptador
HTTP en memoria (`test/support/fake_backend.dart`); nunca llegan a la app.

### Entornos

`config/dev.json`, `config/staging.json` y `config/prod.json` fijan `APP_ENV` y `API_BASE_URL` al compilar. Las URL de
staging y producción son marcadores hasta que haya despliegues.
