# Empire & Kin

**NYC mob life** — 1930s / 1980s · real-time free-roam + empire.

**Branch `BETA` · Version:** `0.6.1-alpha` — Phase 5 physics + Phase 6 telemetry

## Controls

| Key | Action |
|-----|--------|
| WASD | Move / drive throttle+steer |
| Shift | Sprint (on foot) · **Handbrake** (in vehicle) |
| E | Interact / enter·exit vehicle |
| **M** | City map |
| **C** | Character map |
| **[ ]** | Camera zoom |
| Q/E | Camera orbit |
| Esc | Empire menu |
| F5/F9 | Save/Load |

## Build (Windows cross from WSL)

```bash
git checkout BETA && git pull
rm -rf .zig-cache zig-out
export GLFW_WIN=$HOME/glfw-3.4.bin.WIN64
zig build -Dtarget=x86_64-windows-gnu -Dgpu=true \
  -Dglfw_prefix=$GLFW_WIN -Doptimize=ReleaseFast
cp zig-out/bin/empire.exe /mnt/c/Users/JDaur/Info/
```

Linux GPU:

```bash
zig build run -Dgpu=true -Doptimize=ReleaseFast
```

## Docs

- [`docs/PHASE5_PHYSICS.md`](docs/PHASE5_PHYSICS.md)
- [`docs/PHASE6_TELEMETRY.md`](docs/PHASE6_TELEMETRY.md)
