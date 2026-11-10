# Identidades visuales

La app tiene cinco identidades y cada persona elige la suya en **Perfil → Apariencia** (ADR-0011):

- **Musgo**, la de por defecto;
- **Gaceta**, **Pulso** y **Atlas**;
- **«Papel y tinta»**, la clásica de la ADR-0008.

En la misma tarjeta se elige el modo: sistema, claro u oscuro. Las dos cosas se guardan en el dispositivo
(`localStore`, `prefs/appearance`) y `main` las lee antes del primer fotograma. La cuenta todavía no las guarda: el
campo está pedido en `docs/architecture/api-integration.md` (§4). El papel del lector (claro, sepia u oscuro) sigue
siendo una preferencia de la lectura; la identidad cambia sus colores.

Las identidades se definen una vez, para la web y para la app, en `wasichai/lesen-ui`:
[`docs/design-system/lesen/explorations/`](https://github.com/wasichai/lesen-ui/tree/main/docs/design-system/lesen/explorations).
Los tokens están en `tokens/<identidad>.json` y su resolución en `scripts/design-directions.mjs`. Aquí solo se
traducen a Dart.

## Piezas

| Pieza                                                        | Qué hace                                                                                |
| ------------------------------------------------------------ | --------------------------------------------------------------------------------------- |
| `lib/app/theme/tokens.dart`                                  | `LesenTokens` lleva colores, tonos, familias, radios y escala tipográfica (`LesenType`) |
| `lib/app/theme/theme.dart`                                   | `buildTheme(brightness, tokens: …)` construye el `ThemeData` con esos tokens            |
| `lib/app/theme/directions/<identidad>.dart`                  | Tokens claro y oscuro y paletas del lector, generados de los JSON de lesen-ui           |
| `lib/app/theme/directions/directions.dart`                   | `enum DesignDirection { musgo, gaceta, pulso, atlas, papel }`; `fallback` es Musgo      |
| `lib/features/profile/application/appearance_providers.dart` | `appearanceProvider`: identidad y modo, leídos y guardados en `localStore`              |
| `lib/features/profile/presentation/profile_screen.dart`      | La tarjeta «Apariencia»                                                                 |
| `assets/fonts/`                                              | TTF variables subconjuntadas, con su `OFL-<familia>.txt`                                |

Los widgets no escriben familias ni radios a mano: leen `LesenTokens.of(context)` (`readingFont`, `displayFont`,
`interfaceFont`, `radiusLg`, `tones`…). `ReaderPalette.of(theme, direction: …)` da el papel del lector de la identidad.

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

- La familia en Dart es la primera de la pila CSS, con el mismo nombre (`'Source Serif 4'`), y así se declara en
  `pubspec.yaml`.
- El `tracking` va en em y se multiplica por el tamaño (`TypeStep.letterSpacing`); «Papel y tinta» conserva su
  −0,2 px fijo.
- No se traducen (no hay dónde usarlos todavía en la app): `border`, `border-control`, `accent`, los estados
  (`danger`, `success`, `warning`, `notice`), `mark-saved-ink`, `shadow.*` y `shape.radius.base`.

## Fuentes

Todas van en todos los flavors y en la web, declaradas en el bloque `fonts:` de `pubspec.yaml`. Son Fraunces, Source
Serif 4, IBM Plex Sans, Plus Jakarta Sans, Literata, Manrope y Geist, con cursiva donde existe (Manrope no la tiene).
Newsreader y Source Sans 3 son las de siempre y no se tocan.

Para que el binario no crezca, cada TTF nueva se reduce así:

- **Peso variable.** Se conserva el eje `wght`: Flutter lo ajusta con `fontWeight`.
- **Ejes fijados.** Los demás se fijan en su valor por defecto, porque Flutter no los mueve solo: `opsz` (Literata 12,
  Source Serif 4 20), `wdth`, `SOFT` y `WONK`. Fraunces, que solo se usa en títulos, se fija en `opsz=72`.
- **Subconjunto.** Latin, latin-ext, signos del AFI y signos de uso común, sin hinting.

| Medida                     | Antes  | Después |
| -------------------------- | ------ | ------- |
| Las siete familias nuevas  | 6,4 MB | 2,3 MB  |
| Todo `assets/fonts/` (TTF) | —      | 4,2 MB  |

Ninguna de las familias nuevas tiene los signos del AFI (ɐ, ʁ, ɪ, ˈ…); solo Source Sans 3. Por eso el tema pone
`fontFamilyFallback: ['SourceSans3']` en las demás identidades, y la transcripción fonética se ve en todas.

Para regenerarlas, con [fonttools](https://github.com/fonttools/fonttools) (`pip install fonttools`) y los TTF de
`google/fonts` (`ofl/<familia>/`):

```sh
U="U+0000-00FF,U+0100-02FF,U+0300-036F,U+1E00-1EFF,U+2000-206F,U+20AC,U+2113,U+2122,U+2190-2193,U+2212,U+2215,U+2248,U+2260,U+2264-2265,U+FEFF,U+FFFD"
# 1. fijar los ejes que no son el peso (sin ejes extra, como Geist, se salta este paso)
fonttools varLib.instancer 'Literata[opsz,wght].ttf' opsz=drop -o /tmp/Literata.ttf
fonttools varLib.instancer 'Fraunces[SOFT,WONK,opsz,wght].ttf' opsz=72 SOFT=drop WONK=drop -o /tmp/Fraunces.ttf
# 2. subconjunto
pyftsubset /tmp/Literata.ttf --unicodes="$U" --layout-features='*' --no-hinting --output-file=assets/fonts/Literata.ttf
```

`drop` fija el eje en su valor por defecto. Para las cursivas se hace lo mismo con su archivo `-Italic`.

## Pruebas

- `test/features/appearance_test.dart`:
  - por defecto, Musgo y el modo del sistema; lo elegido se guarda y se recupera; un valor roto vuelve a Musgo;
  - en el perfil, elegir Gaceta cambia `LesenTokens` del tema; cada opción mide 48 dp y lleva `selected` y `button`.
- `test/app/design_directions_test.dart`:
  - paridad Dart ↔ JSON, con copias en `test/fixtures/design/`;
  - «Papel y tinta» intacta y `copyWith`;
  - cada familia declarada en `pubspec.yaml`, con sus archivos.
- `test/app/accessibility_test.dart`: los mismos umbrales de contraste, objetivos táctiles y texto al 200 % en las cinco
  identidades.
- `test/design/direction_goldens_test.dart` (etiqueta `design`), en las cinco identidades:
  - teléfono 390×844, claro y oscuro: Descubrir, catálogo, ficha, lector, hoja del diccionario, mini reproductor,
    reproductor, vocabulario y progreso;
  - tableta 1024×768, clara: Descubrir, lector con panel lateral y progreso.

  Salen en `test/design/goldens/<identidad>/`, con la hora fijada a las 9 para que el saludo de Descubrir no cambie.
  Dependen de la plataforma que los dibuja (se generaron en macOS), así que la ejecución por defecto los salta:

  ```sh
  flutter test --tags design --run-skipped                  # comparar
  flutter test --tags design --run-skipped --update-goldens # regenerar
  ```

  `exclude_tags` no sirve: package:test lo combina con `--tags`, y así no se podrían pedir nunca.

## Cambiar, añadir o quitar una identidad

- **Cambiar una.**
  1. Se edita el JSON en lesen-ui y se copia a `test/fixtures/design/`.
  2. Se regenera `lib/app/theme/directions/<identidad>.dart`; la prueba de paridad dice si falta algo.
  3. Se regeneran los goldens.
- **Quitar una.**
  1. Se borran su valor del `enum` y sus ramas en `directions.dart`.
  2. Se borran su archivo, su JSON, sus goldens y su nota en los ARB.
  3. Se borran las fuentes que solo use ella, de `assets/fonts/` y de `pubspec.yaml`.
  4. Una preferencia guardada con su nombre vuelve sola a Musgo.
- **Cambiar la de por defecto.** Se cambia `DesignDirection.fallback` y se escribe una ADR nueva.
