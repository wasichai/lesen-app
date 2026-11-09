# Permisos de la plataforma

Se piden solo los que usa una función ya entregada, y cada uno con su motivo. Al añadir uno, se actualiza esta tabla.

| Plataforma | Permiso / capacidad                      | Desde  | Por qué                                                                     |
| ---------- | ---------------------------------------- | ------ | --------------------------------------------------------------------------- |
| Android    | `INTERNET`                               | Fase 1 | Hablar con la API de Lesen                                                  |
| Android    | `ACCESS_NETWORK_STATE`                   | Fase 1 | Saber si hay red para avisar con discreción y no intentar lo imposible      |
| Android    | `usesCleartextTraffic` (solo depuración) | Fase 1 | El backend local de desarrollo es `http://10.0.2.2:8095`; release exige TLS |
| iOS        | `NSAllowsLocalNetworking`                | Fase 1 | Igual que el anterior para el simulador; no relaja TLS hacia internet       |

Pendientes, con la fase que los introduce:

- Fase 3, audio en segundo plano: `FOREGROUND_SERVICE`, `FOREGROUND_SERVICE_MEDIA_PLAYBACK` y `WAKE_LOCK` en Android;
  `UIBackgroundModes: audio` en iOS.
- Fase 6, recordatorios locales: `POST_NOTIFICATIONS` (Android 13+) y la autorización de notificaciones de iOS, pedidas
  solo cuando la persona activa un recordatorio.
