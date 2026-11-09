# ADR-0003 — Navegación declarativa con go_router

Estado: aceptada (2026-11-09)

## Contexto

Hacen falta enlaces profundos, guardas de sesión y de onboarding, pestañas que conservan su pila y pantallas a
pantalla completa (lector, reproductor, repaso) fuera del armazón.

## Decisión

`go_router` (paquete mantenido por el equipo de Flutter) con `StatefulShellRoute.indexedStack` para las cuatro ramas,
una redirección global (sin sesión → login; sin perfil → onboarding) y constantes tipadas para construir rutas.
Los enlaces profundos se validan contra rutas y slugs conocidos.

## Consecuencias

- Un enlace a una lectura funciona con la app cerrada y lleva al login si hace falta, volviendo después.
- No se usa `go_router_builder` (generación de código, ver ADR-0002).
