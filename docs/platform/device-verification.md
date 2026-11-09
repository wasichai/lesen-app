# Verificación en dispositivos

La CI y el contenedor de desarrollo no tienen dispositivos. Esta lista se recorre a mano en un Android y un iPhone
reales antes de publicar, y se anota el resultado (fecha, dispositivo, versión del sistema) en la PR o en
`docs/HISTORY.md`.

## Audio (fase 3)

| Caso                                                            | Esperado                                                        | Android | iOS |
| --------------------------------------------------------------- | --------------------------------------------------------------- | ------- | --- |
| Reproducir y bloquear la pantalla                               | Sigue sonando; controles en la pantalla de bloqueo              | ☐       | ☐   |
| Pasar a otra app                                                | Sigue sonando; notificación multimedia (Android)                | ☐       | ☐   |
| Botones de auriculares y Bluetooth: reproducir/pausa, siguiente | Pausa y reanuda; siguiente y anterior van por párrafo           | ☐       | ☐   |
| Desconectar los auriculares                                     | Se pausa; no suena por el altavoz                               | ☐       | ☐   |
| Llamada entrante                                                | Se pausa; al colgar, reanuda solo si el sistema lo indica       | ☐       | ☐   |
| Otra app reproduce audio                                        | Lesen cede el foco (pausa)                                      | ☐       | ☐   |
| Cerrar la app desde multitarea                                  | Para; al volver, la lectura recuerda la posición sin sonar sola | ☐       | ☐   |
| Velocidad 1,5×                                                  | El resaltado sigue a la voz sin retraso visible                 | ☐       | ☐   |
| TalkBack/VoiceOver sobre la barra de audio                      | Cada control dice su nombre y la posición «0:12 de 1:12»        | ☐       | ☐   |

## Sin conexión (fase 5)

| Caso                                                         | Esperado                                                 | Android | iOS |
| ------------------------------------------------------------ | -------------------------------------------------------- | ------- | --- |
| Descargar una lectura con Wi-Fi                              | Progreso, «Descargada · disponible sin conexión»         | ☐       | ☐   |
| Con «solo Wi-Fi» y datos móviles                             | El texto se descarga; el audio espera                    | ☐       | ☐   |
| Modo avión: abrir la lectura descargada, escucharla, avanzar | Todo funciona; aviso discreto con los cambios pendientes | ☐       | ☐   |
| Quitar el modo avión                                         | Se sincroniza solo; el progreso aparece en la web        | ☐       | ☐   |
| Responder las preguntas sin red                              | «Respuestas guardadas»; al volver la red se corrigen     | ☐       | ☐   |
