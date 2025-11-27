#!/usr/bin/env bash
set -euo pipefail

START_TIME=$(date +%s)

# ==== CONFIG ====
TASK_ID="26112521-3873-4c18-b26c-e3b4e6260767" # Cambia esta TASK_ID por el de tu TASK!!
FORMAT_ID="5057e5cc-b825-11e4-9d0e-28d24461215b"
BASE_DIR="reports" # Cambia BASE_DIR por el directorio en el que quieres que se cree el directorio de REPORTS!!
DATE_TAG=$(date +%F)
REPORT_DIR="$BASE_DIR/$DATE_TAG"
XML_FILE="$REPORT_DIR/report_$DATE_TAG.xml"
JSON_FILE="$REPORT_DIR/report_$DATE_TAG.json"
SPLIT_DIR="$REPORT_DIR/split_$DATE_TAG"
GMP_USERNAME="admin" # Introduce aquí tu usuario de GMP (por defecto: admin).
GMP_PASSWORD="INTRODUCE-AQUI-TU-PASSWD" # Introduce aqui tu contraseña de GMP.

# =========================================================
#  FASE 1: INICIO Y PREPARACIÓN DE DIRECTORIOS
# =========================================================

mkdir -p "$REPORT_DIR"

clear

gum style \
    --border double \
    --margin "1 1" \
    --padding "1 4" \
    --border-foreground 33 \
    --foreground 33 \
    --bold \
    " OpenVAS Report Splitter "

gum join --horizontal \
    "$(gum style --foreground 33 '📅 FECHA DE EJECUCIÓN:  ')" \
    "$(gum style --foreground 255 "$DATE_TAG")"

gum join --horizontal \
    "$(gum style --foreground 33 '📂 CARPETA DE SALIDA:  ')" \
    "$(gum style --foreground 255 "$REPORT_DIR")"

echo ""

# =========================================================
#  FASE 2: INTERACCIÓN CON GVM
# =========================================================

# ==== 1. OBTENER ÚLTIMO REPORT ID ====
TEMP_ID_FILE=$(mktemp)
gum spin --spinner dot --title "Buscando último report de la task..." -- \
    bash -c "gvm-cli --gmp-username $GMP_USERNAME --gmp-password $GMP_PASSWORD socket --xml \"<get_tasks task_id='$TASK_ID' details='1'/>\" | grep -oP '(?<=<report id=\")[^\"]+' | tail -1 > $TEMP_ID_FILE"

LAST_REPORT_ID=$(cat "$TEMP_ID_FILE")
rm "$TEMP_ID_FILE"

if [ -z "$LAST_REPORT_ID" ]; then
    gum style --foreground 196 --bold "✘ [ERROR] No se encontró ningún report para la task $TASK_ID"
    exit 1
fi
gum style --foreground 82 "✔ Obtenido último report ID con éxito: $LAST_REPORT_ID"
echo ""

# ==== 2. DESCARGAR REPORTE EN XML ====
if gum spin --spinner dot --title "Descargando reporte en formato XML..." -- \
    bash -c "gvm-cli --gmp-username $GMP_USERNAME --gmp-password $GMP_PASSWORD socket --xml \"<get_reports report_id='$LAST_REPORT_ID' format_id='$FORMAT_ID' details='1' filter='apply_overrides=0 levels=hmlg rows=100 min_qod=70 first=1 sort-reverse=severity'/>\" > \"$XML_FILE\""; then
    gum style --foreground 82 "✔ Reporte guardado con éxito: $XML_FILE"
else
    gum style --foreground 196 --bold "✘ Falló la descarga o decodificación del reporte."
    exit 1
fi
echo ""

# =========================================================
#  FASE 3: PROCESAMIENTO DE DATOS (PYTHON)
# =========================================================

# ==== 3. PARSEAR A JSON (parser.py) ====
chmod +x tools/parser.py || true

if [ ! -f "tools/parser.py" ]; then
    gum style --foreground 196 --bold "[ERROR] No se encontró parser.py en la ruta esperada."
    exit 1
fi

if gum spin --spinner minidot --title "Parseando XML a JSON limpio ($JSON_FILE)..." -- \
    python3 tools/parser.py "$XML_FILE" "$JSON_FILE"; then
    :
else
    gum style --foreground 196 --bold "Error durante el parseo del archivo."
    exit 1
fi

# ==== 4. DIVIDIR JSON EN VULNERABILIDADES (splitter.py) ====
chmod +x tools/splitter.py || true

if [ ! -x "tools/splitter.py" ]; then
    gum style --foreground 196 --bold "✘ No se encontró splitter.py."
    exit 1
fi

if gum spin --spinner points --title "Dividiendo JSON en vulnerabilidades..." -- \
    bash -c "mkdir -p \"$SPLIT_DIR\" && python3 tools/splitter.py \"$JSON_FILE\" \"$SPLIT_DIR\""; then
    gum style --foreground 82 "✔ JSON dividido en vulnerabilidades con éxito: $SPLIT_DIR"
else
    gum style --foreground 196 --bold "✘ Falló la división del archivo JSON."
    exit 1
fi
echo ""

# =========================================================
#  FASE 4: FINALIZACIÓN
# =========================================================

END_TIME=$(date +%s)
DURATION=$((END_TIME - START_TIME))

gum style \
    --border double \
    --border-foreground 82 \
    --foreground 255 \
    --bold \
    "PROCESO COMPLETADO EN ${DURATION} SEGUNDOS. ¡Vulnerabilidades listas!"

gum style --foreground 82 "Consulta los archivos generados en: $REPORT_DIR"