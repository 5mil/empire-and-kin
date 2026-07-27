# Next step for PC + Android (`0.2.5-alpha`)

## Done this step

| Side | Deliverable |
|------|-------------|
| **Both** | Contact-shadow style dark plates under player / cars / beacons (scene) |
| **PC** | `-Dtouch=true` — mouse injects Android virtual pad; on-screen labels |
| **Android** | `android/native_app.c` — NativeActivity attach + multi-touch → `empire_touch` |

## PC commands

```bash
# Visual playtest (atmosphere + shadows)
zig build -Dtarget=x86_64-windows-gnu -Dgpu=true \
  -Dglfw_prefix=$GLFW_WIN -Doptimize=ReleaseFast

# Practice mobile controls on desktop
zig build -Dtarget=x86_64-windows-gnu -Dgpu=true -Dtouch=true \
  -Dglfw_prefix=$GLFW_WIN -Doptimize=ReleaseFast
```

LMB = primary finger (stick / zones). RMB = second finger (actions).

## Android commands

```bash
zig build run-android                    # scripted logic demo
zig build android-lib -Doptimize=ReleaseFast   # libempire.so
```

Wire `native_app.c` into the NDK shared object that Manifest loads as `libempire.so` (or a thin `libempire` that links Zig + this C file).

## Immediate follow-ups

1. **PC** — bake one PD ground/building texture (see `ART_SOURCES.md`)
2. **Android** — Gradle project that packages `jniLibs/arm64-v8a/libempire.so` + runs NativeActivity
3. **Both** — embed full `main` loop callable from `empire_android_main()` after attach
