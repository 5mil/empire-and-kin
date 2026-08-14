# Empire & Kin

**NYC mob life** — 1930s / 1980s · real-time free-roam + empire.

**Version:** `0.6.0-alpha` — Phase 5 raycast driving physics

## Controls

| Key | Action |
|-----|--------|
| WASD | Move / drive throttle+steer |
| Shift | Sprint (on foot) · **Handbrake** (in vehicle) |
| E | Interact / enter·exit vehicle |
| **M** | City map (WASD pan, Q/E zoom) |
| **C** | Character map |
| **[ ]** | Camera zoom |
| Q/E | Camera orbit |
| Esc | Empire menu |
| F5/F9 | Save/Load |

## Build

```bash
git pull
zig build -Dgpu=true -Doptimize=ReleaseFast
./zig-out/bin/empire
```

Windows cross: see prior notes (`-Dtarget=x86_64-windows-gnu -Dglfw_prefix=...`).

## Assets

```bash
./tools/fetch_cc0_assets.sh
```

## Docs

- [`docs/GRAPHICS_DETAIL.md`](docs/GRAPHICS_DETAIL.md) — detail path vs GTA 4
- [`docs/RESOURCE_SYSTEM.md`](docs/RESOURCE_SYSTEM.md)
- [`docs/MESH_SKINS.md`](docs/MESH_SKINS.md)
- [`docs/PHASE5_PHYSICS.md`](docs/PHASE5_PHYSICS.md) — raycast drive physics
