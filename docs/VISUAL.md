# Visual target vs reality

## Straight talk (read before the next test)

**The Sims 4** is not a visual bar we can clear with procedural boxes before a playtest.
It is a decade of character art, animation, CAS, routing, lighting, UI, and audio.

**Empire & Kin `0.3.1-alpha`** is the **highest Sims-*like* fidelity this stack can offer without meshes/textures**:

| Layer | Sims 4 | Empire & Kin now |
|-------|--------|------------------|
| Camera | Elevated neighborhood | Elevated 3/4 follow (shared PC + GLES) |
| Selected Sim | Mesh + plumbob | Multi-part boss + stacked green plumbob |
| Other Sims | Full bodies | Variant ped silhouettes |
| Needs | Icon bars | Text needs bars (Health / Calm / Control) |
| Aspiration | Career/want panel | Goal card + progress bars |
| World | Textured lots | Block city + fog + contact shadows + lot grid |
| UI chrome | Nine-slice panels | Bitmap font cards (no image atlas yet) |
| Animation | Walk cycles | Static poses |
| Materials | PBR textures | Vertex color + fog/rim |

If the test scores only “looks like Sims 4 screenshots,” it will fail.
If it scores **can I read my Sim, my money, my goal, and the block**, `0.3.1` is the bar.

## What would true fidelity require (post-test roadmap)

1. glTF character + building import  
2. Texture atlas (PD sources in `docs/ART_SOURCES.md`)  
3. Skinned walk / idle  
4. Real UI toolkit (rects, nine-slice, icons)  
5. Android APK host with same GLES path  

Until then: **clarity and agency**, not screenshot parity.
