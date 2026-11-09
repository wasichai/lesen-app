# Historial

## Fase 0 — Auditoría y arquitectura (2026-11-09)

- Auditoría de `wasichai/lesen` y `wasichai/lesen-ui`: casi todo lo que la app necesita existe en `/api/lesen`; huecos
  (refresco de token, push, paquete de descarga, cambios desde una fecha, borrado de cuenta) documentados con su contrato
  propuesto en `docs/architecture/api-integration.md`.
- Requisitos, hoja de ruta, arquitectura de la app, estrategia sin conexión y de audio.
- ADR 0001–0008.
- CI: mensajes de commit y formato de Markdown/YAML.
