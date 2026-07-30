# Public-domain & CC0 art sources

Production assets must be **CC0 / public domain / original**. Check every item.

## 3D (preferred production path)

| Source | License | Best for |
|--------|---------|----------|
| [Kenney.nl](https://kenney.nl/assets) | CC0 | City kits, modular buildings, roads, props |
| [Quaternius](https://quaternius.com/) | CC0 | Base characters + animation libraries |
| [KayKit animations](https://kaylousberg.itch.io/kaykit-character-animations) | CC0 | Humanoid clips |
| [Poly Haven](https://polyhaven.com/) | CC0 | PBR textures, HDRIs, some models |
| [Open Source 3D Assets](https://opensource3dassets.com/) | CC0 focus | GLB registry |
| [Khronos Sample Assets](https://github.com/KhronosGroup/glTF-Sample-Assets) | varies | Loader tests |
| [ToxSam / Polygonal Mind CC0 GLB](https://github.com/ToxSam/cc0-models-Polygonal-Mind) | CC0 | Environment props |

## AI image → 3D (custom assets)

| Tool | License | Role |
|------|---------|------|
| **TRELLIS.2** (Microsoft) | MIT | Primary image-to-textured-GLB pipeline |
| Material Maker | MIT | Procedural PBR materials |
| Ubisoft CHORD | Open weights | Texture → full PBR set |
| FLUX / SD (self-host) | Model-dependent | Concept images only (legal inputs) |

Pipeline docs: **`docs/ART_GENERATION_PIPELINE.md`**  
Helper: `tools/run_trellis_image_to_3d.py`  
Output root: `assets/generated/`

## Animation / rig tooling

| Tool | License | Role |
|------|---------|------|
| [Mesh2Motion](https://mesh2motion.org/) | FOSS / CC0 assets | Auto-rig + export animated GLB |
| Blender | GPL | Edit / retarget / export |
| Quaternius UAL | CC0 | Drop-in walk/idle/run |

## Historical photography (reference / selective texture)

| Source | Notes |
|--------|--------|
| [Library of Congress](https://www.loc.gov/) | FSA/OWI often **no known restrictions** — verify per item |
| [NYPL Digital Collections](https://digitalcollections.nypl.org/) | Filter rights; many PD |
| [Wikimedia Commons](https://commons.wikimedia.org/) | PD / CC0 filter |
| [Internet Archive](https://archive.org/) | Check rights |

### 1930s NYC
- LOC / NYPL street scenes, waterfront, elevated trains  
- Prefer FSA/OWI and confirmed PD photographers  

### 1980s NYC
- Most photos still under copyright  
- Prefer **original** photos, CC0 packs, or pure procedural  

## Implementation rule

1. Prototype with primitives (`sim_actor`, `scene`)  
2. Fetch CC0 packs via `tools/fetch_cc0_assets.sh`  
3. Generate custom pieces with TRELLIS → `assets/generated/`  
4. Import GLB / textures through the engine loader  
5. Log every shipped file in `assets/CREDITS.md`  

See **`docs/FIDELITY_PIPELINE.md`** and **`docs/ART_GENERATION_PIPELINE.md`**.
