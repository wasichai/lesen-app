# Fixtures

Copiadas de `wasichai/lesen-ui/e2e/fixtures/`, que las captura del backend real con su contenido de demostración
(`capture.mjs`, `model/apply.py --demo`). Son respuestas del contrato, no datos inventados, y solo se usan en pruebas.

- `lesen.json`: idiomas, temas, colecciones, tarjetas y, de tres lecturas, ficha, contenido, traducciones, entradas,
  audio y evaluación.
- `audio/der-alte-leuchtturm.mp3`: narración eSpeak NG de la lectura con audio (licencia en su `voice.license`).

- `notebook.json`, `assessment.json`, `attempt.json`: capturados del backend local con su demo (`lena` y `tomas`,
  2026-11-09): cuaderno, repaso, estadísticas, búsqueda y entrada del diccionario, preguntas y un intento corregido.

- `progress.json`: panel, resumen semanal, logros, metas y listas capturados del backend local (2026-11-09).

- `illustrations/`: la ilustración de la demostración de «Der alte Leuchtturm» (`der-alte-leuchtturm-sturm.svg`, de
  `wasichai/lesen` `src/main/resources/demo/illustrations/`) y sus `blocks` (`der-alte-leuchtturm.blocks.json`). Los
  bloques se compusieron con los datos de esa demo (`demo/readings/der-alte-leuchtturm.json`, `images[0]`, tras el
  tercer párrafo) y la regla de `ContentBlock.of` del backend, porque el backend local de la captura era anterior a la
  ADR-0018. Hay que volver a capturarlos de un backend con la ADR-0018 en cuanto se pueda.

Al cambiar el contrato del backend, se vuelven a capturar allí y se copian aquí.

- `design/{gaceta,pulso,musgo,atlas}.json`: las identidades visuales (ADR-0011), copiadas de
  `wasichai/lesen-ui/docs/design-system/lesen/explorations/tokens/`. La prueba de paridad
  (`test/app/design_directions_test.dart`) comprueba que `lib/app/theme/explorations/` dice lo mismo.
