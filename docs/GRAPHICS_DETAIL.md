# Graphics detail path (`0.5.2`)

## Honest scope vs GTA 4

**GTA 4** ships years of hand-authored city meshes, high-res textures, animation graphs, physics, and a full map stack (RAGE streaming, sparse virtual texturing, dual-paraboloid reflections).  
Empire & Kin **cannot** match that in one sprint or with CC0-only art. This release locks **richer material identity + fuller character map + better map controls + denser streets** into the codebase so the city and boss read denser and more controllable.

## What is locked in (`0.5.2`)

| System | Location | Notes |
|--------|----------|--------|
| Material bank | `src/engine/gfx/texture_bank.zig` | 15 materials: asphalt, wet asphalt, sidewalk, cobble, brick, brick_dark, concrete, stucco, metal, foliage, water, roof_tar, dirt_alley, painted_line, glass — procedural 64² tiles with cracks/mortar/slabs |
| Surface grain | `src/engine/gfx/shaders.zig` | Multi-octave fBm + streak + soft specular hint |
| Character map | `src/game/character_map.zig` | 8 skills, needs (incl. vice), appearance (body/hair/face/suit/hat/tone/scar/jewelry), traits, social, era presets |
| Character UI | `src/engine/character_ui.zig` | **C** toggle — full sheet + derived speed/combat/stealth muls |
| World map | `src/engine/world_map.zig` | **M** toggle, WASD pan, Q/E + [ ] zoom, clamped pan, legend |
| Camera zoom/orbit | `src/engine/camera.zig` | **[ ]** zoom, Q/E orbit when map closed |
| Sprint | Shift | 1.45× move (input mapper) |
| Expanded cityscape | `src/engine/cityscape.zig` | More footprints, alleys, north band, east towers, lamps, jobs, parked cars |
| Collision | `src/game/collision.zig` | Matches cityscape extents |

## Controls

```
WASD / arrows     move
Shift             sprint
E                 interact
M                 city map (WASD pan, Q/E or [ ] zoom)
C                 character map
[ ]               camera zoom out / in
Q / E             camera orbit (when map closed)
Esc               empire pause menu
F5 / F9           save / load
```

## Locking real textures later (CC0 only)

1. Run `./tools/fetch_cc0_assets.sh` on a machine with network (Kenney + Poly Haven).
2. Place albedo PNGs under `assets/cc0/textures/` (asphalt, brick, concrete, sidewalk).
3. ResourceManager / texture upload path can replace procedural tiles when a matching file exists — API of `texture_bank` stays stable (`MaterialId` + `colorOf` / `generateTile`).
4. Log every binary in `assets/CREDITS.md`.

**No Rockstar / GTA assets** — only CC0 / procedural locked materials.

## Next toward “real streets”

1. Upload `texture_bank` tiles as real GL textures + UVs on ground/buildings  
2. Place Kenney/Poly Haven GLBs on cityscape footprints  
3. Character GLB + clothing slots driven by character map  
4. District heat/control from world position on the map overlay  
