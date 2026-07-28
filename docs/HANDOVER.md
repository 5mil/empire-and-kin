# Empire & Kin — Handover

**Version:** `0.3.0-alpha`  
**Focus:** Life-sim **readability** (not Sims 4 fidelity — see `docs/VISUAL.md`).

## What changed this pass

- Elevated **3/4 camera** (neighborhood dollhouse angle)
- **Multi-part boss** silhouette + green plumbob cue
- **Clean HUD**: district, cash, health/heat/control, goal % — no debug wall
- **Larger font** (scale 2.75)
- Softer sky/ground; greener job markers
- Centered title screen

## Build (Windows GPU)

```bash
cd ~/empire-and-kin && git pull && rm -rf .zig-cache zig-out
export GLFW_WIN=$HOME/glfw-3.4.bin.WIN64
zig build -Dtarget=x86_64-windows-gnu -Dgpu=true \
  -Dglfw_prefix=$GLFW_WIN -Doptimize=ReleaseFast
```

## Playtest checklist

1. Can you tell who you are? (green diamond over boss)  
2. Can you read cash + goal without hunting?  
3. Does the camera feel like looking down at a block?  
4. Is the screen *not* covered in overlapping text?

If those pass, playtests are useful again.
