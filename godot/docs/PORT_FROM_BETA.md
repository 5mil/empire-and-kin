# Port map: Zig BETA → Godot 4

Zig engine is frozen on branch **`BETA`** (`0.6.0-alpha`). Active work is Godot under `godot/`.

## Camera (design change)

| BETA (Zig) | Godot |
|------------|--------|
| Elevated FollowCam (~18 m height) | Street-level SpringArm (~5 m, eye 1.7) |
| Orbit Q/E, zoom [ ] | Mouse look |

## Systems ported

| Zig | Godot |
|-----|--------|
| `balance.zig` | `scripts/autoload/balance.gd` |
| `city.zig` districts | `scripts/autoload/districts.gd` + **real lat/lon anchors** |
| session economy / heat / clock / wanted | `scripts/autoload/game_state.gd` |
| `empire.zig` rackets | `scripts/autoload/empire.gd` |
| `save.zig` F5/F9 | `scripts/autoload/save_system.gd` |
| `vehicle_phys.zig` Phase 5 | `scripts/vehicle.gd` (RigidBody + handbrake) |
| mission jobs | `scripts/job_marker.gd` |
| HUD panels | `scripts/ui/hud.gd` + `scenes/hud.tscn` |
| player move | `scripts/player.gd` + enter/exit vehicle |

## Not yet ported (queue)

- Full empire menu UI, crew assignments, loans, stash
- Traffic AI, ped crowds, rival encounters as 3D agents
- Raycast suspension mesh lean (visual) — use VehicleBody3D wheels later
- Android GLES path (Godot export replaces)
- Authored Hell’s Kitchen from OSM (next art milestone)

## Real maps

District IDs keep BETA names. `Districts.REAL_BOUNDS` stores WGS84 centers for OSM-based block authoring. Default play district: **`hells_kitchen`**.

## Open project

Godot 4.3+ → open `godot/` folder → F5.
