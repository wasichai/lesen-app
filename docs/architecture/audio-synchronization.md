# Audio y sincronización

## 1. Datos

`GET readings/{slug}/versions/{n}/audio` → `{assets[{id, voice, url, format, durationMs, origin, timings, sentences,
paragraphs}]}` (ADR-0008 del backend). `timings` es `[[tokenId, startMs, endMs]]`, solo de palabras, ordenado, sin
solapes y anclado a los ids de token de esa versión inmutable. `sentences` y `paragraphs` dan el tramo de cada oración y
párrafo. Hasta un 5 % de palabras puede no tener tiempo (lo dicho y lo escrito no casan). Sin audio: 404 y el lector
funciona igual.

## 2. Motor

`just_audio` para reproducir y `audio_service` para la sesión del sistema (ADR-0006):

- **Android:** `MediaSession`, notificación multimedia con servicio en primer plano mientras suena, foco de audio,
  pausa al desconectar auriculares (`ACTION_AUDIO_BECOMING_NOISY`), controles de pantalla de bloqueo, auriculares y
  Bluetooth.
- **iOS:** `AVAudioSession` en categoría `playback` (vía `audio_session`), `UIBackgroundModes: audio`, interrupciones
  (llamadas, Siri) con reanudación solo si el sistema lo sugiere, controles de pantalla de bloqueo y del Centro de
  control.
- El `AudioHandler` vive fuera del árbol de widgets (lo crea el arranque y lo expone un proveedor): reconstruir una
  pantalla nunca reinicia el reproductor.
- Se restaura la última posición por (slug, versión) al volver a abrir la lectura, sin reproducir solo.
- Fuente: archivo local si está descargado; si no, la URL con rangos.

## 3. Palabra activa

`TimingIndex` (dominio, puro y probado) guarda tres arreglos paralelos ordenados (`start`, `end`, `tokenId`). Para una
posición `t`, una búsqueda binaria da el último `start ≤ t`; si `t ≤ end + 250 ms` (el mismo margen que la web,
`LINGER_MS`) esa palabra sigue activa, si no ninguna. Lo mismo para oraciones y párrafos. Coste `O(log n)` por evento.

## 4. Resaltado sin reconstruir el documento

- La posición llega del reproductor como flujo; un único `ActiveTokenController` la convierte en
  `(paragraphId, sentenceId, tokenId)` y **solo emite cuando cambia**.
- Cada párrafo escucha un `ValueListenable` filtrado a su id: al pasar de una palabra a la siguiente se reconstruye un
  `RichText`, no la lista. Los párrafos fuera de pantalla no existen (`ListView.builder`).
- La palabra hablada lleva fondo **y** subrayado grueso (no solo color); la oración, un fondo suave.
- Ninguna animación toca el reloj del audio.

## 5. Desplazamiento

Se desplaza solo cuando la oración activa sale de la zona visible (con márgenes), con una animación corta (o salto si el
movimiento está reducido). Si la persona desplaza con el dedo, el seguimiento se suspende 4 s; un botón «Volver a lo
que suena» lo recupera.

## 6. Interacción

- Tocar una palabra con el reproductor activo y «tocar para reproducir» activado → salta a su `startMs`; si no, abre el
  diccionario.
- Pulsación larga sobre una oración → «Reproducir desde aquí».
- Controles: reproducir/pausa, ±5 s, oración anterior/siguiente, párrafo anterior/siguiente, velocidad 0,75–1,5,
  posición, duración y buffering.
- Mini reproductor encima de la barra de navegación mientras hay una lectura cargada; el reproductor completo, fuera del
  armazón.

## 7. Accesibilidad

Los controles tienen etiquetas semánticas y valores («Velocidad 1,25×»); el lector anuncia la oración en curso solo si
quien escucha lo pide (anunciarla siempre se pisaría con la narración).
