# Arquitectura de la app

## 1. Capas

Arquitectura limpia pragmática, por funcionalidad. Cada funcionalidad separa solo lo que tiene un segundo uso:

| Capa            | Contiene                                                                    | Depende de       |
| --------------- | --------------------------------------------------------------------------- | ---------------- |
| `presentation/` | Pantallas y widgets; leen proveedores, no hablan HTTP                       | `application`    |
| `application/`  | Proveedores y notificadores de Riverpod (estado, casos de uso)              | `domain`, `data` |
| `domain/`       | Modelos inmutables y reglas del cliente (índices del lector, tiempos, etc.) | nada             |
| `data/`         | DTO (`fromJson`), repositorios, acceso a la API y a la base local           | `core`, `domain` |

Los DTO nunca llegan a los widgets: el repositorio los convierte en modelos de dominio. Una funcionalidad pequeña
puede no tener `domain/` propio.

## 2. Estructura

```
lib/
  app/            arranque, configuración, rutas, tema, l10n
  core/           red, sesión, almacenamiento, base local, audio, sincronización, errores, widgets comunes
  features/
    auth/  onboarding/  profile/  discover/  catalog/  reader/  audio_player/
    dictionary/  vocabulary/  comprehension/  library/  progress/  downloads/  settings/
l10n/             ARB es/en
test/             unitarias y de widgets, con fixtures capturadas del backend
integration_test/ recorridos completos
```

## 3. Estado: Riverpod

Un único marco (ADR-0002): `flutter_riverpod` sin generación de código. Proveedores `FutureProvider`/`AsyncNotifier`
para lo que viene de la API, `Notifier` para estado local, `.family` por slug/versión y `autoDispose` salvo en lo que
debe sobrevivir a la pantalla (sesión, reproductor, cola de sincronización). Las pruebas sustituyen dependencias con
`ProviderScope(overrides: …)`.

## 4. Navegación: go_router

- `StatefulShellRoute.indexedStack` con cuatro ramas (Descubrir, Mis lecturas, Vocabulario, Progreso) que conservan su
  pila.
- El lector, el reproductor completo, el repaso y la evaluación van **fuera** del armazón: pantalla completa sin barra.
- Redirección global: sin sesión → `/login`; con sesión y sin perfil (404) → `/onboarding`.
- Enlaces profundos `lesen://reading/{slug}` y `https://…/readings/{slug}`: solo se aceptan rutas conocidas con slugs
  que cumplen `^[a-z0-9-]{1,120}$`; cualquier otra cosa lleva a Descubrir.
- Los nombres de ruta son constantes tipadas (`Routes.reader(slug)`), nunca cadenas sueltas.

## 5. Red

`dio` con un único cliente (`core/networking`):

- `baseUrl` = `API_BASE_URL` del entorno + `/api`; las URL relativas de portadas y audio se resuelven contra él.
- Interceptor de sesión: añade `Authorization: Bearer`; ante un 401 cierra la sesión (no hay refresco) y conserva la
  cola de operaciones pendientes.
- Mapeo de errores a `ApiFailure` sellado: `offline`, `timeout`, `unauthorized`, `forbidden`, `notFound`, `conflict`,
  `validation(errors)`, `server`, `contract` (respuesta que no casa con el DTO).
- Tiempos de espera: 10 s de conexión, 20 s de respuesta. `CancelToken` por pantalla.
- Reintento solo de errores de red y solo en llamadas idempotentes (GET, PUT de progreso, repaso con `clientId`), con
  espera exponencial y como mucho dos veces; los 4xx/5xx se muestran con un botón de reintento.

## 6. Diseño

«Papel y tinta», el sistema de `lesen-ui` (`docs/design-system/lesen/`) llevado a Flutter (ADR-0008): Material 3 como
base, `ThemeExtension` propia con los tokens (papel, tinta, terracota, tonos de tema, marcas del lector), Newsreader
para títulos y lectura, Source Sans 3 para la interfaz (ambas OFL, empaquetadas). Composición distinta en teléfono
(barra inferior, hojas inferiores) y tableta (≥ 600 dp: raíl de navegación, rejilla de dos columnas, panel lateral del
diccionario). Respeta el texto escalable y `MediaQuery.disableAnimations`.

## 7. Localización

`flutter_localizations` + `gen-l10n` con ARB `es` (plantilla) y `en`. Tres idiomas independientes: el de la interfaz
(ARB), el de estudio (datos del perfil) y el de traducción (por defecto el de la interfaz; lo decide el backend). Todo
texto en idioma de estudio se pinta con su `Locale` para que la tipografía, la partición de palabras y los lectores de
pantalla usen el idioma correcto. Una prueba comprueba que `es` y `en` tienen las mismas claves.

## 8. Entornos

`--dart-define-from-file=config/<entorno>.json` con `API_BASE_URL`, `APP_ENV` y `APP_NAME`. `dev` apunta a
`http://10.0.2.2:8095` (emulador Android) o `http://localhost:8095`; `staging` y `prod` se rellenan al desplegar. Los
sabores nativos (identificador de app por entorno) llegan en la fase 7.
