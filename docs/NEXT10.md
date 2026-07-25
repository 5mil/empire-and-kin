# Next 10 Steps — Toward a Playable Visual Game

## Art policy

Prefer **public-domain / free historical** sources (LOC, NYPL, Wikimedia Commons PD, Internet Archive).  
Placeholders first; PD art as appropriate. See `docs/ART_SOURCES.md`.

---

## Steps

| # | Step | Status |
|---|------|--------|
| 1 | Engine backend | ✅ |
| 2 | Frame loop | ✅ |
| 3 | Minimal scene | ✅ |
| 4 | Input → controller | ✅ |
| 5 | District debug HUD | ✅ |
| 6 | **Empire pause UI** | ✅ (see details below) |
| 7 | Vehicles on screen | Driveable car, enter/exit, camera follow |
| 8 | Wanted / police feedback | Stars + pursuit visuals |
| 9 | Mission markers + first job | World marker → complete mission |
| 10 | Vertical slice + disk save | Demo-ready prototype |

---

## Step 6 details (Empire pause UI)

**Goal:** When the player pauses, open an empire management overlay without leaving the session.

### Behavior
- **Pause** (Esc / Space / Start) freezes free-roam movement and simulation tick.
- Overlay draws on top of the scene (text now; real UI toolkit later).
- **Resume** with the same pause key.

### Panels
1. **Header** — Influence, reputation label, estimated racket $/day  
2. **Rackets** — type, level, assigned crew member  
3. **Crew** — name, loyalty, fatigue; `>` marks selected member  
4. **Orders** — one-shot keys applied to selected crew:

| Key | Order | Effect |
|-----|--------|--------|
| 1 | Collect | Pull cash from rackets |
| 2 | Rest | Lower fatigue, raise morale |
| 3 | Enforce | Raise district control + reputation |
| 4 | Scout | Lower district heat |
| 5 | Guard | Reduce racket heat generation |

### Files
- `src/engine/empire_ui.zig` — draw + order handling  
- Wired from `main` when `controller.paused`  
- `RawKeys.key_1`…`key_5` for menu input  

### Later polish
- Click / gamepad navigation of racket & crew rows  
- Assign crew to racket from this screen  
- Optional: keep world ticking slowly while menu is open  
