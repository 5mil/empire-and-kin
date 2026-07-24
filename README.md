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
1930s photography often usable after rights check; 1980s usually needs original or licensed assets.  
See `docs/ART_SOURCES.md`. Placeholders first, PD art as appropriate.

---

## Where we are

- **Simulation foundation (Phases 6–10):** complete (economy, crew, rackets, police, vehicles, missions, eras…)
- **Step 1:** Engine backend interface + NullBackend ✅
- **Step 2:** Continuous frame loop driving simulation ✅ (headless)

Next: real window backend → visible player → input → UI → vertical slice.  
Full list: `docs/NEXT10.md`

---

## Running

```bash
zig build run
```

Headless loop runs ~90 frames then exits. Swap `null_backend` for a real Magister/Arcis/RealCity backend when ready — gameplay code stays the same.

---

*Built for a living city, not a board game.*
