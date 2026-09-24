#!/usr/bin/env bash
# Copy the live import skill from testimonials.ltd into the plugin.
# Fails (and leaves the file alone) if the download is empty or is not a skill.
set -euo pipefail
URL="https://testimonials.ltd/skills/testimonials-import-reviews/SKILL.md"
DEST="$(cd "$(dirname "$0")/.." && pwd)/plugins/testimonials/skills/testimonials-import-reviews/SKILL.md"
TMP="$(mktemp)"
trap 'rm -f "$TMP"' EXIT
curl -fsSL --retry 3 -H "Accept-Language: en" -H "Cache-Control: no-cache" "$URL?sync=$(date +%s)" -o "$TMP"
head -3 "$TMP" | grep -q "^name: testimonials-import-reviews$" || { echo "Download is not the skill file"; exit 1; }
cp "$TMP" "$DEST"
echo "Synced $URL"
