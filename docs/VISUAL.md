# Visual target vs reality

## Straight talk

**The Sims 4** is a decade of EA art, animation, CAS, routing, lighting, and UI.
Empire & Kin is a Zig alpha. **True Sims 4 fidelity is not a free-asset drop-in.**

What we *are* building is a **legal free pipeline** (`docs/FIDELITY_PIPELINE.md`) toward life-sim quality:

| Layer | Sims 4 | Empire & Kin |
|-------|--------|----------------|
| Camera | Elevated neighborhood | Elevated 3/4 follow |
| Character | Mesh + CAS | Procedural multi-part + **walk bob** → Quaternius CC0 GLB |
| Animation | Full clips | Procedural limbs → KayKit / Quaternius UAL (CC0) |
| Buildings | Textured lots | Boxes → **Kenney City Kit** (CC0) |
| Textures | PBR sets | Vertex color → **Poly Haven** (CC0) |
| Rig tooling | Proprietary | **Mesh2Motion** + Blender (FOSS) |
| Historical mood | Art direction | LOC / NYPL PD photos (reference) |

## Now (`0.3.2`)

- Free source **manifest** + fetch script  
- Procedural walk animation  
- GLB loader **stub** ready for Phase 1  

## Next measurable steps

1. Download Kenney + Quaternius into `assets/cc0/`  
2. Implement `gltf_loader.loadGlbBytes`  
3. Draw one building + one character from GLB on PC and GLES  
