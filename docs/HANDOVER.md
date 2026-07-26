# Empire & Kin — Handover

**Version:** `0.1.9-alpha`  
**Repo:** https://github.com/5mil/empire-and-kin

## Wired this stretch

- Recruit corner (15,20) via interact + crew names  
- Hospital when HP = 0 (`[E]` $400)  
- Zone name + heat spike + weekly payday  
- Safehouse `[F]` empty stash  
- Crew menu 3 → intimidate (else turf)  
- Full contact map (see `docs/MAP.md`)

## Build

```bash
cd ~/empire-and-kin && git pull && rm -rf .zig-cache zig-out
export GLFW_WIN=$HOME/glfw-3.4.bin.WIN64
zig build -Dtarget=x86_64-windows-gnu -Dgpu=true \
  -Dglfw_prefix=$GLFW_WIN -Doptimize=ReleaseFast
```

Paste compile errors for a fix pass.

**End of handover.**
