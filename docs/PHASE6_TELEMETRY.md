# Phase 6 — Vehicle telemetry HUD

**Status:** shipped in `0.6.1-alpha` on branch `BETA`.

## What you should see

On foot: existing needs HUD.
In a vehicle (`E` near sedan): bottom-center instruments replace the needs card.

| Readout | Source |
|---------|--------|
| MPH | `Vehicle.speed` × 2.237 |
| RPM | long speed × gear ratio |
| GEAR | 1–5 or R |
| SLIP | |lateral| / speed (handbrake lights this up) |
| DMG / HP | 100 − vehicle health |

## Files

| Path | Role |
|------|------|
| `src/game/telemetry.zig` | Sample instruments |
| `src/engine/vehicle_hud.zig` | Draw while occupied |
| `src/engine/play_draw.zig` | Swap HUD when driving |

## Playtest

```bash
git checkout BETA && git pull
rm -rf .zig-cache zig-out
export GLFW_WIN=$HOME/glfw-3.4.bin.WIN64
zig build -Dtarget=x86_64-windows-gnu -Dgpu=true \
  -Dglfw_prefix=$GLFW_WIN -Doptimize=ReleaseFast
```

1. Enter car — MPH/RPM/GEAR appear; foot HUD hides.
2. Accelerate — MPH and RPM climb; gear upshifts.
3. Handbrake mid-turn — SLIP goes amber/red.
4. Hit a wall — DMG rises, HP falls.
5. Exit (`E`) — needs HUD returns.

## Next (Phase 7)

Traffic + street-life density (`docs/REAL_GAME_ROADMAP.md`).
