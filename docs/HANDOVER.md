# Empire & Kin — Handover

**Version:** `0.3.1-alpha`  
**Focus:** Maximum **Sims-like readability** on PC + Android GLES path — **not** Sims 4 screenshot parity.

## Honest scope

True Sims 4 fidelity needs meshes, textures, skinned animation, CAS, and a UI toolkit.  
This build is the ceiling for **procedural boxes + bitmap font** on both backends.

## What landed (`0.3.1`)

- Articulated boss (legs, torso, arms, head, eyes, plumbob stack)
- Ped variants + contact shadows
- Needs-style bars: Health / Calm / Control + aspiration progress
- Soft **lot grid** on ground
- Elevated 3/4 camera (unchanged path)
- Shared scene/HUD/renderer → PC GL and Android GLES both benefit

## Build (Windows GPU)

```bash
cd ~/empire-and-kin && git pull && rm -rf .zig-cache zig-out
export GLFW_WIN=$HOME/glfw-3.4.bin.WIN64
zig build -Dtarget=x86_64-windows-gnu -Dgpu=true \
  -Dglfw_prefix=$GLFW_WIN -Doptimize=ReleaseFast
```

## Android

```bash
zig build run-android
zig build android-lib -Doptimize=ReleaseFast
```

## Test scoring guide

Score **clarity**, not EA comparison:

1. Can you spot the boss (green plumbob)?  
2. Can you read cash + needs bars?  
3. Does the block feel like lots, not empty void?  
4. Is the HUD free of debug spam?

See `docs/VISUAL.md` for the full gap list toward real fidelity.
