# Phase 2 — Mesh city on footprints

**Status:** code path complete. Visual density depends on GLBs present under `assets/cc0` / `assets/generated`.

## What shipped

| Piece | Role |
|-------|------|
| `Backend.drawBuilding` / `drawProp` | Return `true` when a GLB was drawn |
| `model_registry` | Up to 32 building variants + 24 prop variants; scans cc0 + generated |
| `Category.fromPath` | Kenney City kit, commercial/suburban/industrial, trees/lamps/hydrants |
| `renderer.drawBuilding` / `drawProp` | Scale unit mesh to footprint; Phase 1 albedo still applies |
| `scene` | Buildings, lamps, trees, hydrants, dumpsters prefer mesh → box fallback |

## Assets (required for mesh look)

```bash
./tools/fetch_cc0_assets.sh --kenney-only
# Optional denser props:
./tools/fetch_cc0_assets.sh --polyhaven-only --poly-limit 8
```

Or drop GLBs under:

```
assets/cc0/buildings/*.glb
assets/cc0/props/*.glb
assets/generated/buildings/**/*.glb
assets/generated/props/**/*.glb
```

Path/folder must classify as building or prop (see `Category.fromPath`).

TRELLIS custom pieces:

```bash
python tools/run_trellis_image_to_3d.py \
  --image concept.png \
  --out assets/generated/buildings/tenement_01 \
  --name tenement_01
```

## Playtest

```bash
git pull
./tools/fetch_cc0_assets.sh --kenney-only   # once
zig build -Dgpu=true -Doptimize=ReleaseFast
zig build run -Dgpu=true
```

Console should show something like:

```
[res] +assets/cc0/buildings/... cat=building ...
[models] cache=N chars=… bld=… variants=K … props=P
```

- `variants ≥ 1` → footprints use meshes (tinted + Phase 1 material sample)  
- `variants = 0` → procedural boxes + Phase 1 textures (world never blank)

## Exit criteria

- [x] drawBuilding / drawProp on GL + GLES + Null  
- [x] Registry pools multiple building + prop variants  
- [x] Scene prefers mesh, falls back to textured boxes  
- [x] Category tags Kenney city kits and street props  
- [ ] ≥12 buildings as GLB in one district — **requires fetch**  
- [ ] Frame ≥30 fps mid laptop at default zoom — verify after fetch  

## Next

**Phase 3 — Real people** (skinned Quaternius / KayKit + walk/idle).
