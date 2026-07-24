# Empire & Kin

**New York City mob life simulator** — choose your era.

GTA-style free-roam action + Sims-style living crew + continuous city/empire simulation.

---

## Eras

| Era | Setting | Flavor |
|-----|---------|--------|
| **1930s NYC** | Post-Prohibition, early Commission | Luciano, Lansky, Anastasia, Dutch Schultz, Owney Madden, Harlem numbers, Chinatown tongs |
| **1980s NYC** | Commission still strong | Gambino, Genovese, Lucchese, Bonanno, Colombo, The Westies, Ghost Shadows, Brighton Beach Russians |

Player can select either era. Rival organizations, bosses, and ethnic makeup change accordingly.

---

## Design Philosophy

This is **not** a turn-based strategy game.

- Time flows continuously.
- Rackets generate money every second.
- Crew needs, loyalty, fatigue and heat change in real time.
- You can pause for management, but the world is always alive.
- Combat, driving and missions happen in the same continuous world.

**Stack**: Zig · Magister · Arcis · RealCity

---

## Current Systems

| System            | Status | Notes                                      |
|-------------------|--------|--------------------------------------------|
| Era Select        | Done   | 1930s or 1980s NYC                         |
| Multi-ethnic Orgs | Done   | Italian, Jewish, Irish, Chinese, Black, Russian |
| Healing           | Done   | Safehouses, food, entertainment            |
| Combat            | Done   | Basic fighter resolution                   |
| Missions          | Done   | Bootlegging, protection, hits, heists…     |
| City              | Done   | 6 districts with control & heat            |
| Crew              | Done   | Roles, loyalty, morale, fatigue            |
| Economy           | Done   | Real-time income & upkeep                  |
| Events            | Done   | Police raids, informants, lucky breaks…    |
| Rivals            | Done   | Era-specific real-world inspired rosters   |
| Save/Load         | Done   | In-memory slot                             |
| Simulation Clock  | Done   | Continuous game time + time scale          |
| Player Controller | Done   | Position, movement, health, wanted         |
| District Awareness| Done   | Location → current district                |
| Empire Menu       | Done   | Pauseable overview                         |

---

## Roadmap

### Phase 6 – Simulation Core ✅
### Phase 7 – Free-Roam Skeleton ✅
### Phase 7.5 – Era + Multi-Ethnic Underworld ✅

### Phase 8 – Living World
- Pedestrian & traffic AI
- Dynamic police response to heat
- Day/night cycle

### Phase 9 – Empire Layer
- Full racket assignment UI
- Crew orders
- Influence & reputation

### Phase 10 – Action Integration
- Open-world missions
- Real-time combat
- Vehicles & chases

---

## Running

```bash
zig build run
```

Change `selected_era` in `src/main.zig` between `.nyc_1930s` and `.nyc_1980s` to switch the underworld roster.

---

*Built for a living city, not a board game.*
