# Empire & Kin

**New York City mob life simulator** — 1930s or 1980s.

Real-time free-roam + living crew + empire management.

**Stack**: Zig · Magister · Arcis · RealCity (target) · `engine.Backend` abstraction

## Art
Public-domain historical sources preferred — `docs/ART_SOURCES.md`.

## Progress
- Simulation foundation (Phases 6–10) ✅  
- Steps 1–6 ✅ — backend, loop, scene, input, district HUD, **empire pause UI**

Next: Step 7 vehicles on screen. See `docs/NEXT10.md`.

## Controls
| Input | Action |
|-------|--------|
| WASD / Arrows | Move |
| E | Interact |
| F | Attack |
| Esc / Space | Pause / empire menu |
| 1–5 (while paused) | Crew orders: Collect, Rest, Enforce, Scout, Guard |

```bash
zig build run
```
