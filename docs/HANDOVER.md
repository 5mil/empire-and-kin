# Empire & Kin — Handover

**Version:** `0.2.1-alpha`  
**Repo:** https://github.com/5mil/empire-and-kin

## Platforms

| Track | Command | Status |
|-------|---------|--------|
| **Windows GPU** | `zig build -Dtarget=x86_64-windows-gnu -Dgpu=true -Dglfw_prefix=$GLFW_WIN -Doptimize=ReleaseFast` | Primary playtest |
| **Headless** | `zig build run-headless` | CI / logic |
| **Android Phase A** | `zig build run-android` | Touch backend, no GLES window yet |
| **Android lib** | `zig build android-lib` | `libempire.so` exports |

See **docs/ANDROID.md** for the full mobile plan.

## Windows GPU (unchanged)

```bash
cd ~/empire-and-kin && git pull && rm -rf .zig-cache zig-out
export GLFW_WIN=$HOME/glfw-3.4.bin.WIN64
zig build -Dtarget=x86_64-windows-gnu -Dgpu=true \
  -Dglfw_prefix=$GLFW_WIN -Doptimize=ReleaseFast
```

## Android Phase A (same machine)

```bash
zig build run-android
```

**End of handover.**
