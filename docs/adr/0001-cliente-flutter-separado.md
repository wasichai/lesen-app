# ADR-0001 — Cliente Flutter propio, separado de la web y sin lógica del backend

Estado: aceptada (2026-11-09)

## Contexto

Lesen tiene backend (`wasichai/lesen`) y web (`wasichai/lesen-ui`). Hace falta una app para iOS y Android, en
teléfono y tableta, con audio en segundo plano, lectura sin conexión y controles del sistema. Una WebView de la web no
da nada de eso con calidad nativa.

## Decisión

- App Flutter en `wasichai/lesen-app`, cliente de primera clase de la misma API. Ni WebView ni código compartido con la
  web.
- El backend es la fuente de verdad: catálogo, contenido, identidad, cuaderno, FSRS, corrección y progreso. El cliente
  no corrige preguntas, no calcula intervalos de repaso ni métricas del panel; solo mantiene proyecciones locales para
  responder rápido y funcionar sin red.
- Convenciones del ecosistema Lesen: código en inglés; documentación, comentarios y commits en español; Conventional
  Commits; ADR que no se editan; `docs/HISTORY.md`.

## Consecuencias

- Lo que falta en el móvil se pide al backend como contrato (`docs/architecture/api-integration.md`), no se inventa en
  Dart.
- La web y el móvil deben dar el mismo resultado para la misma cuenta: el progreso se cruza entre ambos.
