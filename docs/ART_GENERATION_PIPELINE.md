# Art Generation Pipeline (TRELLIS.2 + open tools)

**Policy:** CC0 / public-domain / open-weight models only. No Rockstar, EA, or scraped copyrighted photos.

**Primary image-to-3D backend:** **TRELLIS.2** (Microsoft, MIT license)  
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
│  Empire & Kin (Zig)                                          │
│  ResourceManager.scan → loadPath → GpuMesh                   │
│  cityscape / vehicles / props place meshes                   │
│  texture_bank + shaders for streets (Phase 1)                │
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
- Code: https://github.com/microsoft/TRELLIS.2 (or current Microsoft TRELLIS.2 repo)
- Older TRELLIS family: https://github.com/microsoft/TRELLIS (image-large models still useful)

### Minimal local setup (Python)

```bash
# On a machine with NVIDIA GPU (A100/H100 recommended in paper; consumer cards work at lower res)
git clone https://github.com/microsoft/TRELLIS.2.git   # or current official repo
cd TRELLIS.2
pip install -r requirements.txt   # follow their README for exact torch/CUDA pins
# Download weights as instructed in the repo (Hugging Face)
```

### Run from this project

```bash
# From Empire & Kin root, after TRELLIS is installed and on PYTHONPATH or use absolute path
python tools/run_trellis_image_to_3d.py \
  --image path/to/concept.png \
  --out assets/generated/props/crate_01 \
  --name crate_01 \
  --res 512
```

Output layout:

```
assets/generated/props/crate_01/
  crate_01.glb          # textured mesh (primary)
  meta.json             # prompt, seed, source image hash, tool version
  preview.png           # optional multi-view still
```

### Input guidelines (for best topology)
- Clean subject, centered
- Plain background (white/black) or easy-to-remove BG
- Prefer orthographic or mild perspective for hard props
- One clear object per image for first pass

### Post-process (recommended before shipping)
1. Open GLB in Blender
2. Check scale (engine units ≈ meters)
3. Decimate / remesh if poly count is too high for mobile
4. Optional LOD meshes (`_lod1.glb`, `_lod2.glb`)
5. Log provenance in `assets/CREDITS.md`

---

## Supporting tools (same pipeline)

| Role | Tool | Notes |
|------|------|--------|
| Concept images | FLUX / SD 3.5 + ControlNet (ComfyUI) | Style lock for 1930s NYC |
| PBR materials | Material Maker (MIT) | Node graph → albedo/normal/roughness |
| PBR from single map | Ubisoft CHORD (open weights + ComfyUI nodes) | |
| Texture variations | texturize | Expand real PD photos |
| Noise / runtime | texture_bank + FastNoise-style patterns | Already in engine |
| CC0 kits | Kenney, Quaternius, Poly Haven | Still primary for volume |

---

## Engine integration

### Scan roots
`assets/catalog.json` and `ResourceManager` already walk:

- `assets/cc0/...`
- **`assets/generated/...`** (added for this pipeline)

Category is inferred from path substrings (`vehicle`, `building`, `prop`, `character`, …).

### Placement
1. Generate asset with TRELLIS → `assets/generated/<category>/<name>/`
2. Rebuild / run engine; `ingestTree` picks up new `.glb`
3. Bind via `ResourceManager.firstOf(.vehicle)` or explicit `loadPath`
4. Cityscape / garage / props tables can store mesh path keys later

### Phase alignment (REAL_GAME_ROADMAP)

| Roadmap phase | How this pipeline helps |
|---------------|-------------------------|
| Phase 1 textures | Material Maker / Poly Haven / CHORD → texture_bank + GL upload |
| Phase 2 mesh city | TRELLIS custom facades + Kenney kits on footprints |
| Phase 3 people | Prefer Quaternius first; TRELLIS only for unique props/heads after cleanup |
| Phase 4 cars | TRELLIS custom period cars + Kenney Car Kit |
| Phase 5–8 | Physics/telemetry consume same meshes |

---

## Directory convention

```
assets/
  cc0/                 # fetched Kenney / Quaternius / Poly Haven
  generated/           # TRELLIS + bake output (git-ignore large binaries if needed)
    vehicles/
    buildings/
    props/
    characters/
    environment/
  catalog.json
  CREDITS.md
```

Large generated binaries: keep `meta.json` in git; optional LFS or download script for GLBs.

---

## Legal / honest notes

- TRELLIS.2 weights/code are MIT — verify current Microsoft terms before commercial ship.
- **Input images** must be yours, CC0, or public domain. Do not feed copyrighted game screenshots or modern street photos you do not own.
- Output meshes still need human review (topology, collision, LODs) before calling them production-ready.
- This does **not** claim GTA 4 photoreal parity; it supplies a legal path to denser, textured, mesh-based city content.

---

## Immediate next actions

1. On a GPU machine: install TRELLIS.2 per upstream README.
2. Generate one prop (e.g. trash can, crate, fire hydrant) → `assets/generated/props/`.
3. Confirm engine `ResourceManager` logs `[res] +...` on ingest.
4. Place the mesh in `cityscape` or a debug spawn.
5. Expand to one vehicle body and one building facade piece.

See also: `docs/REAL_GAME_ROADMAP.md`, `docs/FIDELITY_PIPELINE.md`, `tools/run_trellis_image_to_3d.py`.
