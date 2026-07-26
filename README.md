# Empire & Kin

**New York City mob life simulator** — 1930s or 1980s.

Real-time free-roam + living crew + empire management.

**Version:** `0.1.1-alpha`  
**Stack:** Zig 0.16 · GLFW + OpenGL 3.3 · `engine.Backend`

## Art
Public-domain historical sources preferred — `docs/ART_SOURCES.md`.

## Status
**Alpha track complete (A1–A10)** + GPU path verified on Windows.  
**B1 bitmap font** · collision · smoothed camera · job respawn · toasts  
**Full handover:** [`docs/HANDOVER.md`](docs/HANDOVER.md)

## Play (Linux / WSL display)

```bash
# Headless (no GPU libs)
zig build run-headless

# GPU on Linux (needs libglfw + OpenGL)
sudo apt install libglfw3-dev libgl1-mesa-dev
zig build run -Dgpu=true
```

## Windows cross-compile from WSL

```bash
# Unpack official GLFW WIN64 prebuilt, then:
export GLFW_WIN=$HOME/glfw-3.4.bin.WIN64
zig build -Dtarget=x86_64-windows-gnu -Dgpu=true \
  -Dglfw_prefix=$GLFW_WIN -Doptimize=ReleaseFast
# Copy zig-out/bin/empire.exe AND glfw3.dll next to each other on Windows
```

Boot → **[1] New Game** → pick era **[Enter]** → free-roam.

| Key | Action |
|-----|--------|
| WASD | Move / drive |
| E | Job or vehicle |
| Esc | Empire menu |
| F | Attack (in fight) |
| F5 / F9 | Quick-save / load |
| H / X | Next tip / dismiss tips |
| Tab | Empire panels |
| 1–5 | Crew orders (paused) |

## Docs
- **`docs/HANDOVER.md`** — architecture, instructions, full future plan
- `docs/ALPHA_ROADMAP.md` · `docs/ALPHA_CHECKLIST.md`
- `docs/GFX_ARCHITECTURE.md` · `docs/ART_SOURCES.md`
