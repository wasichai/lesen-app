# Publicación

Nada de esto se ha hecho todavía: no hay firma de producción, ni cuentas de tienda, ni URLs de staging y producción.
Este documento dice qué hace falta y dónde va cada cosa. **Ningún secreto entra en el repositorio.**

## Entornos y sabores

| Entorno | `--flavor` (Android) | Configuración         | Identificador                |
| ------- | -------------------- | --------------------- | ---------------------------- |
| dev     | `dev`                | `config/dev.json`     | `com.wasichai.lesen.dev`     |
| staging | `staging`            | `config/staging.json` | `com.wasichai.lesen.staging` |
| prod    | `prod`               | `config/prod.json`    | `com.wasichai.lesen`         |

```bash
flutter build appbundle --release --flavor prod --dart-define-from-file=config/prod.json
```

En iOS los sabores necesitan esquemas de Xcode (Runner-dev, Runner-staging, Runner-prod) con su
`PRODUCT_BUNDLE_IDENTIFIER`; se crean en Xcode en un Mac y no se han creado aún. Mientras, iOS compila un único destino
con el `config/*.json` que se le pase.

Antes de publicar, `config/staging.json` y `config/prod.json` deben apuntar al backend real (hoy son marcadores).

## Android: firma y Play Store

1. Crear la clave de subida (una vez, fuera del repositorio):

   ```bash
   keytool -genkey -v -keystore ~/lesen-upload.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
   ```

2. Crear `android/key.properties` (ignorado por git) o definir variables en la CI:

   | `key.properties` | Variable de CI                    |
   | ---------------- | --------------------------------- |
   | `storeFile`      | `LESEN_ANDROID_KEYSTORE`          |
   | `storePassword`  | `LESEN_ANDROID_KEYSTORE_PASSWORD` |
   | `keyAlias`       | `LESEN_ANDROID_KEY_ALIAS`         |
   | `keyPassword`    | `LESEN_ANDROID_KEY_PASSWORD`      |

   Sin ellas, la release se firma con la clave de depuración (sirve para probar, la Play Store la rechaza).

3. Activar «Play App Signing» y subir el `.aab`. La ficha necesita la declaración de permisos de
   `docs/platform/permissions.md` (servicio en primer plano de tipo `mediaPlayback` y notificaciones) y una política de
   privacidad.
4. La Play Store exige poder borrar la cuenta desde la app o una web: hoy no hay endpoint (hueco en
   `docs/architecture/api-integration.md`).

## iOS: certificados y App Store

1. Cuenta de Apple Developer del equipo, identificador `com.wasichai.lesen` con la capacidad **Background Modes → Audio**
   (ya declarada en `Info.plist`) y, si llega el push, **Push Notifications**.
2. En Xcode: equipo de firma, perfil de aprovisionamiento de distribución y `flutter build ipa --release
--dart-define-from-file=config/prod.json`.
3. Subir con Transporter o `xcrun altool`; en App Store Connect, la descripción de uso de notificaciones y la política
   de privacidad. La CI solo compila sin firma (`flutter build ios --no-codesign`).

## Push

No hay API de avisos en el backend (Wasichai 1.10.0). La app usa recordatorios locales. Cuando exista
`PUT /api/lesen/devices/{installationId}` (contrato propuesto), habrá que añadir Firebase Cloud Messaging en Android
(`google-services.json`, fuera del repositorio) y APNs en iOS (clave `.p8` en el servidor, nunca en la app).

## Antes de cada versión

- [ ] CI en verde (formato, análisis, pruebas, APK debug y release, iOS sin firma).
- [ ] `docs/platform/device-verification.md` recorrido en un Android y un iPhone reales, con el resultado anotado.
- [ ] `version:` de `pubspec.yaml` subida (nombre y número de compilación).
- [ ] `docs/HISTORY.md` al día.
