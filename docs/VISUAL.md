# Visual target vs reality

## Straight talk

**The Sims 4** is a decade of EA art, animation, CAS, routing, lighting, and UI polish.
Empire & Kin is a Zig alpha with **procedural boxes + bitmap font**. Playtests that only measure “does it look like Sims 4?” will always fail until we add a real art pipeline (meshes, textures, skinned characters, UI toolkit).

What we *can* hit in the near term is **life-sim readability**:

| Signal | Sims 4 | Empire & Kin (now) |
|--------|--------|--------------------|
| Camera | Elevated neighborhood | Elevated 3/4 follow |
| Sim | Full body mesh | Multi-part silhouette + plumbob cue |
| HUD | Portrait + needs + money | Clean panel: cash / heat / control / goal |
| World | Textured lots | Block city with fog + shadows |
| UI noise | Focused | Debug overlays **removed from default play** |

## Playability bar (this milestone)

1. You always know **where you are** (district + clock).  
2. You always know **what matters** (goal % + cash).  
3. You always know **what to press** (bottom prompt).  
4. Your character reads as a **person**, not a crate.  
5. The screen is not a wall of debug text.

## Next visual tiers (ordered)

1. **Larger type** (font scale 2.5+) — done this pass  
2. **Sim HUD only** — done this pass  
3. Articulated boss + ped silhouettes — done this pass  
4. Soft ground grid / lot boundaries  
5. Simple billboard icons for jobs (not cyan poles only)  
6. True mesh import (glTF) + materials  
7. Skinned walk cycle  
8. Proper UI toolkit (rects, nine-slice panels)

Until tier 6–8, comparisons to Sims 4 should be about **clarity and agency**, not screenshots.
