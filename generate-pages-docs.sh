#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DATA_DIR="$ROOT_DIR/data"
XSLT_PATH="$ROOT_DIR/templates/default/journal-template.xslt"
PY_SCRIPT="$ROOT_DIR/generate_html.py"
DOCS_DIR="$ROOT_DIR/docs"

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

shopt -s nullglob
xml_files=("$DATA_DIR"/journal-data-*.xml)
shopt -u nullglob

if (( ${#xml_files[@]} == 0 )); then
  echo "Error: no XML files found in $DATA_DIR" >&2
  exit 1
fi

mkdir -p "$DOCS_DIR"
find "$DOCS_DIR" -maxdepth 1 -type f -name '*.html' -delete

latest_date="00000000"
latest_suffix=""
latest_target=""

for xml_file in "${xml_files[@]}"; do
  base_name="$(basename "$xml_file")"
  suffix="${base_name#journal-data-}"
  suffix="${suffix%.xml}"

  out_html="$DOCS_DIR/the-ai-report-${suffix}.html"

  python3 "$PY_SCRIPT" \
    --xml "$xml_file" \
    --xslt "$XSLT_PATH" \
    --out "$out_html"

  file_date="00000000"
  if [[ "$suffix" =~ ^([0-9]{8}) ]]; then
    file_date="${BASH_REMATCH[1]}"
  fi

  if [[ "$file_date" > "$latest_date" ]] || { [[ "$file_date" == "$latest_date" ]] && [[ "$suffix" > "$latest_suffix" ]]; }; then
    latest_date="$file_date"
    latest_suffix="$suffix"
    latest_target="$(basename "$out_html")"
  fi

done

if [[ -z "$latest_target" ]]; then
  echo "Error: could not determine latest generated page." >&2
  exit 1
fi

cat > "$DOCS_DIR/index.html" <<EOF
<!DOCTYPE html>
<html lang="fr">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>AI Report - Redirection</title>
  <meta http-equiv="refresh" content="0; url=./$latest_target">
  <link rel="canonical" href="./$latest_target">
  <script>
    window.location.replace('./$latest_target');
  </script>
</head>
<body>
  <p>Redirection vers la derniere edition: <a href="./$latest_target">$latest_target</a></p>
</body>
</html>
EOF

echo "Generated Pages in: $DOCS_DIR"
echo "Latest page: $latest_target"
