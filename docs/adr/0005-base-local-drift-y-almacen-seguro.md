# ADR-0005 — Base local con drift (SQLite) y token en almacenamiento seguro

Estado: aceptada (2026-11-09)

## Contexto

Sin conexión hay que guardar contenido, descargas, progreso, cuaderno, historial, preferencias y una cola de
operaciones, con consultas y migraciones. El token no puede ir a preferencias planas.

## Decisión

- `drift` sobre SQLite: tipado, consultas reactivas, migraciones probadas. Es la única pieza con `build_runner`
  (excepción a ADR-0002 justificada por las consultas tipadas); el código generado se versiona para que compilar no lo
  exija.
- `flutter_secure_storage` (Keychain en iOS, Keystore en Android) para el token y el usuario.
- Archivos de audio y portadas en el directorio de soporte de la app, referenciados desde la base.

## Consecuencias

- Las pruebas usan una base en memoria (`NativeDatabase.memory()`).
- Cerrar sesión borra el token y los datos personales locales; el contenido público descargado puede conservarse.
