# Phase 8 — Graphics engine lift (`0.7.1-alpha`)

Not Sims 4 / GTA 4 parity. This pass makes the **existing lit engine** read as a city at night instead of flat boxes.

## Shipped

| Piece | Change |
|-------|--------|
| `shaders.zig` / `shaders_es.zig` | 4 inverse-square **street lamps** + **window panes** that light more when ambient is low |
| Material tiles | still 64² in bank (safe); lamps/windows are the visual jump |
| Day/night | already in `Renderer.beginFrame` from clear-color luminance |

Walk the avenue at dusk/night (in-game clock). Facades should show a grid of warm windows. Ground near (6,18) and (22,22) should pool amber light.

## Still not in-engine

- Shadow maps
- PBR metal/rough maps from Poly Haven files
- Skinned GPU palette
- Cascaded fog volumes

Those need asset files or a bigger renderer rewrite. Lamps + windows are the cheap half of "looks like a city."
