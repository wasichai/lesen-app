# Estrategia sin conexión

Sin conexión no es un extra: quien lee en el metro o en un avión debe poder leer, escuchar, consultar lo guardado,
repasar y responder preguntas, y nada de lo que haga se pierde.

## 1. Qué se guarda y dónde

| Dato                                                  | Dónde                                        | Por qué                                                  |
| ----------------------------------------------------- | -------------------------------------------- | -------------------------------------------------------- |
| Token y usuario                                       | `flutter_secure_storage` (Keychain/Keystore) | Credencial: nunca en preferencias                        |
| Preferencias de lectura y de la app                   | Base local (`drift`)                         | Consultable y migrable                                   |
| Contenido de versiones                                | Base local, JSON por (slug, versión)         | Inmutable (ADR-0003 del backend): se cachea para siempre |
| Traducciones, audio (metadatos y tiempos), evaluación | Base local, por (slug, versión)              | Igual de inmutables                                      |
| Archivos de audio y portadas                          | Directorio de soporte de la app              | Binarios grandes fuera de SQLite                         |
| Tarjetas, perfil, biblioteca, cuaderno                | Base local como proyección                   | Mostrar algo sin red; la verdad está en el servidor      |
| Operaciones pendientes                                | Tabla `outbox`                               | Que nada se pierda                                       |

## 2. Descargas

Una descarga es explícita («Descargar para leer sin conexión») e incluye contenido, traducciones (oración y párrafo en
el idioma de interfaz), metadatos de audio y tiempos, el archivo de audio, la evaluación y la portada. Estados:
`queued → downloading(progress) → done | failed | cancelled`. Se puede cancelar, reintentar y borrar; la pantalla de
descargas muestra el espacio usado. Con «solo por Wi-Fi», el archivo de audio espera a una red sin coste. Lo
descargado se reproduce desde el archivo local; lo no descargado, en streaming con rangos. La descarga va por dio con la app abierta (ADR-0010).

## 3. Cola de operaciones

Cada escritura se aplica primero a la proyección local (la pantalla responde al momento) y se encola:

| Operación       | Endpoint                              | Idempotencia                                                                                                   |
| --------------- | ------------------------------------- | -------------------------------------------------------------------------------------------------------------- |
| Progreso        | `PUT readings/{slug}/progress`        | Natural (valor total); se **colapsa**: solo el último                                                          |
| Terminar        | `POST readings/{slug}/completion`     | Natural en el backend                                                                                          |
| Marcador        | `PUT/DELETE readings/{slug}/bookmark` | Natural; se colapsa por slug                                                                                   |
| Guardar palabra | `POST vocabulary`                     | 201/200 según existiera                                                                                        |
| Nota de palabra | `PATCH vocabulary/{id}`               | Natural; se colapsa                                                                                            |
| Repaso          | `POST vocabulary/reviews`             | `clientId` UUID generado al responder                                                                          |
| Nota de oración | `POST readings/{slug}/notes`          | No natural: se envía una vez; si la respuesta se pierde, se reconcilia con `GET notes` por (sentenceRef, nota) |
| Intento         | `POST assessments/{id}/attempts`      | Igual que las notas, con `GET attempts` del `lastAttempt`                                                      |

La cola se vacía en orden, al arrancar, al volver la red, al volver la app a primer plano, cada minuto y tras cada
escritura. Errores de red → espera exponencial con tope (2 s, 4 s, … 5 min); mientras la primera espera, las de detrás
también, para no alterar el orden. Un 4xx que no sea 401/408/429 es definitivo: la operación se
marca como rechazada y se muestra en el estado de sincronización, nunca se borra en silencio. Un 401 detiene la cola
hasta volver a entrar.

## 4. Conflictos

- **Progreso.** El backend solo sube el porcentaje dentro de una versión y guarda `secondsRead` como total. Al abrir
  una lectura con red se piden el progreso del servidor y el local; gana el de `updatedAt` más reciente para la
  **posición**, el mayor para el **porcentaje** y el mayor para los **segundos**. Así leer en el móvil sin red y luego
  en la web no pisa lo más nuevo con lo viejo. Si el servidor tiene otra versión vigente, se respeta la del progreso
  del servidor hasta que la persona abra la nueva.
- **Repaso.** El servidor decide el estado FSRS. Un repaso hecho sin red se envía con su `clientId`; si la palabra se
  había repasado ya en otro sitio, el servidor aplica ambos en orden de llegada (comportamiento del backend).
- **Cuaderno y marcadores.** Último que escribe gana; las proyecciones se refrescan del servidor tras vaciar la cola.

## 5. Evaluaciones sin conexión

Si la evaluación está descargada se puede responder sin red. El intento queda como «pendiente de enviar» y, al
enviarse, como «pendiente de evaluar» hasta que el servidor corrige: el cliente **no** corrige nada (el backend es la
autoridad, ADR-0009 del backend).

## 6. Experiencia

Un aviso discreto en la cabecera («Sin conexión: puedes leer lo descargado»), nunca diálogos; las acciones que
necesitan red se desactivan con su motivo; un indicador de sincronización con lo pendiente y lo rechazado.

## 7. Implementación

| Pieza                                            | Dónde                                                          |
| ------------------------------------------------ | -------------------------------------------------------------- |
| Cola, colapso, espera, rechazos                  | `lib/core/sync/outbox.dart`                                    |
| Tipos de operación, disparadores, estado         | `lib/core/sync/sync.dart`                                      |
| Lecturas con copia (`cacheFirst`/`networkFirst`) | `lib/core/storage/cache.dart`                                  |
| Descargas y preferencia de Wi-Fi                 | `lib/features/downloads/application/downloads_controller.dart` |
| Unión de progresos                               | `lib/features/reader/domain/reading_progress.dart`             |

El recorrido completo (descargar, modo avión, leer, avanzar, volver la red, sincronizar) está probado en
`test/features/offline_test.dart`; el modo avión real en un teléfono queda en `docs/platform/device-verification.md`.
