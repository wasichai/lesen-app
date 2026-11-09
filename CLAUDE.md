# Lesen — app móvil

Aprender idiomas leyendo, en iOS y Android. Este repositorio es el cliente Flutter de la plataforma Lesen: el backend
vive en `wasichai/lesen` y la web en `wasichai/lesen-ui`. Antes de cambiar algo, lee `docs/architecture/overview.md`,
`docs/architecture/mobile-architecture.md` y las ADR de `docs/adr/`.

## Stack (no negociable sin ADR nueva)

Flutter estable · Dart estable · Riverpod (ADR-0002) · go_router (ADR-0003) · dio con DTO propios (ADR-0004) · drift y
flutter_secure_storage (ADR-0005) · just_audio + audio_service (ADR-0006) · ARB con `gen-l10n`.

## Reglas

1. **El backend manda.** Nada de corregir preguntas, calcular intervalos FSRS ni métricas del panel en Dart. Si falta un
   endpoint, se documenta en `docs/architecture/api-integration.md` y se pide allí.
2. **Nada inventado.** Sin entrada, traducción, audio o corrección, la app lo dice. Las fixtures (`test/fixtures/`) solo
   existen en pruebas y en el servidor de desarrollo; nunca en release.
3. **Capas.** Los widgets no hablan HTTP ni ven DTO: `presentation → application → domain ← data`.
4. **Nada se pierde.** Toda escritura personal pasa por la cola de operaciones (ADR-0007).
5. **El lector no se reconstruye entero** por un evento de audio: solo el párrafo que cambia.
6. **Ningún secreto** en el repositorio ni en la app: ni claves de proveedores, ni firmas, ni `key.properties`.
7. **Accesibilidad**: etiquetas semánticas, texto escalable, 44 dp, ningún estado solo por color.
8. Sin sobreingeniería: una abstracción necesita un segundo uso concreto.

## Forma de trabajar

- Código y nombres técnicos en inglés; documentación, comentarios y mensajes de commit en español.
- Conventional Commits (commitlint, cabecera ≤ 100). Una ADR aceptada no se edita: se reemplaza con otra.
- Lo entregado va a `docs/HISTORY.md`, lo más nuevo arriba.
- Definition of Done, ejecutado y en verde: `dart format --set-exit-if-changed lib test`, `flutter analyze`,
  `flutter test` y `yarn format:check`.
- Cada fase: una issue, una PR que la cierra y merge con la CI en verde.
