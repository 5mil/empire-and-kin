# Empire & Kin — Handover

**Version:** `0.1.8-alpha`  
**Repo:** https://github.com/5mil/empire-and-kin

## Current playable surface

- 5 jobs (incl. hit) + payout choice  
- 20+ street contacts via `interact.zig` (see `docs/MAP.md`)  
- Ambush, patrol car, radio, turf, weather, news, banter  
- HUD: district, HP, threat, morale, loan, rep, stash, clock, zone, score  
- Milestones, day reputation drift, expanded save  
- Scene: trees, 5 beacons, denser props  

## Modules ready / partial

Death/hospital, recruit, intimidate, protection_run, heat_spike, gameover UI, zone UI  

## Build

```bash
cd ~/empire-and-kin && git pull && rm -rf .zig-cache zig-out
export GLFW_WIN=$HOME/glfw-3.4.bin.WIN64
zig build -Dtarget=x86_64-windows-gnu -Dgpu=true \
  -Dglfw_prefix=$GLFW_WIN -Doptimize=ReleaseFast
```

**Next:** paste compile errors → fix pass; then wire death/recruit into main loop.

**End of handover.**
