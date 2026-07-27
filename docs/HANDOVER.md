# Empire & Kin — Handover

**Version:** `0.2.0-alpha`  
**Repo:** https://github.com/5mil/empire-and-kin

## New this stretch

- **Hell's Kitchen** scenery (east of Little Italy, x≈40–52)  
- **District gates** at x≈30 / -1 / 42 — `[E]` warps between LI ↔ HK / LES  
- Expanded collision + world bounds  
- Gate arches in scene; travel via `interact.tryTravel`  

## Build

```bash
cd ~/empire-and-kin && git pull && rm -rf .zig-cache zig-out
export GLFW_WIN=$HOME/glfw-3.4.bin.WIN64
zig build -Dtarget=x86_64-windows-gnu -Dgpu=true \
  -Dglfw_prefix=$GLFW_WIN -Doptimize=ReleaseFast
```

Walk east to the arch (~30, 20) and press **E** to enter Hell's Kitchen.

**End of handover.**
