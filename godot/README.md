# Empire & Kin — Godot 4

**Active development path.** Zig prototype is frozen on branch `BETA`.

## Goals

- Street-level third-person (default) or FPS — **not** elevated god-cam
- One authored district that reads at eye height
- CC0 / public-domain assets only
- Systems (heat, jobs, empire) only after the district holds up visually

## Requirements

- [Godot 4.3+](https://godotengine.org/download) (Forward Plus)

## Open

1. Install Godot 4.3+
2. **Import** → select this folder (`godot/` containing `project.godot`)
3. Press **F5** (main scene: `scenes/main.tscn`)

## Controls (initial)

| Key | Action |
|-----|--------|
| WASD | Move |
| Mouse | Look |
| Shift | Sprint |
| E | Interact (stub) |
| Esc | Release mouse |

## Layout

```
godot/
  project.godot
  scenes/main.tscn      # world + player spawn
  scripts/player.gd     # street-level chase cam + movement
  scripts/main.gd
```

## Zig freeze

```bash
git checkout BETA   # full Zig 0.6.0-alpha snapshot + docs/BETA_FREEZE.md
```
