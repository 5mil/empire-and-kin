# Empire & Kin — Complete Handover Document

**Version:** `0.1.0-alpha`  
**Repo:** https://github.com/5mil/empire-and-kin  
**Language:** Zig  
**Last structured status:** Alpha complete + GPU infrastructure (SDL2 + OpenGL 3.3)

This document is the single entry point for a new developer or AI agent taking over the project. Read it end-to-end before changing systems.

---

## 1. What the game is

**Empire & Kin** is a real-time New York City mob life simulator set in either the **1930s** or **1980s**. It blends:

- **GTA-style** free-roam action (move, drive, jobs, police heat)
- **Sims-style** crew / life simulation (loyalty, fatigue, orders)
- **City-builder / empire** management (rackets, properties, vehicles, influence)

The player is a rising boss: walk the districts, run jobs, manage crew and rackets, dodge heat and rivals, and grow the organization.

**Design pillars**

1. Real-time (not turn-based) — GTA and Sims are real-time; turn-based was explicitly rejected except as possible side minigames later.
2. Historically grounded underworld names and multi-ethnic organizations (Italian, Jewish, Irish, Chinese, Black, Russian crews depending on era).
3. Public-domain historical art preferred for production assets.
4. Renderer-agnostic gameplay via `engine.Backend` so GPU backends can swap without rewriting simulation.

---

## 2. Current status (honest)

| Area | Status |
|------|--------|
| Simulation / systems (Phases → Alpha A1–A10) | **Complete** |
| Disk save/load | **Complete** (core fields; not full empire graph) |
| Headless demo loop | **Complete** (`NullBackend`) |
| GPU window + OpenGL path | **Infrastructure complete**; needs machine with SDL2 + GL |
| Real 3D art / textures | **Not started** (colored primitives) |
| Bitmap font / readable HUD text on GPU | **Proxy only** (colored bars for text lines) |
| Audio | **Not started** |
| Magister / Arcis / RealCity | **Targets only** — not public engines; abstract behind `Backend` |
| Store-ready / polished beta | **Not ready** |

**Alpha definition (met):** Boot, era select, free-roam, jobs, empire menu, police/events/rivals, save/load, no panic on NullBackend.

**Not alpha:** AAA graphics, full map, audio, deep save of every racket/property slot.

---

## 3. How to build and run

### Dependencies

- **Zig** (match project’s intended version; prefer recent stable 0.13+)
- **Linux GPU build:** `libSDL2`, OpenGL (`libGL` / Mesa or vendor)
- **Headless:** no GPU libs required

### Commands

```bash
git clone https://github.com/5mil/empire-and-kin.git
cd empire-and-kin

# GPU (default) — opens SDL2 window, OpenGL 3.3
zig build run

# Headless / CI / no display
zig build run-headless
# or
zig build -Dgpu=false
zig build run -Dgpu=false
```

Binary name: `empire` (GPU) / `empire-headless`.

### Controls

| Key | Action |
|-----|--------|
| WASD / arrows | Move or drive |
| E | Start job (near marker) or enter/exit vehicle |
| Esc / Space | Pause → Empire menu |
| Tab | Cycle empire panels (Rackets / Crew / Properties / Vehicles) |
| Q / E | Prev / next row in focused panel (when paused) |
| Enter | Primary action (assign / upgrade / deploy) |
| R | Secondary (repair) |
| F | Tertiary (store vehicle) or attack in fight |
| 1–5 | Crew orders (Collect, Rest, Enforce, Scout, Guard) |
| F5 / F9 | Quick-save / quick-load |
| H / X | Next onboarding tip / dismiss tips |

### Save file

- Path: `empire_save.txt` in the process working directory  
- Format: line-based `key=value`  
- Fields include day, time, treasury, influence, crew stats, player position/health/wanted, district heat/control, `era_id`  
- Written on F5, F9 load, and on quit  

---

## 4. Repository layout

