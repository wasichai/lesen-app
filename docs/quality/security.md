# Seguridad y privacidad

Revisión de la fase 7 (2026-11-09).

| Tema                       | Cómo está                                                                                                                                       |
| -------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------- |
| Credenciales               | El JWT y el usuario, solo en `flutter_secure_storage` (Keychain/Keystore). La contraseña no se guarda nunca.                                    |
| Caducidad y 401            | Al caducar o recibir un 401 con sesión, se cierra y se vuelve al login con aviso; la cola se detiene hasta volver a entrar.                     |
| Refresco de token          | No existe en el backend: no se inventa (hueco documentado).                                                                                     |
| Cerrar sesión              | Borra el token, el progreso local, la cola, las descargas, las copias personales y las preferencias. Si queda algo sin enviar, avisa antes.     |
| Secretos en la app         | Ninguno: no hay claves de proveedores (IA, traducción, TTS). Todo va por el backend.                                                            |
| Secretos en el repositorio | Ninguno: `key.properties`, keystores, perfiles, `google-services.json` y `config/*.local.json` están en `.gitignore`.                           |
| Transporte                 | HTTPS en release. HTTP sin cifrar solo en depuración (Android `usesCleartextTraffic` en el manifiesto de debug; iOS `NSAllowsLocalNetworking`). |
| Enlaces profundos          | Solo `lesen://app/<ruta>`; el router acepta rutas conocidas y slugs `^[a-z0-9-]{1,120}$`, y el `from=` del login nunca sale de la app.          |
| Datos de otras cuentas     | La app solo pide lo de quien entra; el backend responde 404 a lo ajeno. Nada personal se cachea fuera del espacio que se borra al salir.        |
| Registros                  | Sin `print` en `lib/` (regla `avoid_print`); los errores no incluyen tokens ni cuerpos de petición.                                             |
| Entradas                   | Búsquedas recortadas (64 caracteres en el catálogo), notas con `maxLength`, nombres de lista validados por el backend (409 si se repiten).      |
| Permisos                   | Solo los de `docs/platform/permissions.md`, y las notificaciones se piden al activar el recordatorio.                                           |
| Archivos                   | En el directorio de soporte de la app (no visible para otras apps); el audio se escribe en `.part` y se renombra al terminar.                   |

Pendiente fuera de la app: borrado de cuenta (requisito de las tiendas) y registro de dispositivos para push, ambos en
el backend.
