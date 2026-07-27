# Android APK scaffold (Phase B)

This folder will hold the Java/Kotlin + Gradle shell that:

1. Creates an Activity / NativeActivity  
2. Sets up EGL + OpenGL ES 3.0  
3. Loads `libempire.so` from `jniLibs/arm64-v8a/`  
4. Forwards MotionEvents to `empire_touch(x, y, down)`

## Copy lib after Zig build

```bash
# From repo root (Linux/WSL)
zig build android-lib -Dtarget=aarch64-linux -Doptimize=ReleaseFast
mkdir -p android/app/src/main/jniLibs/arm64-v8a
cp zig-out/lib/libempire.so android/app/src/main/jniLibs/arm64-v8a/
```

> Note: a true `aarch64-linux-android` NDK triple is preferred once NDK sysroot is configured (`-Dndk_sysroot=...`). Plain `aarch64-linux` is for Termux / early linking experiments.

## Manifest stub

See `AndroidManifest.xml` — internet not required; portrait optional; NativeActivity name TBD.

## Status

Gradle project not generated yet. Phase A validates game + touch without APK.
