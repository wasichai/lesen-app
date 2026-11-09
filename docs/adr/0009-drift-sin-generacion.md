# ADR-0009 — drift sin generación de código: SQL con valores ligados

Estado: aceptada (2026-11-09). Reemplaza en parte a [ADR-0005](0005-base-local-drift-y-almacen-seguro.md): solo lo que
decía de `build_runner` y del código generado.

## Contexto

ADR-0005 eligió drift sobre SQLite y preveía tablas declaradas en Dart con `build_runner`, como excepción a ADR-0002. Al
empezar la base (fase 2) lo que hace falta son pocas tablas con consultas simples, y el backend ya trabaja con SQL
explícito y valores ligados (`DatabaseClient`). Generar código añade un paso a cada cambio y archivos que revisar.

## Decisión

- drift como conexión, transacciones, migraciones y ejecución en segundo plano (`NativeDatabase.createInBackground`),
  pero **sin tablas generadas**: `LocalDatabase` declara su esquema como migraciones SQL numeradas y aditivas, y las
  consultas van con `customSelect`/`customStatement` y variables ligadas.
- La primera tabla es `kv` (espacio, clave, JSON, fecha): preferencias, progreso local y contenido inmutable de
  versiones. Las tablas de la fase 5 (descargas, cola de operaciones) se añaden como migraciones nuevas.
- Pruebas con `NativeDatabase.memory()`; la compilación web de desarrollo usa `MemoryLocalStore`.

## Consecuencias

- Sin `build_runner` en todo el proyecto (ADR-0002 se cumple sin excepciones).
- Si las consultas crecen hasta necesitar tipos generados, se reconsiderará con otra ADR.
