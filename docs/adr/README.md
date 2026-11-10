# Decisiones de arquitectura

Una ADR aceptada no se edita: si cambia la decisión, se escribe otra que la reemplaza y se enlazan. Las decisiones del
backend viven en `wasichai/lesen/docs/adr/` y se citan como «ADR-NNNN del backend».

| ADR                                                    | Decisión                                                                                   |
| ------------------------------------------------------ | ------------------------------------------------------------------------------------------ |
| [0001](0001-cliente-flutter-separado.md)               | Cliente Flutter propio, separado de la web y sin lógica del backend                        |
| [0002](0002-estado-con-riverpod.md)                    | Estado con Riverpod, sin generación de código                                              |
| [0003](0003-navegacion-con-go-router.md)               | Navegación declarativa con go_router                                                       |
| [0004](0004-red-con-dio-y-dto-propios.md)              | Red con dio y DTO escritos a mano, probados contra fixtures reales                         |
| [0005](0005-base-local-drift-y-almacen-seguro.md)      | Base local con drift y token en almacenamiento seguro                                      |
| [0006](0006-audio-just-audio-y-audio-service.md)       | Audio con just_audio y audio_service                                                       |
| [0007](0007-sin-conexion-cola-y-conflictos.md)         | Sin conexión primero: proyecciones locales, cola de operaciones y conflictos               |
| [0008](0008-sistema-de-diseno-papel-y-tinta.md)        | «Papel y tinta» en Flutter: Material 3 de base con identidad propia (reemplazada por 0011) |
| [0009](0009-drift-sin-generacion.md)                   | drift sin generación de código: SQL con valores ligados (reemplaza en parte a 0005)        |
| [0010](0010-descargas-en-primer-plano-y-cola-en-kv.md) | Descargas con dio en primer plano y cola sobre `kv` (reemplaza en parte a 0007 y 0009)     |
| [0011](0011-identidad-seleccionable.md)                | Cinco identidades visuales elegidas en el perfil, Musgo por defecto (reemplaza a 0008)     |
