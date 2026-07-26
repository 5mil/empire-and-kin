# Empire & Kin

**New York City mob life** — 1930s or 1980s · real-time free-roam + empire.

**Version:** `0.1.2-alpha`  
**Stack:** Zig 0.16 · GLFW + OpenGL 3.3 · `engine.Backend`

## What’s in this build

- Readable bitmap HUD, framed panels, status feed
- Little Italy block: sidewalks, crosswalks, tenements, alley, safehouse
- Ambient **pedestrians** and **traffic**
- Jobs with **payout choice** (keep vs tithe)
- **Safehouse** heal + **bribe** ($500)
- Empire: street **collection**, racket **upgrade** ($800)
- **Tiered goals** (control + cash)
- Heat decay, reputation pay bonus, job cancel if you leave the marker

## Build

```bash
# Headless
zig build run-headless

# Linux GPU
zig build run -Dgpu=true

# Windows cross-compile from WSL
export GLFW_WIN=$HOME/glfw-3.4.bin.WIN64
zig build -Dtarget=x86_64-windows-gnu -Dgpu=true \
  -Dglfw_prefix=$GLFW_WIN -Doptimize=ReleaseFast
# empire.exe + glfw3.dll side by side
```

## Controls

| Key | Action |
|-----|--------|
| WASD | Move / drive |
| E | Job, car, safehouse |
| R | Bribe at safehouse / collect (empire rackets) |
| F | Attack / upgrade racket (empire) |
| Esc | Empire menu |
| 1 / 2 | Job payout choice |
| Tab | Empire panels |
| F5 / F9 | Save / load |
| H / X | Tips |

## Docs

[`docs/HANDOVER.md`](docs/HANDOVER.md)
