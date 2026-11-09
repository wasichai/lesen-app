# Accesibilidad

Revisión de la fase 7. Lo automático se comprueba en `test/app/accessibility_test.dart`; lo que necesita un lector de
pantalla real está en `docs/platform/device-verification.md`.

| Pauta               | Cómo                                                                                                                      | Prueba      |
| ------------------- | ------------------------------------------------------------------------------------------------------------------------- | ----------- |
| Contraste AA        | Tokens de la app y de los tres temas del lector ≥ 4,5:1 (texto) y ≥ 7:1 (texto de lectura)                                | Automática  |
| Objetivos táctiles  | ≥ 48 dp (Android) y ≥ 44 pt (iOS) en Descubrir, catálogo, ficha, lector, vocabulario y progreso                           | Automática  |
| Etiquetas           | Todo lo tocable tiene nombre (`labeledTapTargetGuideline`); tarjetas con «título, idioma, nivel, minutos»                 | Automática  |
| Texto escalable     | Las pantallas principales al 200 % sin desbordes; rejillas con altura proporcional                                        | Automática  |
| No solo color       | Palabra abierta o hablada: negrita y subrayado; nueva: punteado; estados con icono y texto; lo estimado con «≈» y palabra | Revisión    |
| Movimiento reducido | Anillos, transiciones del onboarding, del repaso y del desplazamiento respetan `disableAnimations`                        | Revisión    |
| Idioma del texto    | Lo que está en el idioma de estudio lleva su `Locale` (lectura, entradas, ejemplos, opciones)                             | Revisión    |
| Anuncios            | Guardar palabra, errores, resultados y avance de descarga se anuncian (`liveRegion`, `sendAnnouncement`)                  | Revisión    |
| Palabras tocables   | Cada palabra es un tramo con reconocedor; los lectores de pantalla los exponen como enlaces                               | Dispositivo |
| Hojas y diálogos    | Hojas modales con asa y cierre por gesto o botón; el foco vuelve al texto                                                 | Dispositivo |
