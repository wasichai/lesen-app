# ADR-0008 — «Papel y tinta» en Flutter: Material 3 de base con identidad propia

Estado: aceptada (2026-11-09)

## Contexto

La app no debe parecer una app Material genérica, y la web ya tiene una identidad editorial (`lesen-ui`,
`docs/design-system/lesen/`): papel cálido, tinta profunda, terracota como único acento, Newsreader y Source Sans 3,
traducción a un toque y nunca por defecto, nada que castigue un día sin leer.

## Decisión

- Se portan los tokens de la web a una `ThemeExtension` (`LesenTokens`) sobre `ThemeData` de Material 3, con
  esquemas claro y oscuro de la app y tres temas del lector (claro, sepia, oscuro).
- Newsreader y Source Sans 3 se empaquetan (licencia SIL OFL, con su licencia en `assets/fonts/`).
- Composición adaptable propia: teléfono (barra inferior, hojas inferiores) y tableta ≥ 600 dp (raíl, dos columnas,
  panel lateral del diccionario), no una ampliación del teléfono.
- Contraste AA comprobado en pruebas, como en la web; ningún estado solo por color; movimiento reducido respetado.

## Consecuencias

- La web y el móvil se reconocen como el mismo producto; un cambio de marca toca los tokens de ambos.
