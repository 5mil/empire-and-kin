# Empire & Kin

**New York City mob life simulator** — choose your era.

GTA-style free-roam action + Sims-style living crew + continuous city/empire simulation.

---

## Eras

| Era | Setting |
|-----|---------|
| **1930s NYC** | Post-Prohibition, early Commission |
| **1980s NYC** | Commission era + Westies, tongs, Brighton Beach |

---

## Design Philosophy

Real-time continuous simulation. Pause for empire management; the world can keep living underneath.

**Stack**: Zig · Magister · Arcis · RealCity (target) · thin `engine.Backend` abstraction now

---

## Art policy

**Public-domain / free historical sources first** (LOC, NYPL, Wikimedia Commons PD, Internet Archive).  
See `docs/ART_SOURCES.md`. Placeholders first, PD art as appropriate.

---

## Where we are

- **Simulation foundation (Phases 6–10):** complete
- **Step 1–3:** Backend, frame loop, minimal scene ✅
- **Step 4:** Input mapper + controller (WASD/pad → move, district) ✅

Next: Step 5 district HUD → empire pause UI → vehicles.  
Full list: `docs/NEXT10.md`

---

## Controls (Step 4)

`WASD` / arrows move · `E` interact · `F` attack · `Esc` / `Space` pause

---

## Running

```bash
zig build run
```

---

*Built for a living city, not a board game.*
