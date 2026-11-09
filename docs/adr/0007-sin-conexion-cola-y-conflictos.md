# ADR-0007 — Sin conexión primero: proyecciones locales, cola de operaciones y conflictos explícitos

Estado: aceptada (2026-11-09)

## Contexto

Leer, escuchar, repasar y responder sin red no debe perder nada, y leer en el móvil sin red y luego en la web no debe
pisar lo nuevo con lo viejo. El backend ya hace idempotentes progreso, terminar, guardar y repasar (`clientId`).

## Decisión

- Cada escritura se aplica a la proyección local y se encola en `outbox`; la cola se vacía en orden, con espera
  exponencial, al volver la red, al volver a primer plano y al arrancar.
- Progreso: posición del más reciente por `updatedAt`; porcentaje y segundos, el mayor. Repaso: el servidor decide.
- Un rechazo definitivo (4xx) se muestra; nunca se borra en silencio.
- Descargas explícitas con `background_downloader` (progreso, cancelación, reintento, solo Wi-Fi).

## Consecuencias

- Detalle en `docs/architecture/offline-strategy.md`.
- Sin un endpoint de paquete ni de cambios desde una fecha, una descarga hace varias peticiones y la sincronización
  refresca listas enteras; ambos contratos están propuestos.
