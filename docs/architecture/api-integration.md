# Integración con la API

## 1. Contrato

La app usa el contrato **existente** de `wasichai/lesen`, descrito en su `docs/architecture/api-design.md` y publicado en
`/api/lesen/public/openapi`. No hay endpoints propios del móvil.

| Grupo       | Endpoints que usa la app                                                                    |
| ----------- | ------------------------------------------------------------------------------------------- |
| Acceso      | `POST /api/auth/login` → `{token, expiresAt, user}`; `GET /api/auth/me/permissions`         |
| Público     | `public/languages`, `public/topics`, `public/covers/{f}.svg`, `public/audio/{f}` (rangos)   |
| Perfil      | `GET/PUT learner/profile` (404 = sin onboarding)                                            |
| Catálogo    | `discover`, `readings?…`, `readings/{slug}`                                                 |
| Lectura     | `readings/{slug}/versions/{n}/{content,translations,audio,assessment}`                      |
| Biblioteca  | `library`, `readings/{slug}/{progress,completion,bookmark,notes}`, `notes/{id}`, `lists/**` |
| Diccionario | `dictionary/{lookup,search,entries/{key},history,favorites}`                                |
| Vocabulario | `vocabulary`, `vocabulary/{id,keys,known,stats}`, `vocabulary/reviews{,/next}`              |
| Comprensión | `assessments/{id}/attempts`, `attempts/{id}`, `attempts/{id}/answers/{q}/self-assessment`   |
| Progreso    | `progress/{dashboard,weekly,achievements,goals}`                                            |

## 2. DTO

DTO escritos a mano, inmutables, con `fromJson` que valida lo que el cliente necesita y lanza `ContractException` si
falta (ADR-0004). Se eligió frente a generar el cliente desde OpenAPI porque el documento solo existe con el backend en
marcha (necesita credenciales de GitHub Packages para Wasichai) y no cubre `/api/auth/*`; un generador en CI añadiría un
backend vivo a cada compilación. A cambio, las pruebas de contrato parsean las **fixtures capturadas del backend real**
por `lesen-ui` (`test/fixtures/lesen.json`, copiado con su procedencia) y los recorridos de integración se ejecutan
contra el backend de verdad cuando está disponible.

Reglas de evolución: campos desconocidos se ignoran; enumeraciones desconocidas se mapean a un valor `unknown` sin
romper la pantalla; un campo nuevo opcional no exige versión nueva de la app.

## 3. Errores

`application/problem+json` (`{type, title, status, detail, errors[{field, message}]}`) → `ApiFailure`. Un 404 en
recursos «todavía no hay» (perfil, progreso, audio, traducción, evaluación) es `null`, no un error. Un 401 cierra la
sesión; un 403 es «tu cuenta no tiene acceso a esto».

## 4. Huecos

Lo que el móvil necesitaría y el backend no tiene. Ninguno se simula: la app lo rodea en el cliente y lo dice.

| Hueco                         | Efecto en la app hoy                                                                    | Contrato propuesto (para `wasichai/lesen` o Wasichai)                                                                                                            | Dónde              |
| ----------------------------- | --------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------ |
| Refresco de token             | Al caducar, se vuelve a pedir la contraseña; lo pendiente se conserva                   | `POST /api/auth/refresh` con un token de refresco rotatorio de un solo uso, ligado al dispositivo                                                                | Wasichai           |
| Registro público              | Sin alta desde la app: la cuenta la crea quien administra                               | Ya pedido aguas arriba por el backend (roadmap §Aguas arriba)                                                                                                    | Wasichai           |
| Avisos push                   | Recordatorios **locales** programados en el dispositivo                                 | `PUT /api/lesen/devices/{installationId}` `{platform, pushToken, locale, timeZone}`; `DELETE` al salir                                                           | Wasichai + `lesen` |
| Paquete para descargar        | Cinco peticiones por lectura (contenido, traducciones, audio, evaluación, portada)      | `GET readings/{slug}/versions/{n}/bundle` con todo lo inmutable de la versión y un `ETag`                                                                        | `lesen`            |
| Cambios desde una fecha       | La biblioteca y el cuaderno se piden enteros al sincronizar                             | `?updatedSince=` en `library`, `vocabulary` y `vocabulary/known`                                                                                                 | `lesen`            |
| URL absolutas                 | Portadas y audio llegan relativas; el cliente las resuelve contra su `API_BASE_URL`     | Aceptable; si se mueven a wasichai-files (fase 6 del backend), que lleguen absolutas                                                                             | `lesen`            |
| Texto de oración y offsets    | El cliente reconstruye el texto con `text + space`                                      | Opcional: `sentence.text` en la vista de contenido                                                                                                               | `lesen`            |
| Varios idiomas de estudio     | El perfil tiene un solo `targetLanguage`; cambiarlo es editar el perfil                 | Perfiles por idioma; fuera del alcance actual                                                                                                                    | `lesen`            |
| Audio de pronunciación        | El panel muestra la IPA; no hay audio por palabra (la narración llega en la fase 3)     | `audioUrl` opcional en la entrada del diccionario, generado como la narración                                                                                    | `lesen`            |
| Ilustraciones en el texto     | Solo hay portada; la lectura y su descarga no llevan imágenes entre párrafos            | Bloque `{type: "image", id, url, width, height, alt, caption?}` entre párrafos en `content`, inmutable por versión y con `alt` obligatorio; entra en el `bundle` | `lesen`            |
| Borrado de cuenta             | Requisito de las tiendas: se documenta el procedimiento manual                          | `DELETE /api/lesen/me` (y el de Wasichai) antes de publicar en las tiendas                                                                                       | Wasichai + `lesen` |
| Identidad visual en la cuenta | La identidad y el modo se guardan en cada dispositivo (ADR-0011); no viajan entre ellos | Un campo `direction` (`musgo`, `gaceta`, `pulso`, `atlas`, `papel`) en `/auth/me/preferences`, junto a `theme` y `locale` (ADR-034 de Wasichai)                  | Wasichai           |

Nada de esto se implementa en el backend desde este repositorio: se abrirá como issue allí cuando haga falta.

## 5. Fixtures de desarrollo

`test/fixtures/lesen.json` y `test/fixtures/audio/der-alte-leuchtturm.mp3` vienen de
`wasichai/lesen-ui/e2e/fixtures/`, capturados del backend real con su demo (`model/apply.py --demo`). Se usan solo en
pruebas y en un servidor de fixtures de desarrollo (`tool/`), nunca en una compilación de release.
