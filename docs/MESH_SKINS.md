# Mesh + skins operational path

## Honest scope

**Sims 4** and **Second Life** ship years of CAS, high-res textures, full skeletal animation graphs, and content pipelines.  
This project makes **mesh characters operational** — load GLB, bind-pose skin, draw with facing + scale + walk bob on PC GL and GLES — **not** product parity with those platforms.

## What works now (Phase 3)

| Feature | Status |
|---------|--------|
| GLB container parse | Yes |
| POSITION / NORMAL / indices | Yes |
| JOINTS_0 + WEIGHTS_0 | Yes |
| inverseBindMatrices | Yes |
| CPU skinning (bind pose) | Yes |
| Character mesh draw + yaw + scale | Yes |
| Walk bob / idle | Yes (procedural) |
| CharacterMap tint / height / bulk | Yes |
| 8 street peds mesh or procedural | Yes |
| GPU skinning shader | Not yet |
| Animation clip playback | Not yet |
| Second Life / Sims 4 CAS | Out of scope |

## How to use

1. Drop CC0 character GLBs (Quaternius recommended):
   `assets/cc0/characters/*.glb`
2. Optional: `./tools/fetch_cc0_assets.sh --samples-only` for Khronos rigged samples
3. Run GPU build — registry auto-loads characters on init

## Tooling (free)

- Quaternius base characters + UAL animations (CC0)
- Mesh2Motion → export animated GLB
- Blender → glTF 2.0 binary export with skin

## Next engineering

1. Sample animation channels → joint matrices per frame  
2. GPU skinning (uniform bone palette)  
3. Texture (baseColorTexture) upload  
4. LOD / multiple primitives per mesh  

See **docs/PHASE3_PEOPLE.md**.
