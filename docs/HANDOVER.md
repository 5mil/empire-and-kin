# Empire & Kin — Handover

**Version:** `0.1.2-alpha`  
**Repo:** https://github.com/5mil/empire-and-kin  
**Zig:** 0.16 · **GPU:** GLFW + OpenGL 3.3

---

## Status

| Area | Status |
|------|--------|
| Alpha A1–A10 sim | Complete |
| GPU Windows cross-compile | Working (ReleaseFast) |
| Bitmap font HUD | Working |
| Rich street scenery | Little Italy block |
| Peds + traffic | Ambient |
| Job choice / safehouse / bribe | Working |
| Tiered goals | Working |
| Heat decay | Working |
| Expanded save (full graph) | Not yet |
| Textures / audio | Not yet |

---

## Agency loop

1. Walk to cyan job pole → **E** → stay in radius  
2. On finish: **[1]** keep take or **[2]** tithe crew  
3. Green door safehouse: **E** heal, **R** bribe ($500)  
4. **Esc** empire: **R** collect, **F** upgrade racket ($800)  
5. Goal tiers: control + treasury → next tier  

---

## Key modules

```
src/game/collision.zig  heat.zig  goals.zig  peds.zig  traffic.zig
src/engine/scene.zig    choice.zig  feed.zig  panel.zig  hud.zig
```

---

## Build (Windows from WSL)

```bash
export GLFW_WIN=$HOME/glfw-3.4.bin.WIN64
zig build -Dtarget=x86_64-windows-gnu -Dgpu=true \
  -Dglfw_prefix=$GLFW_WIN -Doptimize=ReleaseFast
```

Prefer **ReleaseFast** for playtests.

---

## Next priorities

1. C1 expanded save (rackets, fleet, jobs, goal tier)  
2. Texture/font atlas  
3. Debug-mode overflow fixes  
4. Second district block  

**End of handover.**
