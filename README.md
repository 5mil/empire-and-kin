# Empire & Kin

**NYC mob life** — 1930s / 1980s · real-time free-roam + empire.

**Version:** `0.3.1-alpha`  
**Stack:** Zig · GLFW + OpenGL 3.3 (PC) · GLES 3.0 path (Android)

Life-sim **readability** pass: elevated camera, multi-part boss + plumbob, needs-style HUD, lot grid, fog/shadows.  
**Not** The Sims 4 visual parity — see [`docs/VISUAL.md`](docs/VISUAL.md).

- [`docs/HANDOVER.md`](docs/HANDOVER.md) — status  
- [`docs/CONTROLS.md`](docs/CONTROLS.md) — bindings  
- [`docs/MAP.md`](docs/MAP.md) — contacts  
- [`docs/ART_SOURCES.md`](docs/ART_SOURCES.md) — PD art policy (no asset pack yet)

## Windows build (WSL)

```bash
export GLFW_WIN=$HOME/glfw-3.4.bin.WIN64
zig build -Dtarget=x86_64-windows-gnu -Dgpu=true \
  -Dglfw_prefix=$GLFW_WIN -Doptimize=ReleaseFast
```

## Android (logic / GLES lib)

```bash
zig build run-android
zig build android-lib -Doptimize=ReleaseFast
```
