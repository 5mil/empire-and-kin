# Empire & Kin — Handover

**Version:** `0.1.7-alpha`  
**Steps complete:** ~200 design/implementation pushes on this track  
**Repo:** https://github.com/5mil/empire-and-kin

## What exists

- Playable GPU Windows path (ReleaseFast recommended)
- Dense agency: interact hub + 15+ street contacts + jobs + empire
- Ambush, patrol car, radio, turf, weather, news, banter
- HUD stack: district, HP, threat, morale, loan, score, compass, minimap
- Expanded save: goal tier, stash, reputation
- Modules ready but not all hooked: bakery, barber, laundry, perfume, cigar, post, skirmish, milestones, difficulty

## First action when you return

```bash
cd ~/empire-and-kin && git pull && rm -rf .zig-cache zig-out
export GLFW_WIN=$HOME/glfw-3.4.bin.WIN64
zig build -Dtarget=x86_64-windows-gnu -Dgpu=true \
  -Dglfw_prefix=$GLFW_WIN -Doptimize=ReleaseFast
```

Paste compile errors → fix pass. Then playtest the contact map (`docs/MAP.md`).

## Next product priorities

1. Compile-fix  
2. Hook remaining shops into `interact.zig`  
3. Second district scenery  
4. Visual pass (textures / font)

**End of handover (step 200).**
