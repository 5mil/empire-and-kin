# Empire & Kin — Handover

**Version:** `0.1.6-alpha`  
**Repo:** https://github.com/5mil/empire-and-kin

## Street contacts (E)

Fence · Stash · Doc · Numbers · Bartender · Vendor · Phone · Paper · Church · Dock · Gamble · Informant · Warehouse · Arcade · Taxi · Safehouse

## Systems

- Interact hub: `src/engine/interact.zig`
- Ambush, patrol car, radio, turf pressure
- Threat / morale / loan / score HUD
- Expanded save (goal, stash, rep)

## Empire menu

- Crew 1 loan · 2 tip · 3 turf · 5 lookout  
- Rackets R collect · F upgrade $800

## Build

```bash
git pull && rm -rf .zig-cache zig-out
export GLFW_WIN=$HOME/glfw-3.4.bin.WIN64
zig build -Dtarget=x86_64-windows-gnu -Dgpu=true \
  -Dglfw_prefix=$GLFW_WIN -Doptimize=ReleaseFast
```

**End of handover.**
