#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DATA_DIR="$ROOT_DIR/data"
XSLT_PATH="$ROOT_DIR/templates/default/journal-template.xslt"
PY_SCRIPT="$ROOT_DIR/generate_html.py"

# Optional override: pass a date as YYYYMMDD.
TARGET_DATE="${1:-$(date +%Y%m%d)}"

if [[ ! -d "$DATA_DIR" ]]; then
  echo "Error: data directory not found: $DATA_DIR" >&2
  exit 1
fi

if [[ ! -f "$XSLT_PATH" ]]; then
  echo "Error: XSLT template not found: $XSLT_PATH" >&2
  exit 1
fi

if [[ ! -f "$PY_SCRIPT" ]]; then
  echo "Error: generator script not found: $PY_SCRIPT" >&2
  exit 1
fi

INPUT_XML="$DATA_DIR/journal-data-${TARGET_DATE}.xml"

if [[ ! -f "$INPUT_XML" ]]; then
  shopt -s nullglob
  matches=("$DATA_DIR"/journal-data-"$TARGET_DATE"*.xml)
  shopt -u nullglob

  if (( ${#matches[@]} == 0 )); then
    echo "Error: no XML file found for date $TARGET_DATE in $DATA_DIR" >&2
    echo "Expected pattern: journal-data-${TARGET_DATE}*.xml" >&2
    exit 1
  fi

  if (( ${#matches[@]} > 1 )); then
    IFS=$'\n' sorted=( $(printf '%s\n' "${matches[@]}" | sort) )
    INPUT_XML="${sorted[$((${#sorted[@]} - 1))]}"
    echo "Info: multiple XML files found for $TARGET_DATE. Using latest by name: $(basename "$INPUT_XML")"
  else
    INPUT_XML="${matches[0]}"
  fi
fi

INPUT_BASENAME="$(basename "$INPUT_XML" .xml)"
SUFFIX="${INPUT_BASENAME#journal-data-}"
OUT_HTML="$ROOT_DIR/the-ai-report-${SUFFIX}.generated.by-script.html"

python3 "$PY_SCRIPT" \
  --xml "$INPUT_XML" \
  --xslt "$XSLT_PATH" \
  --out "$OUT_HTML"

echo "Generated: $OUT_HTML"
