# ADR-0010 — Descargas con dio en primer plano y cola de operaciones sobre la tabla `kv`

Estado: aceptada (2026-11-09). Reemplaza en parte a [ADR-0007](0007-sin-conexion-cola-y-conflictos.md) (el uso de
`background_downloader`) y a [ADR-0009](0009-drift-sin-generacion.md) (tablas nuevas para la fase 5).

## Contexto

ADR-0007 preveía `background_downloader` para que una descarga larga siguiera con la app cerrada, y ADR-0009 tablas
nuevas para la cola y las descargas. Al implementarlo: los archivos de una lectura son pequeños (el audio de demostración
pesa menos de 1 MB por lectura), `background_downloader` añade configuración nativa y un ciclo de vida propio difícil de
probar, y la cola y las descargas son decenas de filas, no miles.

## Decisión

- Las descargas usan el cliente dio de la app (`download` con progreso y cancelación) mientras la app está abierta; el
  audio se escribe en un `.part` que se renombra al terminar, y una descarga cortada al cerrar la app aparece como
  fallida para reintentarla.
- La cola (`outbox`) y el estado de las descargas (`downloads`) son espacios de la tabla `kv` de ADR-0009, con el orden
  y los reintentos dentro de cada documento JSON. La web de desarrollo usa la misma lógica sobre `MemoryLocalStore`.
- La cola mantiene el orden de llegada y se detiene ante la primera operación que espera su reintento, para que una
  operación nunca adelante a otra anterior (terminar después del último progreso).

## Consecuencias

- Una descarga no continúa con la app cerrada. Si las lecturas con audio grabado crecen, se reconsiderará con otra ADR.
- Sin migraciones nuevas en esta fase; si la cola crece hasta necesitar consultas, se le dará su tabla.
