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
| All prior systems | Done   | Healing, combat, missions, city, crew…     |
| Rackets / Orders  | Done   | Empire layer                               |
| Day/Night + Police| Done   | Living world                               |
| Vehicles          | Done   | Sedan, truck, motorcycle, taxi             |
| Chases            | Done   | Pursuit distance, escape / caught          |
| Open-world Missions| Done  | Location-triggered jobs                    |
| RT Combat Encounter| Done  | Street fights tied to player               |

---

## Roadmap

### Phases 6–10 ✅ (foundation complete)

**Next directions**
- Wire into actual Magister / Arcis rendering
- Real input + camera
- Full map / streaming
- Audio, UI polish, save to disk

---

## Running

```bash
zig build run
```

---

*Built for a living city, not a board game.*
