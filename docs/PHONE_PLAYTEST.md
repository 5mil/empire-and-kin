# Real-phone playtest — Empire & Kin

**Goal:** install a debug APK on a physical arm64 Android phone and see GLES + touch.

## Prerequisites

| Tool | Notes |
|------|--------|
| Phone | arm64 (arm64-v8a), Android 7+ (API 24+), **OpenGL ES 3.0** |
| USB debugging | Developer options → USB debugging ON |
| `adb` | From Android SDK platform-tools |
| Android NDK | r26+ (for `libempire.so` + optional C glue) |
| Zig | Same version as the repo |
| Android Studio **or** command-line SDK + Gradle | To package the APK |

## 1. Connect the phone

```bash
adb devices
# accept the RSA prompt on the phone
```

## 2. Build native library (from repo root)

```bash
git pull
export ANDROID_SDK_ROOT=$HOME/Android/Sdk
export NDK=$ANDROID_SDK_ROOT/ndk/27.0.12077973   # your version
./tools/build_phone_lib.sh
```

Or manually:

```bash
export SYSROOT=$NDK/toolchains/llvm/prebuilt/linux-x86_64/sysroot
zig build android-lib -Dgles=true -Dandroid=true \
  -Dtarget=aarch64-linux-android \
  -Dndk_sysroot=$SYSROOT \
  -Doptimize=ReleaseFast
mkdir -p android/app/src/main/jniLibs/arm64-v8a
cp zig-out/lib/libempire.so android/app/src/main/jniLibs/arm64-v8a/
```

Link `android/native_app.c` so `ANativeActivity_onCreate` exists in the loaded library (see script).

## 3. Build & install APK

**Android Studio:** Open the `android/` folder → Run on phone.

**CLI:**
```bash
cd android && ./gradlew :app:assembleDebug
adb install -r app/build/outputs/apk/debug/app-debug.apk
adb shell am start -n com.fivemil.empireandkin/android.app.NativeActivity
```

## 4. logcat

```bash
adb logcat -s EmpireKin:* GLESBackend:* EGL:* AndroidRuntime:E
```

Want: `ANativeActivity_onCreate` then `GLES attached WxH abi=3`.

## 5. Known limits

- First APK validates **window + EGL + GLES + touch inject**.
- Full `main.zig` sim on device is next after attach works on your phone.
- arm64-v8a only for this pass.
