# Port map: Zig BETA → Godot 4

Zig engine is frozen on branch **`BETA`** (`0.6.0-alpha`). Active work is Godot under `godot/`.

## Graphics backends (resolved by Godot)

| Zig BETA | Godot |
|----------|--------|
| Custom GL 3.3 (`gl_backend.zig`) | Forward+ (Vulkan/GL) desktop |
| Custom GLES 3.0 (`gles_backend.zig`) | Mobile renderer on Android export |
| `gltf_loader.zig` + `skin.zig` bind-pose | `GLTFDocument` + `Skeleton3D` via `AssetContinuum` |
| `texture_bank` / `recipe` resolver | `scripts/autoload/asset_continuum.gd` |

Drop CC0/TRELLIS `.glb` under `godot/assets/cc0/` or `godot/assets/generated/` — spots and buildings upgrade from T0 boxes automatically.

## Systems ported

| Zig | Godot |
|-----|--------|
| `balance.zig` | `scripts/autoload/balance.gd` |
| `city.zig` districts | `scripts/autoload/districts.gd` |
| economy / heat / clock / wanted | `scripts/autoload/game_state.gd` |
| `empire.zig` rackets + crew + payday | `scripts/autoload/empire.gd` |
| rival / stash / loan / ambush / news | `scripts/autoload/world_sim.gd` |
| `interact.zig` (~40 E-key spots) | `interact_catalog.gd` + `interact_spot.gd` |
| `save.zig` F5/F9 | `save_system.gd` (now includes empire + world_sim) |
| recipe / continuum | `asset_continuum.gd` |
| vehicle Phase 5 | `scripts/vehicle.gd` |
| jobs / HUD / player | existing scenes |

## Interact spots (E)

Fence, stash, doc, numbers, bar, vendor, phone, paper, church, dock, blackjack, informant, warehouse, arcade, taxi, bakery, barber, laundry, perfume, cigar, post, recruit, alley, hospital, intimidate, lookout, speakeasy, garage, pawn, bookie, florist, butcher, tailor, union, racing form, fire escape, pier, club, safe stash.

## Open project

Godot 4.3+ → open `godot/` folder → F5.
