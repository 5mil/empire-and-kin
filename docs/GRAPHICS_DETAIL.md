# Graphics detail path (`0.5.1`)

## Honest scope vs GTA 4

**GTA 4** ships years of hand-authored city meshes, high-res textures, animation graphs, physics, and a full map stack.  
Empire & Kin **cannot** match that in one sprint. This release locks **material identity + character map + map controls** into the codebase so the city and boss read denser and more controllable.

## What is locked in

| System | Location | Notes |
|--------|----------|--------|
| Material bank | `src/engine/gfx/texture_bank.zig` | Asphalt, sidewalk, brick, concrete, stucco, metal, foliage… procedural 64² tiles |
| Surface grain | `src/engine/gfx/shaders.zig` | World-space noise on lit surfaces |
| Character map | `src/game/character_map.zig` | Skills, needs, appearance, reputation |
| Character UI | `src/engine/character_ui.zig` | **C** toggle |
| World map | `src/engine/world_map.zig` | **M** toggle, Q/E zoom, WASD pan |
| Camera zoom/orbit | `src/engine/camera.zig` | **[ ]** zoom, Q/E orbit when not in map |
| Sprint | Shift | 1.45× move |
| Expanded collision | `src/game/collision.zig` | Matches cityscape extents |

## Controls

```
WASD / arrows     move
Shift             sprint
E                 interact
M                 city map (pan WASD, Q/E zoom)
C                 character map
[ ]               camera zoom out / in
Q / E             camera orbit (when map closed)
Esc               empire pause menu
F5 / F9           save / load
```

## Next toward “real streets”

1. Upload `texture_bank` tiles as real GL textures + UV on ground/buildings  
2. Place Kenney/Poly Haven GLBs on cityscape footprints  
3. Character GLB + clothing slots driven by character map  
4. District heat/control from world position  

**No Rockstar / GTA assets** — only CC0 / procedural locked materials.
