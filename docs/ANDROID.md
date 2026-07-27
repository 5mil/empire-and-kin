# Android track — Empire & Kin

**Status:** Phase A scaffold (touch backend + shared lib + GLES shaders).  
**Not yet:** GLES window inside an APK on a real phone (Phase B).

## Why not “just -Dgpu” on Android?

| Desktop | Android |
|---------|---------|
| GLFW window | **No GLFW** on Android |
| OpenGL 3.3 core | **OpenGL ES 3.0** |
| Keyboard | **Touch** (virtual stick) |
| `.exe` / ELF | **APK** + `libempire.so` + Activity |

Zig 0.16 Android/bionic support is still incomplete upstream, so we stage carefully.

---

## Phase A — what you can run **today**

### 1) Android backend on your WSL/PC (no phone needed)

Same game logic, touch→key mapping, no GPU window:

```bash
cd ~/empire-and-kin && git pull && rm -rf .zig-cache zig-out
zig build run-android
```

Exits after ~300 frames. Logs `[AndroidBackend]` + `[draw]` lines.

### 2) Explicit `-Dandroid=true`

```bash
zig build -Dandroid=true -Doptimize=ReleaseFast
# → zig-out/bin/empire  (android backend selected)
```

### 3) Shared library for future APK

```bash
zig build android-lib -Doptimize=ReleaseFast
# → zig-out/lib/libempire.so   (or .dll on Windows host — prefer Linux)
```

On Linux / WSL:

```bash
zig build android-lib -Dtarget=aarch64-linux -Doptimize=ReleaseFast
```

Exports: `empire_touch`, `empire_touch2`, `empire_abi_version`, …

### 4) Termux on a phone (game logic smoke-test)

If you install [Termux](https://termux.dev) + Zig on the device:

```bash
# inside Termux
git clone https://github.com/5mil/empire-and-kin.git
cd empire-and-kin
zig build run-android
```

This validates simulation + touch mapping on ARM. **Still no GLES window.**

### 5) Desktop GPU + touch overlay (practice virtual pad)

```bash
zig build run -Dgpu=true -Dtouch=true
```

(Overlay labels only until mouse→touch injection is wired in gl_backend.)

---

## Phase B — real on-device graphics (next work)

1. Android NDK + `aarch64-linux-android` target + sysroot (`-Dndk_sysroot=…`)
2. NativeActivity (or GameActivity) hosts EGL + GLES3 context
3. Swap `shaders.zig` → `shaders_es.zig` when `enable_android`
4. Load `libempire.so`, feed touch via `empire_touch(x,y,down)`
5. Package APK with Gradle (see `android/` scaffold)

Reference templates: [ZigAndroidTemplate](https://github.com/MasterQ32/ZigAndroidTemplate), zero-graphics.

---

## Simultaneous iteration workflow

| Each push | Windows GPU | Android backend |
|-----------|-------------|-----------------|
| Feature / scenery / agency | `zig build … -Dgpu=true` → `empire.exe` | `zig build run-android` |
| Touch mapping changes | optional `-Dtouch=true` | primary |
| GLES shaders | desktop 330 | `shaders_es.zig` ready |

**Recommended per iteration:**

```bash
# Windows (existing)
zig build -Dtarget=x86_64-windows-gnu -Dgpu=true \
  -Dglfw_prefix=$GLFW_WIN -Doptimize=ReleaseFast

# Android track (logic)
zig build run-android -Doptimize=ReleaseFast
```

---

## Touch layout (normalized 0..1)

```
[1] [2]              [OK]
[F5]


 STICK          [R] [||]
 (left)         [E] [F]
```

- Stick: bottom-left → WASD / stick axes  
- E / F / R / pause: bottom-right  

---

## Files added

| Path | Role |
|------|------|
| `src/engine/touch.zig` | Virtual pad → `RawKeys` |
| `src/engine/android_backend.zig` | Mobile backend |
| `src/engine/gfx/shaders_es.zig` | GLES 3.0 shaders |
| `src/android_lib.zig` | `libempire.so` exports |
| `android/` | Manifest + README scaffold |
| `build.zig` | `-Dandroid`, `run-android`, `android-lib` |
