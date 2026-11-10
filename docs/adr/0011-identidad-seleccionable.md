# ADR-0011 — Identidad visual seleccionable en el perfil, con Musgo por defecto

Estado: aceptada (2026-11-10). Reemplaza a [ADR-0008](0008-sistema-de-diseno-papel-y-tinta.md) en la identidad única;
sigue en pie lo demás de ella: Material 3 de base con `LesenTokens`, composición adaptable propia y contraste AA por
prueba.

## Contexto

La ADR-0008 fijó «Papel y tinta» como la única identidad de la app. La exploración de lesen-ui
(`docs/design-system/lesen/explorations/`) dejó cuatro direcciones más: Gaceta, Pulso, Musgo y Atlas. Se probaron en
un laboratorio de desarrollo con los mismos tokens en la web y en Flutter. La decisión de producto es que cada persona
elija la suya y que, sin elegir, se vea Musgo.

La cuenta de Wasichai guarda `theme` y `locale` en `/auth/me/preferences` (ADR-034 de Wasichai), pero no tiene un campo
para la identidad. La regla «el backend manda» impide inventarlo en el cliente.

## Decisión

- Hay cinco identidades: **Musgo** (por defecto), Gaceta, Pulso, Atlas y «Papel y tinta», la clásica.
  - Cada una da tokens claros y oscuros y las tres paletas del lector.
  - Los tokens se generan de los JSON compartidos con lesen-ui.
  - Una prueba de paridad comprueba que Dart y JSON dicen lo mismo.
- La identidad y el modo (sistema, claro u oscuro) se eligen en el perfil.
  - Se guardan en el dispositivo (`localStore`, `prefs/appearance`), como las preferencias del lector.
  - No pasan por la cola de operaciones, porque no son una escritura del servidor.
  - `main` los lee antes del primer fotograma, para no pintar Musgo y saltar a otra.
- La sincronización entre dispositivos se pide al backend: un campo `direction` en las preferencias de cuenta
  (`docs/architecture/api-integration.md`, §4). Cuando exista, la preferencia local pasará a ser su copia.
- Las fuentes van autoalojadas en todos los flavors, declaradas en `pubspec.yaml`. Son de Google Fonts con licencia OFL.
  - Cada una es variable en peso.
  - Los demás ejes se fijan: `opsz`, `wdth`, `SOFT` y `WONK`, que Flutter no ajusta solo.
  - Se subconjuntan a latin, latin-ext y AFI: 2,3 MB las siete familias nuevas, frente a 6,4 MB completas.
  - La transcripción fonética cae en Source Sans 3, la única que tiene esos signos.
- El contraste AA se comprueba por prueba en las cinco identidades y en los tres papeles del lector. Las mismas pruebas
  miden objetivos táctiles y texto al 200 %.

## Consecuencias

- La app ya no tiene una sola cara: las capturas de tienda y la documentación deben decir cuál muestran.
- Cambiar una identidad es cambiar su JSON en lesen-ui y regenerar el archivo de Dart. Los goldens con la etiqueta
  `design` muestran el efecto en cada una.
- Quien cambia de dispositivo vuelve a Musgo hasta que exista el campo de cuenta.
- Riesgos de Musgo como identidad por defecto, anotados y sin cambiar por ahora:
  - El verde de marca `#2f5e45` se parece al `success` `#2d6a3a`. El éxito ya lleva icono y texto, nunca solo color.
  - Manrope no tiene cursiva, así que el «estimado» del progreso sale con cursiva sintetizada.
