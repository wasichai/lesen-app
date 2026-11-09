# ADR-0002 — Estado con Riverpod, sin generación de código

Estado: aceptada (2026-11-09)

## Contexto

La app combina datos remotos con caché, estado local muy frecuente (posición de audio) y servicios de larga vida
(reproductor, sincronización). Las opciones maduras son Riverpod y BLoC.

## Decisión

`flutter_riverpod` como único marco de estado e inyección de dependencias. Sin `riverpod_generator` ni `freezed`: la
generación añade `build_runner` a cada cambio y la app no lo necesita para ser tipada.

## Consecuencias

- Las pruebas sustituyen repositorios con `overrides` sin un contenedor aparte.
- El estado de alta frecuencia (palabra activa) no pasa por Riverpod: usa `ValueListenable` filtrados para no
  reconstruir de más (`docs/architecture/audio-synchronization.md`).
