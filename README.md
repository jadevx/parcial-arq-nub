# parcial-arq-nub — Documentación Automática con IA

## Qué es

Pipeline de documentación automática que usa **Kiro CLI en modo headless** para analizar código fuente y generar documentación completa en PDF. Incluye:

- Documentación funcional (manual de usuario)
- Documentación técnica (endpoints, modelos, arquitectura)
- Diagramas Mermaid (C4, secuencia, casos de uso)
- Capturas de pantalla automáticas con Playwright (opcional)

## Uso rápido

Desde cualquier pipeline CI/CD:

```bash
curl -fsSL https://raw.githubusercontent.com/jadevx/parcial-arq-nub/main/document.sh | bash -s -- "$KIRO_API_KEY"
```

Genera `docs/documentation.pdf` en tu repositorio.

### Con capturas de pantalla

```bash
export APP_URL="http://tu-app.com"
export APP_USER="usuario"
export APP_PASSWORD="clave"
curl -fsSL https://raw.githubusercontent.com/jadevx/parcial-arq-nub/main/document.sh | bash -s -- "$KIRO_API_KEY"
```

### Con ruta personalizada

```bash
curl -fsSL https://raw.githubusercontent.com/jadevx/parcial-arq-nub/main/document.sh | bash -s -- "$KIRO_API_KEY" "output/mi-doc.pdf"
```

## Qué hace el script

1. Instala Kiro CLI, Pandoc, XeLaTeX, Playwright
2. Clona este repo para obtener el agente y steerings
3. Ejecuta el agente IA en modo headless
4. El agente analiza el código, toma capturas (si hay URL), genera Markdown
5. Pandoc convierte el Markdown a PDF (blanco y negro)
6. Limpia archivos temporales
7. Deja solo el PDF en la ruta indicada

## Arquitectura

```
parcial-arq-nub/
├── .kiro/
│   ├── agents/documenter.json         ← Agente IA (tools: read, grep, glob, code, write, shell)
│   └── steering/
│       ├── documentacion.md           ← Proceso principal
│       ├── documentacion-funcional.md ← Guía funcional
│       ├── documentacion-no-funcional.md ← Guía técnica
│       ├── capturas-pantalla.md       ← Sistema de screenshots
│       └── diagramacion.md            ← Diagramas Mermaid
├── document.sh                         ← Script autocontenido
└── README.md
```

## Ejemplo en GitHub Actions

```yaml
name: Documentación con IA
on:
  push:
    branches: [docs]
jobs:
  documentar:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Generar documentación
        env:
          KIRO_API_KEY: ${{ secrets.KIRO_API_KEY }}
          APP_URL: ${{ secrets.APP_URL }}
        run: |
          curl -fsSL https://raw.githubusercontent.com/jadevx/parcial-arq-nub/main/document.sh | bash -s -- "$KIRO_API_KEY"
      - uses: actions/upload-artifact@v4
        with:
          name: documentacion
          path: docs/documentation.pdf
```

## Requisitos del runner

- Ubuntu (GitHub Actions runner estándar)
- Acceso a internet
- Secret `KIRO_API_KEY`
