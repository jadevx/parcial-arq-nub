#!/bin/bash
# document.sh — Script autocontenido de documentación con IA
# Uso: curl -fsSL https://raw.githubusercontent.com/jadevx/parcial-arq-nub/main/document.sh | bash -s -- <KIRO_API_KEY> [output_path]
#
# Argumentos:
#   $1 - KIRO_API_KEY (obligatorio)
#   $2 - Ruta de salida del PDF (opcional, default: docs/documentation.pdf)

set -e

KIRO_API_KEY="${1}"
OUTPUT_PATH="${2:-docs/documentation.pdf}"
AGENT_REPO="https://github.com/jadevx/parcial-arq-nub.git"
WORK_DIR=$(pwd)

if [ -z "$KIRO_API_KEY" ]; then
  echo "Error: Se requiere KIRO_API_KEY como primer argumento"
  echo "Uso: bash document.sh <KIRO_API_KEY> [output_path]"
  exit 1
fi

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
  sudo apt-get update -qq && sudo apt-get install -y -qq pandoc texlive-xetex texlive-fonts-recommended
fi

# 3. Clonar repo del agente documentador
echo "--- Clonando agente documentador ---"
AGENT_DIR=$(mktemp -d)
git clone --depth 1 "$AGENT_REPO" "$AGENT_DIR"

# 4. Copiar configuración del agente al proyecto
echo "--- Configurando agente ---"
mkdir -p "$WORK_DIR/.kiro/agents" "$WORK_DIR/.kiro/steering"
cp "$AGENT_DIR/.kiro/agents/documenter.json" "$WORK_DIR/.kiro/agents/"
cp "$AGENT_DIR/.kiro/steering/documentacion.md" "$WORK_DIR/.kiro/steering/"

# 5. Ejecutar agente documentador
echo "--- Ejecutando agente IA ---"
mkdir -p "$WORK_DIR/docs"
export KIRO_API_KEY
kiro-cli chat \
  --agent documenter \
  --no-interactive \
  "Analiza el código fuente de este repositorio y genera la documentación completa. Guarda el resultado en docs/DOCUMENTACION.md"

# 6. Convertir a PDF
echo "--- Convirtiendo a PDF ---"
OUTPUT_DIR=$(dirname "$OUTPUT_PATH")
mkdir -p "$OUTPUT_DIR"

pandoc "$WORK_DIR/docs/DOCUMENTACION.md" \
  -o "$WORK_DIR/$OUTPUT_PATH" \
  --pdf-engine=xelatex \
  -V geometry:margin=2.5cm \
  -V mainfont="DejaVu Sans" \
  -V lang=es \
  --toc \
  --toc-depth=3

# 7. Limpiar
echo "--- Limpiando ---"
rm -rf "$AGENT_DIR"
rm -rf "$WORK_DIR/.kiro"
rm -f "$WORK_DIR/docs/DOCUMENTACION.md"

echo "=== Documentación generada: $OUTPUT_PATH ==="
