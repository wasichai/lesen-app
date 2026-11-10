# Laboratorio de direcciones de diseño

Un banco de pruebas, reversible y fuera de producción, para ver la app con cuatro direcciones de diseño alternativas a
«Papel y tinta» (ADR-0008): **Gaceta**, **Pulso**, **Musgo** y **Atlas**. La identidad de la app no cambia: el
laboratorio solo existe en una compilación de depuración del entorno dev y, fuera de ella, la dirección es siempre
«Papel y tinta» (`DesignDirection.actual`).

Las direcciones se definen una vez, para la web y para la app, en `wasichai/lesen-ui`:
[`docs/design-system/lesen/explorations/`](https://github.com/wasichai/lesen-ui/tree/main/docs/design-system/lesen/explorations)
(los tokens en `tokens/<dirección>.json` y su resolución en `scripts/design-directions.mjs`). Aquí solo se traducen a
Dart.

## Cómo activarlo

```sh
flutter run --flavor dev --dart-define-from-file=config/dev.json
```

Con `APP_ENV == 'dev'` y `kDebugMode` aparece un botón redondo de 44 dp («Laboratorio de diseño», icono de paleta)
abajo a la izquierda. Abre una hoja para elegir la dirección y el modo (sistema, claro u oscuro). La elección no se
guarda: al reiniciar la app vuelve «Papel y tinta». El papel del lector (claro, sepia, oscuro) sigue siendo una
preferencia de la lectura, como siempre; el laboratorio cambia sus colores dentro de la dirección.

## Piezas

| Pieza                                         | Qué hace                                                                                |
| --------------------------------------------- | --------------------------------------------------------------------------------------- |
| `lib/app/theme/tokens.dart`                   | `LesenTokens` lleva colores, tonos, familias, radios y escala tipográfica (`LesenType`) |
| `lib/app/theme/theme.dart`                    | `buildTheme(brightness, tokens: …)` construye el `ThemeData` con esos tokens            |
| `lib/app/theme/explorations/<dirección>.dart` | Tokens claro y oscuro y paletas del lector, generados de los JSON de lesen-ui           |
| `lib/app/theme/explorations/directions.dart`  | `enum DesignDirection { actual, gaceta, pulso, musgo, atlas }`                          |
| `lib/app/design_lab/design_lab.dart`          | `designDirectionProvider`, `designThemeModeProvider`, el botón y la hoja                |
| `lib/app/design_lab/explore_fonts.dart`       | Registra con `FontLoader` las familias que la dirección necesita                        |
| `assets/fonts/explore/`                       | TTF variables de Google Fonts (OFL, con su `OFL-<familia>.txt`)                         |

Los widgets ya no escriben familias ni radios a mano: leen `LesenTokens.of(context)` (`readingFont`, `displayFont`,
`interfaceFont`, `radiusLg`, `tones`…). `ReaderPalette.of(theme, direction: …)` da el papel del lector de la dirección.

## Correspondencia de tokens

Los colores salen de `resolveTheme`: las anclas de `light` o `dark` y, para el lector, encima las de `reader-light`,
`reader-sepia` o `reader-dark`.

| Token compartido (JSON)              | Variable CSS (lesen-ui)                      | Campo Dart                                                     |
| ------------------------------------ | -------------------------------------------- | -------------------------------------------------------------- |
| `color.surface`                      | `--surface`                                  | `LesenTokens.surface` · `ReaderPalette.paper`                  |
| `color.surface-muted`                | `--surface-muted`                            | `LesenTokens.surfaceMuted`                                     |
| `color.surface-raised`               | `--surface-raised`                           | `LesenTokens.surfaceRaised`                                    |
| `color.ink`                          | `--ink`                                      | `LesenTokens.ink` · `ReaderPalette.ink`                        |
| `color.ink-muted`                    | `--ink-muted`                                | `LesenTokens.inkMuted` · `ReaderPalette.inkMuted`              |
| `color.brand`                        | `--brand`                                    | `LesenTokens.brand` · `ReaderPalette.brand`                    |
| `color.brand-strong`                 | `--brand-strong`                             | `LesenTokens.brandStrong`                                      |
| `color.brand-soft`                   | `--brand-soft`                               | `LesenTokens.brandSoft` · `ReaderPalette.active`               |
| `color.on-brand`                     | `--on-brand`                                 | `LesenTokens.onBrand`                                          |
| `color.focus`                        | `--focus`                                    | `LesenTokens.focus`                                            |
| `color.mark-saved`                   | `--mark-saved`                               | `LesenTokens.markSaved` · `ReaderPalette.saved`                |
| `color.mark-new`                     | `--mark-new`                                 | `LesenTokens.markNew`                                          |
| `color.mark-sentence`                | `--mark-sentence`                            | `LesenTokens.markSentence` · `ReaderPalette.sentence`          |
| `color.sea`, `sage`, `ochre`, `plum` | `--sea`, `--sage`, `--ochre`, `--plum`       | `LesenTokens.tones` (en ese orden)                             |
| `font.display`                       | `--font-display`                             | `LesenTokens.displayFont`                                      |
| `font.read`                          | `--font-read`                                | `LesenTokens.readingFont`                                      |
| `font.sans`                          | `--font-sans`                                | `LesenTokens.interfaceFont`                                    |
| `type.display`                       | `--text-display--font-weight/letter-spacing` | `LesenType.display` → `displayLarge/Medium/Small`              |
| `type.h1` … `type.h4`                | `--text-h1--…` … `--text-h4--…`              | `LesenType.h1…h4` → `headlineLarge/Medium/Small`, `titleLarge` |
| `type.label`                         | `--text-label--font-weight`                  | `LesenType.label` → `labelLarge/Medium/Small`                  |
| `shape.radius.sm/md/lg/xl/card`      | `--radius-sm/md/lg/xl/card`                  | `LesenTokens.radiusSm/Md/Lg/Xl/Card`                           |
| `shape.button`                       | `--radius-button`                            | `LesenTokens.buttonRadius` (9999 → `StadiumBorder`)            |
| `shape.chip`                         | `--radius-chip`                              | `LesenTokens.chipRadius` (9999 → `StadiumBorder`)              |

Notas:

- La familia en Dart es la primera de la pila CSS sin espacios: `'Source Serif 4'` → `SourceSerif4`.
- El `tracking` va en em y se multiplica por el tamaño (`TypeStep.letterSpacing`); «Papel y tinta» conserva su
  −0,2 px fijo.
- No se traducen (no hay dónde usarlos todavía en la app): `border`, `border-control`, `accent`, los estados
  (`danger`, `success`, `warning`, `notice`), `mark-saved-ink`, `shadow.*` y `shape.radius.base`.

## Fuentes y flavors

Las fuentes de exploración (unos 6,5 MB: Fraunces, Source Serif 4, IBM Plex Sans, Plus Jakarta Sans, Literata,
Manrope y Geist, con cursiva donde existe) se declaran como assets **solo del flavor dev**:

```yaml
assets:
  - path: assets/fonts/explore/
    flavors: [dev]
```

y se registran con `FontLoader` al elegir la dirección, antes de cambiar el tema. Atlas usa Newsreader, que ya viene
de serie.

- **Android e iOS**: `--flavor dev` las incluye; staging y prod, no. Comprobado con el manifiesto de assets que arma
  la herramienta (`flutter test --flavor dev` lista los 20 archivos de `assets/fonts/explore/`; `--flavor prod` y
  `--flavor staging`, ninguno).
- **`flutter test`** sin flavor no las incluye. Los goldens leen los TTF del disco y los registran con `FontLoader`.
- **Web**: `flutter build web` no admite `--flavor` y deja fuera los assets con flavor. El laboratorio funciona igual
  (colores, radios, pesos), pero las familias de exploración caen en la de reserva. Para verlas en la web, se quita
  `flavors` en local, sin hacer commit; cuesta esos 6,5 MB en la descarga de la compilación web.

## Pruebas

- `test/app/design_directions_test.dart`: paridad Dart ↔ JSON (copias en `test/fixtures/design/`), «Papel y tinta»
  intacta y `copyWith`.
- `test/app/accessibility_test.dart`: los mismos umbrales de contraste, objetivos táctiles y texto al 200 % en las cinco
  direcciones.
- `test/design/direction_goldens_test.dart` (etiqueta `design`): teléfono 390×844 claro y oscuro (Descubrir, catálogo,
  ficha, lector, hoja del diccionario, mini reproductor, reproductor, vocabulario y progreso) y tableta 1024×768 clara
  (Descubrir, lector con panel lateral y progreso), en las cinco direcciones. Salen en `test/design/goldens/<dirección>/`.
  Dependen de la plataforma que los dibuja (se generaron en macOS), así que la ejecución por defecto los salta:

  ```sh
  flutter test --tags design --run-skipped                  # comparar
  flutter test --tags design --run-skipped --update-goldens # regenerar
  ```

  `exclude_tags` no sirve para esto: package:test lo combina con `--tags` y no dejaría pedirlos nunca.

## Cambiar o borrar una dirección

- **Cambiar**: se edita el JSON en lesen-ui, se copia a `test/fixtures/design/` y se regenera
  `lib/app/theme/explorations/<dirección>.dart`; la prueba de paridad dice si falta algo.
- **Borrar una**: se quita su valor del `enum` y sus ramas en `directions.dart`, su archivo en `explorations/`, su JSON
  en `test/fixtures/design/`, sus goldens y las fuentes que solo use ella (de `assets/fonts/explore/` y de
  `exploreFontFiles`).
- **Borrar el laboratorio**: además, `lib/app/design_lab/`, `assets/fonts/explore/`, el bloque `assets` de
  `pubspec.yaml`, las dos líneas de `app.dart` y `reader_screen.dart` que leen los providers, la etiqueta `design` de
  `dart_test.yaml`, `designOverrides` de `test/support/harness.dart` y `test/design/`. Los tokens en el tema (familias, radios, escala) pueden quedarse: son los de
  «Papel y tinta».
- **Adoptar una**: no se hace aquí. Hace falta una ADR nueva que reemplace a la ADR-0008.
