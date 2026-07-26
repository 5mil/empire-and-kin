# Empire & Kin

**NYC mob life** — 1930s / 1980s · real-time free-roam + empire.

**Version:** `0.1.8-alpha`  
**Stack:** Zig 0.16 · GLFW + OpenGL 3.3

Dense Little Italy block: 20+ contacts, 5 jobs, empire menu, ambush/patrol, goals, expanded save.

- [`docs/MAP.md`](docs/MAP.md) — contact coordinates  
- [`docs/CONTROLS.md`](docs/CONTROLS.md) — bindings  
- [`docs/HANDOVER.md`](docs/HANDOVER.md) — status

## Windows build (WSL)

```bash
export GLFW_WIN=$HOME/glfw-3.4.bin.WIN64
zig build -Dtarget=x86_64-windows-gnu -Dgpu=true \
  -Dglfw_prefix=$GLFW_WIN -Doptimize=ReleaseFast
```
