#!/usr/bin/env bash
# Fetch instructions for CC0 packs used by Empire & Kin.
# Many hosts require a browser download (itch/Kenney). This script prepares dirs
# and prints exact URLs. Optional: curl Poly Haven sample texture if network allows.

set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
CC0="$ROOT/assets/cc0"

mkdir -p \
  "$CC0/characters" \
  "$CC0/buildings" \
  "$CC0/props" \
  "$CC0/textures" \
  "$CC0/animations" \
  "$CC0/reference"

cat <<'EOF'
=== Empire & Kin — CC0 asset fetch ===

Directories ready under assets/cc0/

Download these packs (browser; CC0):

1) Kenney City Kit packs (buildings + roads)
   https://kenney.nl/assets
   → extract glTF/GLB into assets/cc0/buildings and assets/cc0/props

2) Quaternius Universal Base Characters
   https://quaternius.com/packs/universalbasecharacters.html
   → assets/cc0/characters

3) Quaternius Universal Animation Library (and/or KayKit)
   https://quaternius.com/
   https://kaylousberg.itch.io/kaykit-character-animations
   → assets/cc0/animations

4) Poly Haven textures (brick, asphalt, concrete)
   https://polyhaven.com/textures
   → assets/cc0/textures

5) Optional auto-rig
   https://mesh2motion.org/

After download, append rows to assets/CREDITS.md
See docs/FIDELITY_PIPELINE.md for integration phases.

EOF

# Optional tiny placeholder so the tree is non-empty in git-friendly way
if [[ ! -f "$CC0/textures/.gitkeep" ]]; then
  touch "$CC0/characters/.gitkeep" \
        "$CC0/buildings/.gitkeep" \
        "$CC0/props/.gitkeep" \
        "$CC0/textures/.gitkeep" \
        "$CC0/animations/.gitkeep" \
        "$CC0/reference/.gitkeep"
fi

echo "Done. Place GLB/PNG files under assets/cc0/ then wire the loader."
