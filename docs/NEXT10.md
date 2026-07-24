# Next 10 Steps — Toward a Playable Visual Game

## Art policy

**Prefer public-domain and freely licensed historical sources** wherever possible:

- Photographs, maps, and reference images from pre-1929 / expired-copyright collections (Library of Congress, NYPL Digital Collections, Internet Archive, Wikimedia Commons PD)
- 1930s: period street photos, elevated trains, brownstones, cars, fashion
- 1980s: still respect copyright — use only PD, CC0, or original/licensed assets; modern photos are usually *not* PD
- Maps: historical Sanborn / city surveys in PD for layout reference
- Audio: PD recordings or original; avoid commercial music
- We implement art **as appropriate** — placeholders first, swap in PD references when wiring the renderer

Never ship copyrighted third-party game assets or non-PD modern photos without a license.

---

## Steps

| # | Step | Goal |
|---|------|------|
| 1 | **Lock engine path** | Renderer-agnostic backend interface; Magister/Arcis/RealCity as target, null/console backend now |
| 2 | **Window + main loop** | Real frame loop + dt (or headless fixed step until window backend exists) |
| 3 | **Minimal scene** | Camera + ground + player proxy visible in chosen backend |
| 4 | **Input → controller** | Keys/pad move the existing `player` and update district |
| 5 | **District debug view** | On-screen district name, heat, control |
| 6 | **Empire pause UI** | Overlay for rackets, crew orders, influence |
| 7 | **Vehicles on screen** | Driveable car, enter/exit, camera follow |
| 8 | **Wanted / police feedback** | Stars + simple pursuit visuals from living systems |
| 9 | **Mission markers + first job** | World marker → start/complete one mission |
| 10 | **Vertical slice + disk save** | Full loop + save/load file; demo-ready prototype |

---

## Engine decision (Step 1)

**Target stack (as designed):** Zig + Magister + Arcis + RealCity  

**Current reality:** Those backends are not wired in this repo yet. Simulation is complete and headless.

**Approach:**

1. Define a thin `engine.Backend` interface (init, poll input, begin/end frame, draw primitives, shutdown).
2. Ship a **NullBackend** (console / no window) so CI and logic keep working.
3. When Magister/Arcis/RealCity (or interim raylib/SDL) is available, implement the same interface — **no gameplay rewrite**.

All game code continues to talk only to simulation modules + the backend interface.
