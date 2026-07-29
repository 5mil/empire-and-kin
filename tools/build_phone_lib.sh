#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"
: "${ANDROID_SDK_ROOT:=${ANDROID_HOME:-$HOME/Android/Sdk}}"
if [[ -z "${NDK:-}" ]]; then
  NDK=$(ls -d "$ANDROID_SDK_ROOT"/ndk/* 2>/dev/null | sort -V | tail -1 || true)
fi
if [[ -z "${NDK}" || ! -d "$NDK" ]]; then
  echo "Set NDK=/path/to/ndk"
  exit 1
fi
PREBUILT=$(ls -d "$NDK"/toolchains/llvm/prebuilt/* 2>/dev/null | head -1)
SYSROOT="$PREBUILT/sysroot"
API="${API:-24}"
OUT="$ROOT/android/app/src/main/jniLibs/arm64-v8a"
mkdir -p "$OUT"
echo "NDK=$NDK"
zig build android-lib -Dgles=true -Dandroid=true \
  -Dtarget=aarch64-linux-android \
  -Dndk_sysroot="$SYSROOT" \
  -Doptimize=ReleaseFast
cp -f zig-out/lib/libempire.so "$OUT/libempire.so"
CLANG="$PREBUILT/bin/clang"
if [[ -x "$CLANG" ]]; then
  "$CLANG" --target=aarch64-linux-android$API --sysroot="$SYSROOT" \
    -c -fPIC "$ROOT/android/native_app.c" -o /tmp/native_app.o \
    -I"$SYSROOT/usr/include" || true
  if [[ -f /tmp/native_app.o ]]; then
    "$CLANG" --target=aarch64-linux-android$API --sysroot="$SYSROOT" \
      -shared -fPIC /tmp/native_app.o -L"$OUT" -lempire \
      -llog -landroid -lEGL -lGLESv3 -Wl,-soname,libempire.so \
      -o "$OUT/libempire_app.so" || true
  fi
fi
ls -la "$OUT"
echo "Next: open android/ in Android Studio → Run on phone"
