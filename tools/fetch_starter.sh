#!/usr/bin/env bash
# Copy the smallest extracted CC0 GLBs into assets/cc0 (15 MB cap).
# Run after tools/fetch_cc0_assets.sh --kenney-only (or this script calls it).
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
CC0="$ROOT/assets/cc0"
CAP=$((15 * 1024 * 1024))
MAX_EACH=$((400 * 1024))

if ! find "$CC0" -iname '*.glb' | grep -q .; then
  echo "No GLBs yet — running Kenney-only fetch first"
  "$ROOT/tools/fetch_cc0_assets.sh" --kenney-only --no-samples || true
fi

# Prefer tiny Khronos box
mkdir -p "$CC0/props" "$CC0/buildings" "$CC0/vehicles"
BOX="$CC0/props/khronos_Box.glb"
if [[ ! -f "$BOX" ]]; then
  curl -fL -o "$BOX" \
    "https://raw.githubusercontent.com/KhronosGroup/glTF-Sample-Assets/main/Models/Box/glTF-Binary/Box.glb" \
    || echo "[warn] Box.glb download failed"
fi

used=$(find "$CC0" -iname '*.glb' -printf '%s\n' 2>/dev/null | awk '{s+=$1} END{print s+0}')
echo "Current GLB bytes: $used / $CAP"

# If over cap, keep smallest files only into a staging set — report, don't delete user files.
echo "Starter policy: keep files ≤ ${MAX_EACH} bytes; total ≤ 15MB"
echo "Smallest 12 GLBs:"
find "$CC0" -iname '*.glb' -printf '%s\t%p\n' 2>/dev/null | sort -n | head -12
