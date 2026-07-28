# Assets

Large binary packs are **not** committed by default (keep the git clone small).

```
assets/
  README.md          ← this file
  CREDITS.md         ← required when any third-party file is added
  manifest.json      ← catalog of approved free sources
  cc0/               ← download target (create locally)
    characters/
    buildings/
    props/
    textures/
    animations/
```

## Quick start

```bash
# from repo root
chmod +x tools/fetch_cc0_assets.sh
./tools/fetch_cc0_assets.sh
```

Or download manually from links in `manifest.json` / `docs/FIDELITY_PIPELINE.md`.

## Engine expectation

- Format: **glTF 2.0 / GLB** + PNG textures  
- Shared by **PC OpenGL 3.3** and **Android GLES 3.0**  
- Until the GLB loader lands, gameplay uses procedural meshes  
