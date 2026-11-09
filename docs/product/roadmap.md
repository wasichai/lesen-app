# Hoja de ruta — Lesen móvil

Cada fase se entrega con una issue, una PR y un merge con la CI en verde. Ninguna fase se da por terminada porque una
pantalla exista: lo nuevo lleva pruebas y documentación.

| Fase | Contenido                                                                                                                                                             | Criterio de salida                                                                                  | Estado    |
| ---- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------- | --------- |
| 0    | Auditoría de `lesen` y `lesen-ui`, arquitectura, estrategia offline y de audio, huecos de la API, ADR                                                                 | Documentos de `docs/` y ADR 0001–0008; CI de commits y formato                                      | Hecha     |
| 1    | Proyecto Flutter, sistema de diseño, l10n es/en, configuración por entorno, cliente HTTP, sesión, login, onboarding, navegación adaptable, Descubrir, catálogo, ficha | Una persona entra, completa el onboarding y encuentra una lectura de su nivel en teléfono y tableta | Hecha     |
| 2    | Lector inmersivo, palabra en contexto, traducciones, notas, marcadores, posición, biblioteca                                                                          | Leer → tocar palabra → guardarla → cerrar y volver a la misma oración                               | Hecha     |
| 3    | Motor de audio, segundo plano y controles del sistema, resaltado sincronizado, navegación por oración y párrafo, mini reproductor                                     | Audio de demostración con la palabra hablada resaltada; el lector sin audio sigue igual             | Hecha     |
| 4    | Cuaderno, repaso FSRS, diccionario completo, comprensión con los diez tipos de pregunta y su corrección                                                               | Una lectura evaluada y explicada; un repaso que cambia la próxima fecha de una palabra              | Pendiente |
| 5    | Base local, descargas, lector y audio sin conexión, cola de operaciones, sincronización y conflictos, intentos sin conexión                                           | Leer en modo avión, volver la red y ver el progreso en la web                                       | Pendiente |
| 6    | Panel de progreso, metas, racha amable, logros, resumen semanal, listas, recomendaciones, recordatorios                                                               | El panel separa lo medido de lo estimado y nada castiga un día sin leer                             | Pendiente |
| 7    | Accesibilidad, seguridad, rendimiento, sabores de compilación, firma, CI de iOS, documentación de publicación                                                         | Revisión documentada; compilaciones de release reproducibles sin secretos en el repositorio         | Pendiente |

## Lo que no se puede verificar en este entorno

La CI y el contenedor de desarrollo son Linux sin dispositivos. Se verifica con pruebas unitarias, de widgets y de
integración (también contra el backend real cuando arranca), compilación Android y capturas de la versión web. Quedan
para dispositivos reales, y se marcan como pendientes en cada PR: audio con la pantalla bloqueada, llamadas entrantes,
auriculares y Bluetooth, modo avión, compilación y firma de iOS y publicación en tiendas.
