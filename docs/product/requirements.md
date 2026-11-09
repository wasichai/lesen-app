# Requisitos — Lesen móvil

Lesen móvil es el cliente nativo (iOS y Android, teléfono y tableta) de la plataforma Lesen: aprender idiomas leyendo.
No es una versión móvil de un LMS ni una vista web empaquetada. Comparte el backend con la web (`wasichai/lesen-ui`) y
no duplica su lógica: el backend (`wasichai/lesen`) es la fuente de verdad del catálogo, el contenido publicado, la
identidad, el cuaderno, el repaso, las evaluaciones y el progreso.

## Recorrido principal

1. Entrar con la cuenta de Wasichai (correo y contraseña).
2. Completar el perfil: idioma de la interfaz, idioma de estudio, nivel MCER, metas, temas y minutos diarios.
3. Descubrir lecturas: recomendadas, seguir leyendo, destacadas, de la semana, recientes, colecciones y temas.
4. Filtrar el catálogo por tema, nivel, idioma y duración; buscar.
5. Abrir una lectura, escucharla con resaltado palabra a palabra y seguir escuchando con la pantalla bloqueada.
6. Tocar una palabra: diccionario en contexto sin perder la posición; guardarla.
7. Terminar la lectura y responder las preguntas de comprensión; ver la corrección explicada con citas del texto.
8. Encontrar la palabra en el cuaderno y repasarla (FSRS-5).
9. Ver el progreso: lo medido separado de lo estimado, sin castigos por un día sin leer.
10. Descargar otra lectura, leerla y escucharla sin conexión, y que el progreso se sincronice al volver la red.

## Requisitos funcionales

| Área         | Requisito                                                                                                                          | Backend                                |
| ------------ | ---------------------------------------------------------------------------------------------------------------------------------- | -------------------------------------- |
| Acceso       | Login con correo y contraseña; token en almacenamiento seguro; caducidad → volver a entrar sin perder lo pendiente                 | Existe (`/api/auth/login`)             |
| Perfil       | Onboarding corto, por pasos; interfaz, estudio y nivel independientes                                                              | Existe (`learner/profile`)             |
| Descubrir    | Secciones de `discover`; tarjetas con portada, nivel, minutos, progreso y estado                                                   | Existe                                 |
| Catálogo     | Filtros (tema, nivel, idioma, minutos, estado), orden, búsqueda, paginación                                                        | Existe (`readings`)                    |
| Lector       | Tipografía ajustable, temas claro/sepia/oscuro, ancho, modo sin distracciones, progreso, tiempo restante, reanudar                 | Existe (contenido versionado)          |
| Palabra      | Toque → panel compacto (lema, traducción, categoría, IPA, formas) que se expande; guardar; abrir la entrada completa               | Existe (`dictionary/lookup`)           |
| Oración      | Pulsación larga → traducir, nota, copiar, reproducir desde aquí                                                                    | Existe (traducciones, notas)           |
| Audio        | Reproductor integrado y mini reproductor; velocidad; ±oración, ±párrafo, ±5 s; segundo plano y controles del sistema               | Existe (activos y tiempos por palabra) |
| Sincronía    | Palabra y oración habladas resaltadas; desplazamiento automático que cede ante el dedo; tocar para reproducir desde ahí            | Existe                                 |
| Diccionario  | Búsqueda en ambos sentidos, historial, favoritas, ficha completa, lecturas donde aparece                                           | Existe                                 |
| Cuaderno     | Estados SAVED → LEARNING → FAMILIAR → MASTERED (y «encontrada»); filtros; notas; repaso espaciado                                  | Existe (FSRS-5, ADR-0010 del backend)  |
| Comprensión  | Diez tipos de pregunta; corrección por reglas, asistida (con cita) o autoevaluación; intentos pendientes sin conexión              | Existe (ADR-0009 del backend)          |
| Progreso     | Panel con métricas `MEASURED`/`ESTIMATED`, 28 días, racha semanal amable, metas, logros, resumen semanal                           | Existe (ADR-0011 del backend)          |
| Biblioteca   | En curso, marcadas, terminadas; listas propias                                                                                     | Existe                                 |
| Sin conexión | Descargar texto, traducciones, portada, audio, tiempos y preguntas; gestionar almacenamiento; cola de operaciones y sincronización | Cliente (ver `offline-strategy.md`)    |
| Avisos       | Recordatorios de lectura y de repaso, configurables y discretos                                                                    | Locales: no hay API de avisos (hueco)  |

## Requisitos no funcionales

- **Rendimiento.** Ninguna actualización de posición del audio reconstruye el documento: solo el párrafo activo.
  Listas perezosas, imágenes cacheadas, consultas locales indexadas.
- **Accesibilidad.** VoiceOver y TalkBack, texto escalable, objetivos de 44 dp como mínimo, movimiento reducido, contraste
  AA, ningún estado solo por color (la palabra hablada lleva subrayado además del fondo).
- **Privacidad y seguridad.** El token solo en el llavero/Keystore; ninguna clave de proveedor en la app; registros sin
  datos personales; nada personal se muestra a otra cuenta.
- **Localización.** Interfaz en español e inglés (ARB); idioma de estudio e idioma de traducción son datos.
- **Nada inventado** (ADR-0005 del backend): si no hay entrada, traducción, audio o corrección, la app lo dice; los
  datos de demostración solo existen en desarrollo y pruebas.
