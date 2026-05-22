#!/bin/bash
# document.sh — Documentación automática con IA
# Flujo: Levantar app (si frontend) → Kiro genera MD → Pandoc → HTML → Playwright → PDF
#
# Uso: curl -fsSL https://raw.githubusercontent.com/jadevx/parcial-arq-nub/main/document.sh | bash -s -- <KIRO_API_KEY> [output_path]

set -e

KIRO_API_KEY="${1:-$KIRO_API_KEY}"
OUTPUT_PATH="${2:-docs/documentation.pdf}"
AGENT_REPO="https://github.com/jadevx/parcial-arq-nub.git"
WORK_DIR=$(pwd)
APP_PID=""

if [ -z "$KIRO_API_KEY" ]; then
  echo "Error: Se requiere KIRO_API_KEY como argumento o variable de entorno"
  exit 1
fi

export KIRO_API_KEY

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

# 3. Instalar Playwright en el directorio de trabajo
echo "--- Instalando Playwright ---"
cd "$WORK_DIR"
npm init -y --silent 2>/dev/null || true
npm install playwright --silent 2>/dev/null || true
npx playwright install chromium --with-deps 2>/dev/null || true

# 4. Clonar repo del agente documentador
echo "--- Clonando agente documentador ---"
AGENT_DIR=$(mktemp -d)
git clone --depth 1 "$AGENT_REPO" "$AGENT_DIR"

# 5. Detectar si hay frontend y levantar la app
echo "--- Detectando frontend ---"
HAS_FRONTEND=false
APP_URL=""

# Buscar archivos de frontend
if find "$WORK_DIR" -maxdepth 3 -name "*.html" -o -name "*.jsx" -o -name "*.tsx" -o -name "*.vue" -o -name "*.svelte" 2>/dev/null | grep -q .; then
  HAS_FRONTEND=true
fi
# Buscar carpetas de frontend
if [ -d "$WORK_DIR/public" ] || [ -d "$WORK_DIR/views" ] || [ -d "$WORK_DIR/templates" ] || [ -d "$WORK_DIR/frontend" ] || [ -d "$WORK_DIR/client" ]; then
  HAS_FRONTEND=true
fi

if [ "$HAS_FRONTEND" = true ]; then
  echo "Frontend detectado. Levantando app localmente..."
  # Instalar dependencias del proyecto
  if [ -f "$WORK_DIR/package.json" ]; then
    npm install --silent 2>/dev/null || true
  fi
  # Levantar la app en background
  if [ -f "$WORK_DIR/package.json" ]; then
    npm start &>/dev/null &
    APP_PID=$!
    sleep 5
    APP_URL="http://localhost:3000"
    echo "App levantada en $APP_URL (PID: $APP_PID)"
  fi
else
  echo "No se detectó frontend. Se omitirán capturas de pantalla."
fi

export APP_URL

# 6. Copiar configuración del agente al proyecto
echo "--- Configurando agente ---"
mkdir -p "$WORK_DIR/.kiro/agents" "$WORK_DIR/.kiro/steering"
cp "$AGENT_DIR/.kiro/agents/documenter.json" "$WORK_DIR/.kiro/agents/"
cp "$AGENT_DIR/.kiro/steering/"*.md "$WORK_DIR/.kiro/steering/"

# 7. Ejecutar agente documentador (timeout 5 min)
echo "--- Ejecutando agente IA ---"
mkdir -p "$WORK_DIR/docs" "$WORK_DIR/docs/screenshots"
timeout 300 kiro-cli chat \
  --agent documenter \
  --no-interactive \
  "Analiza el código fuente de este repositorio y genera la documentación completa siguiendo los steerings. Este proyecto $([ "$HAS_FRONTEND" = true ] && echo "TIENE frontend, APP_URL=$APP_URL, toma capturas con Playwright" || echo "NO tiene frontend, es solo API, NO tomes capturas"). Guarda el resultado en docs/DOCUMENTACION.md" || {
  echo "WARN: Kiro CLI excedió el timeout o falló"
  if [ ! -f "$WORK_DIR/docs/DOCUMENTACION.md" ]; then
    echo "Error: No se generó documentación"
    # Matar app si estaba corriendo
    [ -n "$APP_PID" ] && kill $APP_PID 2>/dev/null || true
    exit 1
  fi
}

# 8. Matar la app local
[ -n "$APP_PID" ] && kill $APP_PID 2>/dev/null || true

# 9. Verificar markdown
if [ ! -f "$WORK_DIR/docs/DOCUMENTACION.md" ]; then
  echo "Error: El agente no generó docs/DOCUMENTACION.md"
  exit 1
fi
echo "--- Markdown generado correctamente ---"

# 10. Convertir MD → HTML
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

# 11. Convertir HTML → PDF
echo "--- Convirtiendo HTML a PDF ---"
OUTPUT_DIR=$(dirname "$OUTPUT_PATH")
mkdir -p "$OUTPUT_DIR"
node "$AGENT_DIR/templates/html-to-pdf.js" "$WORK_DIR/docs/DOCUMENTACION.html" "$WORK_DIR/$OUTPUT_PATH" "$WORK_DIR"

# 12. Limpiar
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
