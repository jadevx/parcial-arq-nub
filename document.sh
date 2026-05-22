#!/bin/bash
# document.sh — Documentación automática con IA
# Flujo: Kiro genera MD → Pandoc convierte a HTML (con Mermaid) → Playwright genera PDF
#
# Uso: curl -fsSL https://raw.githubusercontent.com/jadevx/parcial-arq-nub/main/document.sh | bash -s -- <KIRO_API_KEY> [output_path]

set -e

KIRO_API_KEY="${1:-$KIRO_API_KEY}"
OUTPUT_PATH="${2:-docs/documentation.pdf}"
AGENT_REPO="https://github.com/jadevx/parcial-arq-nub.git"
WORK_DIR=$(pwd)

if [ -z "$KIRO_API_KEY" ]; then
  echo "Error: Se requiere KIRO_API_KEY como argumento o variable de entorno"
  exit 1
fi

export KIRO_API_KEY
export APP_URL="${APP_URL:-}"
export APP_USER="${APP_USER:-}"
export APP_PASSWORD="${APP_PASSWORD:-}"

echo "=== Pipeline de Documentación con IA ==="
echo "Proyecto: $WORK_DIR"
echo "Salida: $OUTPUT_PATH"

# 1. Instalar Kiro CLI
echo "--- Instalando Kiro CLI ---"
if ! command -v kiro-cli &> /dev/null; then
  curl -fsSL https://cli.kiro.dev/install | bash
  export PATH="$HOME/.local/bin:$PATH"
fi

# 2. Instalar Pandoc
echo "--- Instalando Pandoc ---"
if ! command -v pandoc &> /dev/null; then
  sudo apt-get update -qq
  sudo apt-get install -y -qq pandoc
fi

# 3. Clonar repo del agente documentador
echo "--- Clonando agente documentador ---"
AGENT_DIR=$(mktemp -d)
git clone --depth 1 "$AGENT_REPO" "$AGENT_DIR"

# 4. Instalar Playwright en el directorio de trabajo
echo "--- Instalando Playwright ---"
cd "$WORK_DIR"
npm init -y --silent 2>/dev/null || true
npm install playwright --silent 2>/dev/null || true
npx playwright install chromium --with-deps 2>/dev/null || true

# 5. Copiar configuración del agente al proyecto
echo "--- Configurando agente ---"
mkdir -p "$WORK_DIR/.kiro/agents" "$WORK_DIR/.kiro/steering"
cp "$AGENT_DIR/.kiro/agents/documenter.json" "$WORK_DIR/.kiro/agents/"
cp "$AGENT_DIR/.kiro/steering/"*.md "$WORK_DIR/.kiro/steering/"

# 6. Ejecutar agente documentador
echo "--- Ejecutando agente IA ---"
mkdir -p "$WORK_DIR/docs" "$WORK_DIR/docs/screenshots"
kiro-cli chat \
  --agent documenter \
  --no-interactive \
  "Analiza el código fuente de este repositorio y genera la documentación completa siguiendo los steerings. Guarda el resultado en docs/DOCUMENTACION.md con las imágenes referenciadas como screenshots/nombre.png"

# 7. Verificar que se generó el markdown
if [ ! -f "$WORK_DIR/docs/DOCUMENTACION.md" ]; then
  echo "Error: El agente no generó docs/DOCUMENTACION.md"
  exit 1
fi
echo "--- Markdown generado correctamente ---"

# 8. Convertir MD → HTML con Pandoc + template + filtro Lua
echo "--- Convirtiendo MD a HTML ---"
cd "$WORK_DIR/docs"
pandoc DOCUMENTACION.md \
  -o DOCUMENTACION.html \
  --template="$AGENT_DIR/templates/template.html" \
  --lua-filter="$AGENT_DIR/templates/mermaid-filter.lua" \
  --metadata title="Documentación del Proyecto" \
  --resource-path=.
cd "$WORK_DIR"
echo "--- HTML generado ---"

# 9. Convertir HTML → PDF con Playwright (renderiza Mermaid como SVG)
echo "--- Convirtiendo HTML a PDF ---"
OUTPUT_DIR=$(dirname "$OUTPUT_PATH")
mkdir -p "$OUTPUT_DIR"
node "$AGENT_DIR/templates/html-to-pdf.js" "$WORK_DIR/docs/DOCUMENTACION.html" "$WORK_DIR/$OUTPUT_PATH" "$WORK_DIR"

# 10. Limpiar
echo "--- Limpiando ---"
rm -rf "$AGENT_DIR"
rm -rf "$WORK_DIR/.kiro"
rm -f "$WORK_DIR/docs/DOCUMENTACION.md"
rm -f "$WORK_DIR/docs/DOCUMENTACION.html"
rm -rf "$WORK_DIR/docs/screenshots"
rm -f "$WORK_DIR/package.json" "$WORK_DIR/package-lock.json"
rm -rf "$WORK_DIR/node_modules"

echo "=== Documentación generada: $OUTPUT_PATH ==="
ls -lh "$OUTPUT_PATH"
