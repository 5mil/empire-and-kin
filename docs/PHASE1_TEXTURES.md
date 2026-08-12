# Phase 1 — Real GL textures from texture_bank

**Status: wired and live** (commit after texture_gpu existed but was not bound).

## What ships

| Piece | Role |
|-------|------|
| `texture_bank.zig` | 15 MaterialIds + 64² procedural RGBA tiles (brick courses, asphalt cracks, slab joints, cobble, …) |
| `texture_gpu.zig` | Upload each tile → `glTexImage2D` + mipmaps, REPEAT, LINEAR_MIPMAP_LINEAR |
| `shaders.zig` / `shaders_es.zig` | `sampler2D uAlbedo`, triplanar world UV, `uUseTexture`, `uUvScale` |
| `renderer.zig` | Owns `GpuBank`; ground = asphalt; boxes map tint → MaterialId |

## Draw path

```
drawGround  → always .asphalt sample
drawBox     → materialFromColor(tint) → bind tile or flat
drawBuilding (GLB) → same heuristic + brick default
```

Triplanar projection uses world position so vertical walls and horizontal roads both show detail without mesh UVs.

## Playtest

```bash
git pull
zig build -Dgpu=true -Doptimize=ReleaseFast
zig build run -Dgpu=true
```

Console should print:

```
[texture_gpu] uploaded 15 material tiles (64x64)
```

Visual checks:

1. Ground shows **asphalt grain / cracks** that tile under the player  
2. Building boxes show **brick courses + mortar** (or concrete/metal for cool gray towers)  
3. Sidewalks show **slab grid**  
4. GLES path has identical uniforms (Android ready)

## Exit criteria

- [x] Ground samples tiled albedo  
- [x] Building faces sample material albedo (heuristic from color)  
- [x] GLES shader path has same uniforms  
- [x] Headless / NullBackend unchanged (no GL)  
- [x] `uUseTexture` actually set to 1 on textured draws (was previously hardcoded 0)

## Next (Phase 2)

Kenney / TRELLIS GLB buildings on cityscape footprints — textures still apply as fallback or modulation.
