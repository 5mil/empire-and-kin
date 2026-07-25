# Empire & Kin

**New York City mob life simulator** — 1930s or 1980s.

Real-time free-roam + living crew + empire management.

**Version:** `0.1.0-alpha`  
**Stack:** Zig · SDL2 + OpenGL 3.3 · `engine.Backend` (Magister/Arcis/RealCity target)

## Art
Public-domain historical sources preferred — `docs/ART_SOURCES.md`.

## Status
**Alpha track complete (A1–A10)** + GPU infrastructure.  
**Full handover:** [`docs/HANDOVER.md`](docs/HANDOVER.md)

## Play

```bash
zig build run              # GPU (SDL2 + OpenGL)
zig build run-headless     # NullBackend
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
- `docs/RELEASE_NOTES_ALPHA.md`
