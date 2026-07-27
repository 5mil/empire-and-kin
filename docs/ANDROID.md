# Android track — Empire & Kin

**Status:** Phase B graphics path landed (`0.2.3-alpha`).  
**Headless demo:** still `zig build run-android` (PC-parity scripted).  
**On-device GLES:** EGL + GLES 3.0 + same renderer as PC (ES shaders).

## Visual parity map

| Feature | PC (`-Dgpu`) | Android GLES (`-Dgles`) |
|---------|--------------|-------------------------|
| Window | GLFW | ANativeWindow + EGL |
| API | OpenGL 3.3 core | OpenGL ES 3.0 |
| Shaders | `shaders.zig` (#330) | `shaders_es.zig` (#300 es) |
| Meshes / camera / light | `renderer.zig` | same |
| HUD text | bitmap font | same |
| Input | keyboard | touch → `RawKeys` |

## Phase A — no phone needed

```bash
zig build run-android
```

Scripted demo ~200 frames (boot → era → move → job → save).

## Phase B — real graphics on device

### Native library

```bash
# Prefer NDK triple when available:
zig build android-lib -Dgles=true -Dandroid=true \
  -Dtarget=aarch64-linux-android \
  -Dndk_sysroot=$NDK/toolchains/llvm/prebuilt/linux-x86_64/sysroot \
  -Doptimize=ReleaseFast
```

Copy into APK:

```bash
mkdir -p android/app/src/main/jniLibs/arm64-v8a
cp zig-out/lib/libempire.so android/app/src/main/jniLibs/arm64-v8a/
```

### Host contract (Java / NativeActivity)

1. Create Activity with native window  
2. `empire_gles_attach(ANativeWindow*, w, h)` → EGL + GLES3 + renderer init  
3. Each frame: feed `empire_touch` / `empire_touch2`, run game loop (or embed `main`)  
4. On destroy: `empire_gles_detach()`

Exports (`empire_abi_version` = 2):

| Symbol | Role |
|--------|------|
| `empire_gles_attach` | Window → EGL/GLES + renderer |
| `empire_gles_detach` | Teardown |
| `empire_touch` / `touch2` | Normalized 0..1 pointers |
| `empire_gles_request_close` | Signal exit |

### Gradle shell

See `android/README.md` — Manifest stub present; full Gradle project is next packaging step.

## Simultaneous PC + Android workflow

```bash
# Windows GPU playtest
zig build -Dtarget=x86_64-windows-gnu -Dgpu=true \
  -Dglfw_prefix=$GLFW_WIN -Doptimize=ReleaseFast

# Android logic (no window)
zig build run-android

# Android GLES .so for APK (needs NDK)
zig build android-lib -Dgles=true -Dandroid=true -Doptimize=ReleaseFast
```

## Files

| Path | Role |
|------|------|
| `src/engine/gles_backend.zig` | Backend vtable — same draws as GLBackend |
| `src/engine/gfx/egl_android.zig` | EGL context from ANativeWindow |
| `src/engine/gfx/shaders_es.zig` | GLSL ES 3.0 |
| `src/engine/gfx/shader_select.zig` | 330 vs 300 es |
| `src/engine/gfx/renderer.zig` | Shared lit + font path |
| `src/android_lib.zig` | `libempire.so` exports |
| `src/engine/android_backend.zig` | Headless/touch demo |
