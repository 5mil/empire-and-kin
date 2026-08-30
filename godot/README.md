# Empire & Kin — Godot 4

**Active path.** Zig prototype frozen on branch `BETA` (0.6.0-alpha).

Systems from BETA are ported as autoloads + street-level play. Art is still temporary; **district geography will follow real NYC maps** (see `Districts.REAL_BOUNDS`).

## Requirements

- [Godot 4.3+](https://godotengine.org/download) (Forward Plus)

## Open

```bash
git pull
# Godot → Import → empire-and-kin/godot/
# F5
```

## Controls

| Key | Action |
|-----|--------|
| WASD | Move / drive |
| Mouse | Look |
| Shift | Sprint / **handbrake** (in car) |
| E | Interact / enter·exit vehicle / start job |
| F5 / F9 | Save / Load |
| Esc | Release mouse |

## Ported from BETA

| System | Location |
|--------|----------|
| Balance numbers | `scripts/autoload/balance.gd` |
| Districts + real map anchors | `scripts/autoload/districts.gd` |
| Cash, heat, wanted, clock, events | `scripts/autoload/game_state.gd` |
| Rackets | `scripts/autoload/empire.gd` |
| Save/Load | `scripts/autoload/save_system.gd` |
| Phase-5 style drive | `scripts/vehicle.gd` |
| Jobs | `scripts/job_marker.gd` |
| HUD | `scenes/hud.tscn` |

Full mapping: [`docs/PORT_FROM_BETA.md`](docs/PORT_FROM_BETA.md)

## Layout

```
godot/
  project.godot
  scenes/main.tscn   # world + player + sedan + job + HUD
  scenes/hud.tscn
  scripts/…
  docs/PORT_FROM_BETA.md
```

## Next

1. Authored **Hell’s Kitchen** block from OSM (real streets)
2. CC0 building/vehicle meshes at street scale
3. Deeper empire UI / crew (from BETA menus)
