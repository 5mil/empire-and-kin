# Android track — Empire & Kin

**Status:** Phase A at **PC NullBackend parity** (scripted demo + touch path).  
**Version:** `0.2.2-alpha`  
**Not yet:** GLES window inside an APK on a real phone (Phase B).

## Why not “just -Dgpu” on Android?

| Desktop | Android |
|---------|---------|
| GLFW window | **No GLFW** on Android |
| OpenGL 3.3 core | **OpenGL ES 3.0** |
| Keyboard | **Touch** (virtual stick) |
| `.exe` / ELF | **APK** + `libempire.so` + Activity |

Zig Android/bionic support is still incomplete upstream, so we stage carefully.

---

## Phase A — PC development test level (now)

Android backend matches **NullBackend** acceptance:

| Milestone | Frames (approx) |
|-----------|-----------------|
| New Game (`1`) | 5–6 |
| Confirm era (Enter) | 12–13 |
| Move (W+D / stick) | 20–55 |
| Start job (E) | 60–61 |
| Hints (H) | 70–71 |
| Pause peek | 90–101 |
| Quick-save (F5) | 120–121 |
| Secondary (F) | 140–141 |
| Move again | 150–180 |
| Auto-exit | 200 |

Also exercises **touch zones** (stick, E, pause, F5, F) every scripted step.

### Run (same machine as Windows GPU tests)

```bash
cd ~/empire-and-kin && git pull && rm -rf .zig-cache zig-out

# Windows GPU (unchanged)
export GLFW_WIN=$HOME/glfw-3.4.bin.WIN64
zig build -Dtarget=x86_64-windows-gnu -Dgpu=true \
  -Dglfw_prefix=$GLFW_WIN -Doptimize=ReleaseFast

# Android Phase A — PC-parity demo (~200 frames @ 30 Hz)
zig build run-android
```

Expect:

```
[AndroidBackend] Empire & Kin 1280x720 touch_path=true close_after=200
[AndroidBackend] PC-parity demo: boot→era→move→job→save
--- android frame 40 pos=(...) boxes=... ---
[draw] ...
[AndroidBackend] === DEMO SUMMARY ===
```

### Shared library

```bash
zig build android-lib -Doptimize=ReleaseFast
# Prefer Linux host for .so:
zig build android-lib -Dtarget=aarch64-linux -Doptimize=ReleaseFast
```

Exports: `empire_touch`, `empire_touch2`, `empire_abi_version`, …

### Termux (ARM smoke, still no GLES UI)

```bash
zig build run-android
```

---

## Phase B — real on-device graphics

1. Android NDK + `aarch64-linux-android` + sysroot (`-Dndk_sysroot=…`)
2. NativeActivity / GameActivity → EGL + GLES3
3. `shaders_es.zig` when `enable_android`
4. Load `libempire.so`, feed `empire_touch`
5. Gradle APK (`android/` scaffold)

---

## Simultaneous iteration

| Each push | Windows GPU | Android backend |
|-----------|-------------|-----------------|
| Feature | `-Dgpu=true` → playtest | `zig build run-android` |
| Touch mapping | optional `-Dtouch=true` | primary |

```bash
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

---

## Files

| Path | Role |
|------|------|
| `src/engine/touch.zig` | Virtual pad → `RawKeys` |
| `src/engine/android_backend.zig` | Mobile backend (PC-parity demo) |
| `src/engine/gfx/shaders_es.zig` | GLES 3.0 shaders |
| `src/android_lib.zig` | `libempire.so` exports |
| `android/` | Manifest + README scaffold |
| `build.zig` | `-Dandroid`, `run-android`, `android-lib` |
