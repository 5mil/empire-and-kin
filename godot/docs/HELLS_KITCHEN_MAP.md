# Hell’s Kitchen — map rules

## Real geography

| Item | Value |
|------|--------|
| Center (approx) | 40.7638 N, 73.9918 W |
| Corridor | 8th–12th Ave, ~34th–59th St |
| Play slice (v0) | Compressed 3 avenues × 4 cross streets |

## Street logic (NYC)

- **Avenues** run roughly **north–south**
- **Streets** run roughly **east–west**
- Road ~12 m, sidewalk ~3.5 m (play scale)
- Block spacing compressed vs real (~55 m ave, ~45 m street) so a few blocks fit a session

## In-engine

`scripts/districts/hells_kitchen_block.gd` builds this grid at runtime.
Default district id: `hells_kitchen` (BETA + GameState).

## Next (OSM)

1. Export a small bbox from OpenStreetMap (Overpass / JOSM)
2. Keep **highway** + **building** footprints only
3. Convert to Godot mesh/colliders (e.g. simplified extrusion)
4. Replace procedural grid with authored scene `scenes/districts/hells_kitchen.tscn`
5. CC0 façade textures / Kenney-style kits on extrusions

**License:** OSM data ODbL — use footprint geometry carefully; art stays CC0.
