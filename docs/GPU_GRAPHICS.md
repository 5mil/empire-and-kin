# GPU Graphics Infrastructure

Empire & Kin uses a real **OpenGL 3.3 core** path through **GLFW** — not a software rasterizer or fake “GPU”.

## Architecture

```
Game (scene / HUD)
        │
        ▼
engine.Backend  (vtable)
        │
   ┌────┴────┐
   ▼         ▼
GLBackend   NullBackend
(GLFW+GL)   (CI / no display)
        │
        ▼
gfx/
  glfw_window.zig   window + context + input
  gl.zig            GL 3.3 loader (getProcAddress)
  math.zig          Mat4 / Vec3 (lookAt, perspective)
  mesh.zig          CPU vertex/index builders
  gpu_mesh.zig      VAO / VBO / EBO
  shaders.zig       GLSL 330 lit + UI
  renderer.zig      frame, camera, ground/box/player/vehicle
```

## Build

**Requirements (GPU):** GLFW 3, OpenGL 3.3 drivers, system C toolchain.

```bash
# Default: GPU enabled
zig build run

# Explicit
zig build run -Dgpu=true

# Headless (NullBackend, no GLFW)
zig build run -Dgpu=false
```

### Linux packages (example)

```bash
sudo apt install libglfw3-dev libgl1-mesa-dev
```

### macOS

Install GLFW via Homebrew (`brew install glfw`). Frameworks linked automatically.

## What is drawn on GPU

| Primitive | Implementation |
|-----------|----------------|
| Ground | Scaled plane mesh, lit shader |
| Buildings / boxes | Unit cube VAO × model matrix |
| Player | Oriented box |
| Vehicle | Wider oriented box |
| Clear / sky | `glClear` with period colors |
| HUD text | GPU UI quads (glyph atlas = next pass) |

## Lighting

Directional light + ambient in `lit_frag`. Depth test and face cull enabled.

## Not shortcuts

- Real context creation (`glfwCreateWindow` + core 3.3 hints)
- Explicit GL function loading via `glfwGetProcAddress`
- GPU-side buffers (STATIC_DRAW meshes, DYNAMIC_DRAW UI)
- Proper MVP matrices (column-major)
- Build flag separates GPU vs headless; game code unchanged

## Next

1. Bitmap font atlas for crisp HUD text
2. Textured ground / PD historical maps
3. Shadow maps
4. Optional Vulkan path behind same Backend
