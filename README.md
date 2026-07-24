# Empire & Kin

**New York City mob life simulator** — choose your era.

GTA-style free-roam action + Sims-style living crew + continuous city/empire simulation.

---

## Eras

| Era | Setting | Flavor |
|-----|---------|--------|
| **1930s NYC** | Post-Prohibition, early Commission | Luciano, Lansky, Anastasia, Dutch Schultz, Owney Madden, Harlem numbers, Chinatown tongs |
| **1980s NYC** | Commission still strong | Gambino, Genovese, Lucchese, Bonanno, Colombo, The Westies, Ghost Shadows, Brighton Beach Russians |

---

## Design Philosophy

Real-time continuous simulation. The city lives whether you are looking or not.

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
| Day / Night       | Done   | Periods + activity levels                  |
| Street Life       | Done   | Pedestrians & traffic density              |
| Dynamic Police    | Done   | Responds to heat + wanted + time of day    |
| Rackets           | Done   | Types, levels, crew assignment             |
| Crew Orders       | Done   | Collect, rest, enforce, scout, guard       |
| Influence / Rep   | Done   | Influence points + reputation scale        |

---

## Roadmap

### Phase 6 – Simulation Core ✅
### Phase 7 – Free-Roam Skeleton ✅
### Phase 7.5 – Era + Multi-Ethnic Underworld ✅
### Phase 8 – Living World ✅
### Phase 9 – Empire Layer ✅
- Racket assignment
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

Phase 9 demo builds rackets, assigns crew, issues orders, upgrades, and tracks influence/reputation.

---

*Built for a living city, not a board game.*
