# ADR-0006 — Audio con just_audio y audio_service

Estado: aceptada (2026-11-09)

## Contexto

La narración debe seguir con la pantalla bloqueada, integrarse con los controles del sistema, respetar interrupciones
y foco de audio en ambas plataformas y dar la posición con precisión para resaltar palabra a palabra.

## Decisión

`just_audio` (reproducción, rangos HTTP, velocidad, flujo de posición), `audio_service` (MediaSession y servicio en
primer plano en Android, centro de control y pantalla de bloqueo en iOS) y `audio_session` (categoría de sesión,
interrupciones y auriculares). El manejador vive fuera del árbol de widgets. La sincronización usa los tiempos por
palabra del backend con búsqueda binaria; nunca aproximaciones por caracteres.

## Consecuencias

- Android declara el servicio y los permisos `FOREGROUND_SERVICE` y `FOREGROUND_SERVICE_MEDIA_PLAYBACK`; iOS,
  `UIBackgroundModes: audio`. El porqué está en `docs/platform/permissions.md`.
- El comportamiento en segundo plano solo se verifica en dispositivos reales; se documenta como pendiente mientras no
  se haga.
