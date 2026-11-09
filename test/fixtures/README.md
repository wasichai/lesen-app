# Fixtures

Copiadas de `wasichai/lesen-ui/e2e/fixtures/`, que las captura del backend real con su contenido de demostración
(`capture.mjs`, `model/apply.py --demo`). Son respuestas del contrato, no datos inventados, y solo se usan en pruebas.

- `lesen.json`: idiomas, temas, colecciones, tarjetas y, de tres lecturas, ficha, contenido, traducciones, entradas,
  audio y evaluación.
- `audio/der-alte-leuchtturm.mp3`: narración eSpeak NG de la lectura con audio (licencia en su `voice.license`).

- `notebook.json`, `assessment.json`, `attempt.json`: capturados del backend local con su demo (`lena` y `tomas`,
  2026-11-09): cuaderno, repaso, estadísticas, búsqueda y entrada del diccionario, preguntas y un intento corregido.

- `progress.json`: panel, resumen semanal, logros, metas y listas capturados del backend local (2026-11-09).

Al cambiar el contrato del backend, se vuelven a capturar allí y se copian aquí.
