#!/bin/bash
# document.sh — Documentación automática con IA
# Uso: curl -fsSL https://raw.githubusercontent.com/jadevx/parcial-arq-nub/main/document.sh | bash -s -- <KIRO_API_KEY> [output_path]
# O con env var: KIRO_API_KEY=xxx bash document.sh
#
# Variables opcionales:
#   APP_URL      — URL de la app para capturas de pantalla
#   APP_USER     — Usuario para login
#   APP_PASSWORD — Contraseña para login

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
[ -n "$APP_URL" ] && echo "App URL: $APP_URL (capturas habilitadas)"

# 1. Instalar Node.js (si no existe)
echo "--- Verificando Node.js ---"
if ! command -v node &> /dev/null; then
  curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
  sudo apt-get install -y nodejs
fi

# 2. Instalar Kiro CLI
echo "--- Instalando Kiro CLI ---"
if ! command -v kiro-cli &> /dev/null; then
  curl -fsSL https://cli.kiro.dev/install | bash
  export PATH="$HOME/.local/bin:$PATH"
fi

# 3. Instalar Pandoc + XeLaTeX
echo "--- Instalando Pandoc + LaTeX ---"
if ! command -v pandoc &> /dev/null; then
  sudo apt-get update -qq
  sudo apt-get install -y -qq pandoc texlive-xetex texlive-fonts-recommended fonts-dejavu
fi

# 4. Instalar Playwright (para capturas)
echo "--- Instalando Playwright ---"
npm init -y --silent 2>/dev/null || true
npm install playwright --silent 2>/dev/null || true
npx playwright install chromium --with-deps 2>/dev/null || true

# 5. Clonar repo del agente documentador
echo "--- Clonando agente documentador ---"
AGENT_DIR=$(mktemp -d)
git clone --depth 1 "$AGENT_REPO" "$AGENT_DIR"

# 6. Copiar configuración del agente al proyecto
echo "--- Configurando agente ---"
mkdir -p "$WORK_DIR/.kiro/agents" "$WORK_DIR/.kiro/steering"
cp "$AGENT_DIR/.kiro/agents/documenter.json" "$WORK_DIR/.kiro/agents/"
cp "$AGENT_DIR/.kiro/steering/"*.md "$WORK_DIR/.kiro/steering/"

# 7. Ejecutar agente documentador
echo "--- Ejecutando agente IA ---"
mkdir -p "$WORK_DIR/docs" "$WORK_DIR/docs/screenshots" "$WORK_DIR/scripts/screenshots"
kiro-cli chat \
  --agent documenter \
  --no-interactive \
  "Analiza el código fuente de este repositorio y genera la documentación completa siguiendo los steerings. Incluye capturas de pantalla si APP_URL está disponible (APP_URL=$APP_URL). Guarda el resultado en docs/DOCUMENTACION.md con las imágenes en docs/screenshots/"

# 8. Verificar que se generó el markdown
if [ ! -f "$WORK_DIR/docs/DOCUMENTACION.md" ]; then
  echo "Error: El agente no generó docs/DOCUMENTACION.md"
  exit 1
fi

# 9. Convertir a PDF
echo "--- Convirtiendo a PDF ---"
OUTPUT_DIR=$(dirname "$OUTPUT_PATH")
mkdir -p "$OUTPUT_DIR"

cd "$WORK_DIR/docs"
pandoc DOCUMENTACION.md \
  -o "$WORK_DIR/$OUTPUT_PATH" \
  --pdf-engine=xelatex \
  -V geometry:margin=2.5cm \
  -V mainfont="DejaVu Sans" \
  -V monofont="DejaVu Sans Mono" \
  -V lang=es \
  -V colorlinks=false \
  --toc \
  --toc-depth=3 \
  --resource-path=.
cd "$WORK_DIR"

# 10. Limpiar
echo "--- Limpiando ---"
rm -rf "$AGENT_DIR"
rm -rf "$WORK_DIR/.kiro"
rm -f "$WORK_DIR/docs/DOCUMENTACION.md"
rm -rf "$WORK_DIR/docs/screenshots"
rm -rf "$WORK_DIR/scripts/screenshots"

echo "=== Documentación generada: $OUTPUT_PATH ==="
ls -lh "$OUTPUT_PATH"
