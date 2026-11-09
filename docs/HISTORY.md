# Historial

## Fase 3 — Motor de audio y sincronización palabra a palabra (2026-11-09)

- just_audio dentro de audio_service (`LesenAudioHandler`), sesión de voz hablada con audio_session: segundo plano,
  notificación y pantalla de bloqueo, auriculares (siguiente y anterior por párrafo), pausa al desconectar.
- Tiempos por palabra del backend con búsqueda binaria (`TimingIndex`, margen de 250 ms); `PlaybackController`
  notifica lo activo solo al cambiar de palabra y cada párrafo se reconstruye solo si es el suyo.
- Barra de audio en el lector (posición, ±5 s, oración y párrafo, velocidad 0,75–1,5, seguir la lectura), mini
  reproductor en la navegación y reproductor a pantalla completa con la oración que suena.
- Tocar una palabra mientras suena lleva el audio a ella; «Escuchar desde aquí» en el diccionario; la posición se guarda
  por versión y se restaura sin sonar sola.
- 61 pruebas. Verificado contra el backend real en la web (MP3 con rangos 206 y palabra hablada resaltada). Lo que
  exige un teléfono queda en `docs/platform/device-verification.md`, sin marcar.

## Fase 2 — Lector inmersivo, diccionario en contexto y biblioteca (2026-11-09)

- Lector a pantalla completa: Newsreader con seis tamaños, tres interlineados, tres anchos y temas claro, sepia y
  oscuro; modo sin distracciones; avance y minutos restantes; reanuda en la oración donde se quedó.
- Cada párrafo es un único `RichText` con un tramo por palabra; se reconstruye solo el párrafo que cambia.
- Diccionario en contexto (hoja inferior en teléfono, panel lateral desde 900 dp): lema, «forma de», categoría, IPA,
  traducción y definición primero; ejemplos, sinónimos, antónimos, relacionadas, gramática y formas al expandir; sin
  entrada, lo dice. Guardar en el cuaderno con la oración (`tokenRef`).
- Oración: traducir a demanda, guardar en notas con comentario, copiar. Párrafo: traducción a demanda o siempre.
- Resaltar guardadas (fondo), nuevas (punteado) y aprendidas (subrayado), nunca solo por color.
- Base local drift/SQLite sin generación (ADR-0009): contenido inmutable cacheado, preferencias y progreso, que se
  guarda primero en el dispositivo y se une con el del servidor sin pisar lo nuevo (`mergeProgress`).
- Marcador, notas, «Terminé de leer» con su cierre, y «Mis lecturas» (en curso, guardadas, terminadas).
- 47 pruebas. Verificado contra el backend real (guardar palabra 201, progreso 200, biblioteca al 47 %).

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
