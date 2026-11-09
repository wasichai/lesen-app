# Historial

## Fase 1 — Base Flutter, diseño, onboarding y catálogo (2026-11-09)

- Proyecto Flutter `com.wasichai.lesen` (Android, iOS; web solo para desarrollo), con entornos `config/*.json`.
- «Papel y tinta» en Flutter: tokens, Newsreader y Source Sans 3 (OFL), temas claro y oscuro, marca.
- Localización es/en con ARB; la interfaz sigue el idioma del perfil y cambia en el propio onboarding.
- Red: un cliente dio con Bearer, `problem+json` → `ApiFailure`, 404 como «todavía no hay», reintento solo de errores de
  red en llamadas idempotentes; portadas por el mismo cliente.
- Sesión en almacenamiento seguro; caducidad o 401 → login con aviso; redirecciones sin salir de la app.
- Onboarding en cinco pasos; Descubrir (destacada, para ti, de la semana, recientes, colecciones, temas, niveles);
  catálogo con búsqueda, filtros y carga incremental; ficha con marcador; perfil y cierre de sesión.
- Navegación adaptable: barra inferior en teléfono, raíl en tableta; aviso discreto sin conexión.
- 28 pruebas (contrato con fixtures reales, fallos, sesión, rutas, filtros, recorrido de onboarding, tableta).
- Verificado contra el backend real (`wasichai/lesen` en local con su demo) en la compilación web, a 390 y 1024 px.

## Fase 0 — Auditoría y arquitectura (2026-11-09)

- Auditoría de `wasichai/lesen` y `wasichai/lesen-ui`: casi todo lo que la app necesita existe en `/api/lesen`; huecos
  (refresco de token, push, paquete de descarga, cambios desde una fecha, borrado de cuenta) documentados con su contrato
  propuesto en `docs/architecture/api-integration.md`.
- Requisitos, hoja de ruta, arquitectura de la app, estrategia sin conexión y de audio.
- ADR 0001–0008.
- CI: mensajes de commit y formato de Markdown/YAML.