```
empire-and-kin/
├── README.md
├── VERSION                 # 0.1.0-alpha
├── build.zig               # -Dgpu=true|false, run + run-headless
├── docs/
│   ├── HANDOVER.md         # this file
│   ├── ALPHA_ROADMAP.md
│   ├── ALPHA_CHECKLIST.md
│   ├── RELEASE_NOTES_ALPHA.md
│   ├── STEP10_VERTICAL_SLICE.md
│   ├── NEXT10.md
│   ├── GFX_ARCHITECTURE.md
│   ├── GPU_GRAPHICS.md
│   ├── BETA_GPU.md
│   └── ART_SOURCES.md
└── src/
    ├── main.zig            # boot, loop, backend select
    ├── game/               # pure simulation (no GL)
    │   ├── player.zig, crew.zig, city.zig, world.zig
    │   ├── economy.zig, empire.zig, properties.zig, garage.zig
    │   ├── missions.zig, action.zig, combat.zig, healing.zig
    │   ├── living.zig, events.zig, rivals.zig, era.zig
    │   ├── time.zig, save.zig, balance.zig, ui.zig
    └── engine/             # IO + presentation
        ├── backend.zig     # Backend vtable API
        ├── null_backend.zig
        ├── gl_backend.zig  # SDL2 + OpenGL implementation
        ├── input.zig, controller.zig, scene.zig
        ├── hud.zig, empire_ui.zig, mission_ui.zig
        ├── wanted_ui.zig, boot.zig, hints.zig
        ├── combat_ui.zig, world_sim.zig
        └── gfx/
            ├── sdl_window.zig
            ├── gl.zig, shaders.zig, math.zig
            ├── mesh.zig, gpu_mesh.zig, renderer.zig
            └── glfw_window.zig   # alternate; prefer SDL on this tree
```

**Rule:** Game logic lives under `src/game/`. Rendering and OS windowing live under `src/engine/`. Simulation must keep working with `NullBackend`.

---

## 5. Architecture notes

### Backend abstraction

`engine.Backend` is a vtable: init, frame, input, camera, drawGround/Box/Player/Vehicle, drawText, etc.

- `selectBackend()` in `main.zig` uses `build_options.enable_gpu`.
- GPU: `gl_backend.getBackend()`
- Headless: `null_backend.getBackend()` (+ scripted input for demos)

### Simulation (real-time)

- `time.Clock` with `time_scale` (demo often ~20×)
- `economy.tick` per game-second income/upkeep
- `living` street activity + police alert
- `world_sim` periodic events + rival control pressure
- `mission_ui` world markers, start, progress, payout + heat
- `wanted_ui` stars + chase at 3+ stars
- `empire_ui` pause panels: rackets, crew, properties, vehicles

### Eras & rivals

- `era.Era`: `nyc_1930s` | `nyc_1980s`
- `rivals.getRivalsForEra` fills historical org names (Luciano, Lansky, Westies, tongs, etc.)
- Boot flow: Title → New Game → era select → play, or Continue from disk

### Graphics pipeline (GPU)

1. SDL2 creates window + OpenGL 3.3 core context  
2. `gl.load` resolves function pointers  
3. Compile/link embedded GLSL 330 (lit + UI)  
4. Upload unit box + ground meshes  
5. Each frame: clear → set camera → draw scene → UI proxies → swap  

See `docs/GFX_ARCHITECTURE.md`.

---

## 6. Design decisions already made (do not re-litigate without cause)

1. **Real-time**, not turn-based core loop.  
2. **Two eras** selectable at New Game.  
3. **Multi-ethnic historical names** for rival orgs.  
4. **Public-domain art first** — see `docs/ART_SOURCES.md`.  
5. **Backend abstraction** before locking to one engine.  
6. Magister / Arcis / RealCity are **named targets**, not shipped dependencies; implement or replace with SDL/GL/Vulkan as needed.  
7. Alpha freeze prioritizes **playable loop + save**, not art polish.

---

## 7. Known limitations / tech debt

- Save does **not** yet persist full racket list, property portfolio, fleet inventory, or job state — only summary + player/district core.  
- Combat is **stub** resolution.  
- GPU text is **rect proxies**, not glyphs.  
- Mesh colors rely on `uTint` + simple lighting; no textures.  
- `glfw_window.zig` may exist as alternate; **SDL2 is the linked default** in `build.zig`.  
- Sandbox/CI environments may lack display; use `-Dgpu=false`.  
- Some GitHub pushes during rapid alpha may lag local `src/engine/gfx/*` files — always treat the **working tree** as source of truth and push missing modules if clone is incomplete.

---

## 8. Full future plan

### Phase B — Beta graphics & presentation (next priority)

| ID | Item | Notes |
|----|------|--------|
| B1 | Bitmap font atlas | Real `drawText` on GPU (8×8 or SDF) |
| B2 | Material / texture pass | Ground, buildings; PD maps as reference |
| B3 | Visual identity | Era-tinted lighting (1930s warm / 1980s neon-cool) |
| B4 | Camera polish | Collision with buildings, FOV by vehicle |
| B5 | Verify GPU path on real desktop | SDL2 + Mesa/NVIDIA/AMD |
| B6 | Optional Vulkan backend | Same `Backend` interface; not required for beta |

