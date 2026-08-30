# BETA freeze — Zig engine snapshot

**Branch:** `BETA`  
**Commit at branch creation:** `7555b31f565fa4f6511f0b02f0b8feb86555bda4`  
**Version:** `0.6.0-alpha` (Phase 5 raycast vehicle physics)

This branch is a **saved state** of the pure-Zig + GLFW/OpenGL prototype as of 2026-08-30.

## What this is

- Custom Zig 0.14 engine (GL / GLES / Android VTable backends)
- Elevated third-person follow camera
- Procedural box city + optional CC0 GLB registry
- Empire / heat / jobs / traffic systems
- Phase 5 drive: suspension lean, handbrake, wall bounce

## What this is not

- Street-level or first-person presentation
- Production art density
- The ongoing development line (see `main` for Godot 4 direction)

## Build (Windows cross from WSL)

```bash
git checkout BETA
./tools/assemble_session.sh
export GLFW_WIN=/path/to/glfw-3.4.bin.WIN64
zig build -Dtarget=x86_64-windows-gnu -Dgpu=true \
  -Dglfw_prefix=$GLFW_WIN -Doptimize=ReleaseFast
```

Do not treat this branch as the product roadmap. It exists so the Zig prototype remains recoverable.
