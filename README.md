# parcial-arq-nub — Agente Documentador con IA

## Qué es

Un agente de IA que documenta automáticamente cualquier proyecto de software. Incluye un script `document.sh` que se puede invocar desde cualquier pipeline CI/CD.

## Uso rápido

Desde el pipeline de tu proyecto:

```bash
curl -fsSL https://raw.githubusercontent.com/jadevx/parcial-arq-nub/main/document.sh | bash -s -- "$KIRO_API_KEY"
```

Esto genera `docs/documentation.pdf` en tu repositorio.

### Con ruta personalizada

```bash
curl -fsSL https://raw.githubusercontent.com/jadevx/parcial-arq-nub/main/document.sh | bash -s -- "$KIRO_API_KEY" "output/mi-doc.pdf"
```

## Qué hace el script

1. Instala Kiro CLI (si no existe)
2. Instala Pandoc + XeLaTeX (si no existen)
3. Clona este repo para obtener la configuración del agente
4. Copia el agente y steering al proyecto
5. Ejecuta Kiro CLI en modo headless — la IA analiza el código
6. Convierte el Markdown generado a PDF con Pandoc
7. Limpia archivos temporales

## Arquitectura

```
parcial-arq-nub/
├── .kiro/
│   ├── agents/documenter.json    ← Definición del agente IA
│   └── steering/documentacion.md ← Instrucciones (prompt engineering)
├── document.sh                    ← Script autocontenido
└── README.md
```

## Requisitos del runner

- Linux (Ubuntu recomendado)
- curl, git, bash
- Acceso a internet
- `KIRO_API_KEY` válida

## Ejemplo en GitHub Actions

```yaml
- name: Generar documentación
  env:
    KIRO_API_KEY: ${{ secrets.KIRO_API_KEY }}
  run: |
    curl -fsSL https://raw.githubusercontent.com/jadevx/parcial-arq-nub/main/document.sh | bash -s -- "$KIRO_API_KEY"
```