### Phase C — Content & simulation depth

| ID | Item |
|----|------|
| C1 | Expanded save: rackets[], properties[], fleet, active jobs, era |
| C2 | More districts + district-specific rackets |
| C3 | Mission variety graphs (chains, fail states) |
| C4 | Real combat encounters (HP, weapons tiers, flee) |
| C5 | Safehouse healing loop wired to UI |
| C6 | Rival AI turns (hostility, takeovers) |
| C7 | Economy balance for 30–60 min sessions |

### Phase D — Audio & UX

| ID | Item |
|----|------|
| D1 | Audio backend abstraction (device + buses) |
| D2 | Ambient beds per era / period (day/night) |
| D3 | One-shot SFX (gun, car, UI) |
| D4 | Settings menu (graphics, audio, keybinds) |
| D5 | Pause menu polish + map screen |

### Phase E — World scale

| ID | Item |
|----|------|
| E1 | Larger open-world layout (block grid, landmarks) |
| E2 | Streaming or chunked district load |
| E3 | Traffic / ped density tuning |
| E4 | Interior shells (speakeasy, social club) |

### Phase F — Production readiness

| ID | Item |
|----|------|
| F1 | Automated tests for economy, save round-trip |
| F2 | Versioned save format + migration |
| F3 | Packaging (Linux AppImage / Windows zip) |
| F4 | Credits, licenses for PD assets |
| F5 | Beta tag `0.2.0-beta` / public playtest build |

### Long-term (post-beta)

- Full career / campaign structure  
- Side minigames (could be turn-based without breaking core)  
- Mod-friendly data (JSON/Zig for rackets, missions)  
- If Magister/Arcis/RealCity become real APIs: implement as additional `Backend`s  

---

## 9. Recommended next actions (ordered)

1. **Confirm clone builds** headless: `zig build run-headless`  
2. **Confirm GPU build** on a machine with SDL2: `zig build run`  
3. **Push any missing `gfx/` files** if GitHub tree is incomplete vs this handover  
4. Implement **B1 bitmap font** so HUD is readable on GPU  
5. Expand **save format (C1)** before adding more persistent systems  
6. Add **one textured prop** from a verified PD source (art pipeline proof)  

---

## 10. Instructions for AI / new contributors

1. Prefer **small, pushable commits** with clear messages.  
2. Never break **headless** path when adding GPU features.  
3. Keep simulation **delta-time based**.  
4. Do not introduce turn-based core loop.  
5. Check **ART_SOURCES.md** before adding visual assets.  
6. Update **VERSION** and release notes when cutting beta.  
7. When uncertain about historical names, prefer documented real orgs; avoid inventing slanderous claims about living persons.  
8. `build_options.enable_gpu` gates GL imports so headless still compiles without SDL.

---

## 11. Doc index

| File | Purpose |
|------|---------|
| `docs/HANDOVER.md` | **This document** — full handoff |
| `docs/ALPHA_ROADMAP.md` | Alpha steps A1–A10 (done) |
| `docs/ALPHA_CHECKLIST.md` | Acceptance checklist |
| `docs/RELEASE_NOTES_ALPHA.md` | 0.1.0-alpha notes |
| `docs/STEP10_VERTICAL_SLICE.md` | Vertical slice design |
| `docs/NEXT10.md` | Foundation steps 1–10 |
| `docs/GFX_ARCHITECTURE.md` | GPU module map |
| `docs/GPU_GRAPHICS.md` / `BETA_GPU.md` | Graphics beta notes |
| `docs/ART_SOURCES.md` | PD art policy and sources |

---

## 12. Demo loop (acceptance for alpha)

```
Title → [1] New Game → pick 1930s [Enter]
→ walk to cyan job marker → [E] Speakeasy Delivery → complete
→ [Esc] Empire → Tab panels → deploy car → [E] drive
→ events/rivals tick → wanted if hot → [F5] save → quit
→ relaunch → [2] Continue (if save exists)
```

Headless NullBackend scripts a shortened path for automated demos.

---

## 13. Contact / ownership

- GitHub: **5mil/empire-and-kin**  
- Version source of truth: `VERSION` file  
- Stack intent: **Zig + engine.Backend**; GPU via **SDL2 + OpenGL 3.3** until a higher-level engine is truly integrated  

**End of handover.** Continue from §9 unless product priorities change.
