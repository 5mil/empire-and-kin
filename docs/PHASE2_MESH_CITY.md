# Phase 2 — Mesh city on footprints

## What shipped

| Piece | Role |
|-------|------|
| `Backend.drawBuilding` | Returns `true` when a GLB was drawn |
| `model_registry` | Scans `assets/cc0` + `assets/generated`, pools up to 16 building variants |
| `renderer.drawBuilding` | Scales mesh to footprint `w×h×d` at center |
| `scene.building` | Prefers mesh; falls back to procedural windows/roof/door |

## Assets

```bash
./tools/fetch_cc0_assets.sh --kenney-only
# or drop GLBs under:
#   assets/cc0/buildings/*.glb
#   assets/generated/buildings/**/*.glb
```

Path must contain `building` or `City` so `Category.fromPath` tags them as buildings.

## Playtest

```bash
git pull
zig build -Dgpu=true -Doptimize=ReleaseFast
zig build run -Dgpu=true
```

Console should show something like:

```
[models] cache=N chars=… bld=… variants=K …
```

If `variants≥1`, footprints use meshes (tinted by cityscape color). If `variants=0`, procedural boxes remain — world never goes blank.

## Exit criteria

- [ ] ≥1 building GLB loads (or honest fallback)
- [ ] Footprints still collide / match layout
- [ ] NullBackend boots (drawBuilding → false)
- [ ] GLES path has drawBuilding wired

## Next

Phase 3 — skinned people, or more Kenney variants + TRELLIS custom facades.
