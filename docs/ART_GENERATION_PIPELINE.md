# Art Generation Pipeline (TRELLIS.2 + open tools)

**Policy:** CC0 / public-domain / open-weight models only. No Rockstar, EA, or scraped copyrighted photos.

**Primary image-to-3D backend:** **TRELLIS.2** (Microsoft, MIT license)  
**Availability policy:** **Asset Continuum** — see `docs/ASSET_CONTINUUM.md` (never blank; premium upgrades offline).

**Goal:** Turn concept images (or reference photos you own / PD) into textured GLB assets that feed `ResourceManager` and the cityscape.

---

## Architecture

```
┌──────────────────────────────────────────────────────────────┐
│  Offline Art Studio (Python / GPU machine)                   │
│                                                              │
│  1. Concept image (FLUX / photo / sketch)                    │
│  2. TRELLIS.2  →  UV-textured GLB + PBR maps                 │
│  3. Optional: Material Maker / CHORD for material polish     │
│  4. Bake / decimate / LODs (Blender headless or mesh tools)  │
└────────────────────────────┬─────────────────────────────────┘
                             │  assets/generated/**/*.glb
┌────────────────────────────▼─────────────────────────────────┐
│  Empire & Kin (Zig) — Asset Continuum                        │
│  T0 procedural → T1 cache → T2 disk → queue T4 jobs          │
│  ResourceManager + texture_bank + cityscape                  │
└──────────────────────────────────────────────────────────────┘
```

Heavy AI stays **offline**. The game never embeds TRELLIS; it only consumes GLB + PNG.

---

## TRELLIS.2 (image → 3D)

### Why TRELLIS.2
- MIT license, open code + weights
- Native PBR-textured mesh output
- Strong single-image → asset quality for props, vehicles, building pieces
- C++/GGML port exists (`trellis.cpp`) if you later want a non-Python runner

### Official sources
- Paper / project: https://microsoft.github.io/TRELLIS.2/
- Code: follow current Microsoft TRELLIS.2 repository
- Older TRELLIS family: https://github.com/microsoft/TRELLIS

### Run from this project

```bash
python tools/run_trellis_image_to_3d.py \
  --image path/to/concept.png \
  --out assets/generated/props/crate_01 \
  --name crate_01 \
  --res 512
```

Or process continuum jobs:

```bash
./tools/asset_ensure.sh --process-queue
```

---

## Continuum integration

Recipes live in `assets/recipes/`. Missing meshes enqueue under `assets/queue/`.
Resolver: `src/engine/gfx/asset_resolve.zig`.

Prefer paths are tried first; procedural fallback always draws; TRELLIS fills `assets/generated` for the next boot.

---

## Directory convention

```
assets/
  cc0/
  generated/
  recipes/             # semantic cards
  queue/               # T4 pending jobs
  catalog.json
  CREDITS.md
```

---

## Legal / honest notes

- TRELLIS.2 weights/code are MIT — verify current terms before commercial ship.
- Input images must be owned, CC0, or public domain.
- Output meshes need review before calling production-final.

See **`docs/ASSET_CONTINUUM.md`** for the full availability design.
