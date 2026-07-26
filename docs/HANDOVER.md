# Empire & Kin — Handover Document

**Version:** `0.1.1-alpha`  
**Repo:** https://github.com/5mil/empire-and-kin  
**Language:** Zig 0.16  
**GPU:** GLFW + OpenGL 3.3 (not SDL2)

---

## 1. What the game is

Real-time NYC mob simulator (1930s / 1980s): free-roam jobs, crew/empire management, police heat.

**Pillars:** real-time core · historical underworld flavor · `engine.Backend` abstraction · headless-first.

---

## 2. Current status (2026-07)

| Area | Status |
|------|--------|
| Simulation A1–A10 | Complete |
| Disk save (core fields) | Complete |
| Headless NullBackend | Complete |
| GPU window (GLFW+GL) | Working on Windows cross-compile |
| B1 bitmap font HUD | Working (procedural 8×8) |
| Building collision + world bounds | Working |
| Smoothed camera / drive FOV | Working |
| Job respawn + toasts | Working |
| Minimap (text) | Basic |
| Textures / audio | Not started |
| Full empire graph save | Not yet |

---

## 3. Build & run

```bash
# Headless
zig build run-headless

# Linux GPU
zig build run -Dgpu=true

# Windows cross-compile from WSL
export GLFW_WIN=$HOME/glfw-3.4.bin.WIN64
zig build -Dtarget=x86_64-windows-gnu -Dgpu=true \
  -Dglfw_prefix=$GLFW_WIN -Doptimize=ReleaseFast
# Run on Windows with empire.exe + glfw3.dll side by side
```

**Note:** Debug builds may hit integer-overflow panics on some paths; prefer `ReleaseFast` for playtests.

### Controls

| Key | Action |
|-----|--------|
| WASD | Move / drive |
| E | Job or vehicle |
| Esc / Space | Pause → Empire |
| Tab | Cycle panels |
| Q / E | Prev / next row (paused) |
| Enter / R / F | Panel actions / attack |
| 1–5 | Crew orders |
| F5 / F9 | Save / load |
| H / X | Tips |

---

## 4. Layout

```
src/game/     pure sim (player, economy, empire, collision, …)
src/engine/   presentation (gl_backend, scene, hud, mission_ui, …)
src/engine/gfx/  GL loader, renderer, font, math, mesh
```

**Rule:** Never break headless when adding GPU features.

---

## 5. Recent design batch (playability)

1. `collision.zig` — AABB buildings + world clamp  
2. `toast.zig` — job/save feedback  
3. Player move through collision  
4. `camera.FollowCam` smoothing  
5–8. Scene era lighting, night lamps, proximity beacons  
9–10. Job respawn + HUD  
11. Balance constants  
12–13. Boot + HUD layout  
14. Vehicle collision drive  
15. Empire pause UI  
16. Minimap  
17–20. Main wiring (toast, heal, cam)  
21–24. Hints, wanted, combat cooldown, banners  
25. Docs / VERSION  

---

## 6. Recommended next

1. Playtest Windows ReleaseFast build; note remaining “crazy” visuals  
2. C1 expanded save (rackets, fleet, jobs)  
3. Texture atlas font (perf)  
4. One PD-textured building prop  
5. Debug-mode integer overflow root cause  

---

## 7. Demo loop

```
Title → [1] New Game → era [Enter]
→ walk to cyan pole → [E] job → complete toast
→ [Esc] Empire → Tab → deploy car → [E] drive
→ F5 save → quit → [2] Continue
```

**End of handover.**
