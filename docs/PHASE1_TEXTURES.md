# Phase 1 — Real GL textures from texture_bank

## What shipped

| Piece | Role |
|-------|------|
| `texture_gpu.zig` | Generate each `MaterialId` 64² tile → `glTexImage2D` + mipmaps |
| `gl.zig` | Texture load/bind/upload symbols |
| `shaders.zig` / `shaders_es.zig` | `sampler2D uAlbedo`, triplanar world UV, `uUseTexture`, `uUvScale` |
| `renderer.zig` | Upload bank on init; ground = asphalt; boxes guess material from tint |

## Playtest

```bash
git pull
zig build -Dgpu=true -Doptimize=ReleaseFast
zig build run -Dgpu=true
```

You should see:

1. Console: `[texture_gpu] uploaded 15 material tiles (64x64)`
2. Ground with **asphalt grain/cracks** that tile as you walk
3. Buildings with **brick/sidewalk/concrete** detail (not flat color)

## Exit criteria (roadmap)

- [x] Ground samples tiled albedo
- [x] Building faces sample material albedo (heuristic from color)
- [x] GLES shader path has same uniforms (Android parity ready)
- [x] Headless / NullBackend unchanged (no GL)

## Next (Phase 2)

Kenney GLB buildings on cityscape footprints.
