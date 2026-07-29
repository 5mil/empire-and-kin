#!/usr/bin/env bash
# Prepare trees + print bulk import map for premium free (CC0) meshes.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
CC0="$ROOT/assets/cc0"

mkdir -p \
  "$CC0/characters" \
  "$CC0/buildings" \
  "$CC0/vehicles" \
  "$CC0/props" \
  "$CC0/environment" \
  "$CC0/textures" \
  "$CC0/reference"

touch \
  "$CC0/characters/.gitkeep" \
  "$CC0/buildings/.gitkeep" \
  "$CC0/vehicles/.gitkeep" \
  "$CC0/props/.gitkeep" \
  "$CC0/environment/.gitkeep" \
  "$CC0/textures/.gitkeep"

cat <<'EOF'
═══════════════════════════════════════════════════════════
  Empire & Kin — bulk CC0 mesh import (premium free)
═══════════════════════════════════════════════════════════

Runtime ResourceManager scans assets/cc0/** for .glb (max 256).

PRIORITY DOWNLOADS (browser):

1) Kenney All-in-1 (largest single CC0 dump)
   https://kenney.itch.io/kenney-game-assets
   → extract 3D/glTF into:
      assets/cc0/buildings  assets/cc0/vehicles
      assets/cc0/props      assets/cc0/characters

2) Kenney City kits (Commercial, Roads, Industrial, Suburban)
   https://kenney.nl/assets

3) Kenney Car Kit
   https://kenney-assets.itch.io/car-kit
   → assets/cc0/vehicles

4) Quaternius Universal Base Characters + UAL
   https://quaternius.com/
   → assets/cc0/characters

5) Kenney Character Assets (rigged + skins)
   https://kenney.itch.io/kenney-character-assets

6) Poly Haven (high-end CC0 models/textures)
   https://polyhaven.com/all
   API: https://api.polyhaven.com/assets
   → assets/cc0/props  assets/cc0/textures

7) Open Source 3D Assets / Polygonal Mind CC0 GLB
   https://opensource3dassets.com/
   https://github.com/ToxSam/cc0-models-Polygonal-Mind

After extract, run the game once — logs show:
  [res] +path cat=… v=… skin=…
  [models] cache=N chars=… bld=… veh=…

Log provenance in assets/CREDITS.md
See assets/catalog.json and docs/RESOURCE_SYSTEM.md
═══════════════════════════════════════════════════════════
EOF
