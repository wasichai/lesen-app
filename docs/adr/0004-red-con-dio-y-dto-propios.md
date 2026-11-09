# ADR-0004 — Red con dio y DTO escritos a mano, probados contra fixtures reales

Estado: aceptada (2026-11-09)

## Contexto

El backend publica OpenAPI solo en tiempo de ejecución (`/api/lesen/public/openapi`), sin cubrir `/api/auth/*`, y
arrancarlo exige credenciales de GitHub Packages. La web valida cada respuesta con zod.

## Decisión

- `dio` como cliente HTTP único, con interceptores de sesión y de errores, tiempos de espera y cancelación.
- DTO inmutables escritos a mano con `fromJson` que falla con `ContractException` si falta lo que el cliente usa, y
  tolera campos y enumeraciones nuevos. Separados de los modelos de dominio y de UI.
- Pruebas de contrato con las fixtures capturadas del backend real por `lesen-ui`.

## Consecuencias

- Cambiar el contrato exige tocar el DTO a mano; a cambio, la CI no depende de un backend vivo.
- Si el backend llega a versionar su OpenAPI en el repositorio, se reconsiderará generar el cliente (con una ADR nueva).
