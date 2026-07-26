# Empire & Kin

**NYC mob life** — 1930s / 1980s · real-time free-roam + empire.

**Version:** `0.1.6-alpha`  
**Stack:** Zig 0.16 · GLFW + OpenGL 3.3

## Snapshot

Dense Little Italy block with 15+ E-key contacts, jobs, empire menu, ambush/patrol, tiered goals, expanded save.

See [`docs/CONTROLS.md`](docs/CONTROLS.md) and [`docs/HANDOVER.md`](docs/HANDOVER.md).

## Windows build (WSL)

```bash
export GLFW_WIN=$HOME/glfw-3.4.bin.WIN64
zig build -Dtarget=x86_64-windows-gnu -Dgpu=true \
  -Dglfw_prefix=$GLFW_WIN -Doptimize=ReleaseFast
```
