# Resource system (`0.4.1`)

## Why this exists

Ad-hoc `loadBossGlb` does not scale to hundreds of CC0 meshes.  
`ResourceManager` is the ground-up layer: **hash IDs, GPU cache, category tags, recursive ingest**.

This is the ops advantage vs content-locked platforms: we can legally pull from many free premium libraries and manage them uniformly.

## Architecture

```
assets/cc0/**/*.glb
        │
        ▼
 ResourceManager.ingestTree()   ← recursive walk, cap 256
        │
        ▼
  slot[id] → GpuMesh + category + skinned flag
        │
        ▼
 Registry picks first character / building / vehicle
        │
        ▼
 Renderer.drawBossMesh / drawMesh
```

## Categories

| Tag | Path hints |
|-----|------------|
| character | `characters/` |
| building | `buildings/`, City |
| vehicle | `vehicles/`, car |
| prop | `props/`, nature |
| environment | `environment/`, road |

## Catalog

`assets/catalog.json` lists approved **CC0 / PD** sources only:

- Kenney All-in-1 + city/car/nature/character kits  
- Quaternius + KayKit  
- Poly Haven (photogrammetry-grade)  
- Open Source 3D Assets / Polygonal Mind  

## Limits (honest)

- Binaries are **not** committed to git (size). Download locally.  
- Cache max **256** GPU meshes per run (raise when streaming lands).  
- No animation clip graph yet — bind-pose skin only.  
- Does not equal Sims 4 / Second Life content volume; it is a better **import + cache** substrate for free meshes.

## Next

1. Streaming / unload least-recently-used  
2. Texture atlas pack from Poly Haven  
3. Animation clips from Quaternius UAL  
4. Scene placement table (which building GLB at which world coord)  
