# Empire & Kin

**Prohibition-era New York City mob life simulator.**

GTA-style free-roam action + Sims-style living crew + continuous city/empire simulation.

---

## Design Philosophy

This is **not** a turn-based strategy game.

- Time flows continuously.
- Rackets generate money every second.
- Crew needs, loyalty, fatigue and heat change in real time.
- You can pause for management, but the world is always alive.
- Combat, driving and missions happen in the same continuous world.

Think *GTA* + *The Sims* + a living 1920s New York that reacts to your empire.

**Stack**: Zig · Magister · Arcis · RealCity

---

## Current Systems

| System            | Status | Notes                                      |
|-------------------|--------|--------------------------------------------|
| Healing           | Done   | Safehouses, food, entertainment            |
| Combat            | Done   | Basic fighter resolution                   |
| Missions          | Done   | Bootlegging, protection, hits, heists…     |
| City              | Done   | 6 districts with control & heat            |
| Crew              | Done   | Roles, loyalty, morale, fatigue            |
| Economy           | Done   | Real-time income & upkeep (per second)     |
| Events            | Done   | Police raids, informants, lucky breaks…    |
| Rivals            | Done   | Maranzano, Masseria, Irish Mob             |
| Save/Load         | Done   | In-memory slot (file later)                |
| Simulation Clock  | Done   | Continuous game time + time scale          |
| Player Controller | Done   | Position, movement, health, wanted level   |
| District Awareness| Done   | Location → current district                |
| Empire Menu       | Done   | Pauseable overview (text stub)             |

---

## Roadmap (Real-Time Focus)

### Phase 6 – Simulation Core ✅
- Continuous clock & delta-time economy
- Heat / control / morale over time

### Phase 7 – Free-Roam Skeleton ✅
- Player controller (placeholder → Magister/Arcis)
- Simple district streaming / location awareness
- Pause menu for empire management

### Phase 8 – Living World
- Pedestrian & traffic AI
- Dynamic police response to heat
- Day/night cycle affecting gameplay

### Phase 9 – Empire Layer
- Full racket assignment UI
- Crew orders (send to district, rest, collect)
- Influence & reputation systems

### Phase 10 – Action Integration
- Seamless mission start from the open world
- Real-time combat with cover / guns / melee
- Vehicle & chase systems

### Later
- Rival AI that expands territory in real time
- Multiple endings / empire collapse
- Multiplayer or co-op crew (stretch)

---

## Running

```bash
zig build run
```

Phase 7 demo walks the player across district boundaries and opens the pauseable empire menu.

---

*Built for a living city, not a board game.*
