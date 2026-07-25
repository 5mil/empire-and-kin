# Graphics Architecture — Empire & Kin

## Goal

Real GPU path: window, GL context, shaders, meshes, camera, lighting, UI pass.
No software raster shortcut for the gameplay view.

## Stack

| Layer | Role |
|-------|------|
| **SDL2** | Window, input, GL context, vsync swap |
| **OpenGL 3.3 core** | Device API (function pointers after context) |
| **engine/gfx/** | Math, mesh, GPU buffers, shaders, renderer |
| **gl_backend.zig** | Implements `engine.Backend` |
| **null_backend.zig** | Headless / CI (`-Dgpu=false`) |

## Module map

```
src/engine/
  backend.zig
  gl_backend.zig
  null_backend.zig
  gfx/
    sdl_window.zig
    gl.zig
    math.zig
    mesh.zig
    gpu_mesh.zig
    shaders.zig
    renderer.zig
```

## Frame

1. beginFrame — poll SDL, resize, clear depth+color
2. Game draws: setCamera, drawGround, drawBox, player, vehicle
3. HUD text queued → UI rect proxies
4. endFrame — swap buffers

## Build

```bash
zig build run              # GPU (default)
zig build run-headless     # NullBackend
```

**Deps (Linux):** libSDL2, libGL.

## Roadmap

- [x] Window + GL 3.3 context
- [x] Shader compile/link
- [x] Depth + directional light + tint
- [x] Unit box / ground meshes
- [x] Camera look-at + perspective
- [ ] Bitmap font atlas
- [ ] PD historical textures
- [ ] Optional Vulkan backend
