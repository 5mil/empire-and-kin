# Mesh + skins operational path (`0.4.0`)

## Honest scope

**Sims 4** and **Second Life** ship years of CAS, high-res textures, full skeletal animation graphs, and content pipelines.  
This release makes **mesh skins operational** in Empire & Kin’s engine — load GLB, read joints/weights, CPU-skin to bind pose, draw on PC GL and GLES-capable path — **not** product parity with those platforms.

## What works now

| Feature | Status |
|---------|--------|
| GLB container parse | Yes |
| POSITION / NORMAL / indices | Yes |
| JOINTS_0 + WEIGHTS_0 | Yes |
| inverseBindMatrices | Yes |
| CPU skinning (bind pose) | Yes |
| GPU skinning shader | Not yet |
| Animation clip playback | Not yet (next) |
| Second Life avatar system | Out of scope |
| Sims 4 CAS | Out of scope |

## How to use

1. Drop a CC0 character GLB (Quaternius recommended):
   `assets/cc0/characters/character.glb`
2. Optional building:
   `assets/cc0/buildings/building.glb`
3. Run GPU build — registry auto-loads on init (wire `model_registry.tryLoadDefaults` from renderer/backend init).

## Tooling (free)

- Quaternius base characters + UAL animations (CC0)
- Mesh2Motion → export animated GLB
- Blender → glTF 2.0 binary export with skin

## Next engineering

1. Sample animation channels → joint matrices per frame  
2. GPU skinning (uniform bone palette)  
3. Texture (baseColorTexture) upload  
4. LOD / multiple primitives per mesh  
