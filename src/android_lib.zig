//! Shared library entry for packaging into an Android APK.
//! NativeActivity / JNI host loads libempire.so and calls these symbols.
//!
//! Full GLES window is owned by the Java/NativeActivity side in Phase B.
//! Phase A exports touch injection + a thin "tick once" API for hosts that
//! run the game loop themselves.

const android_backend = @import("engine/android_backend.zig");
const touch = @import("engine/touch.zig");

/// Required so the .so is not empty / stripped of exports.
export fn empire_abi_version() u32 {
    return 1;
}

export fn empire_touch(x_norm: f32, y_norm: f32, down: u8) void {
    touch.setPointer(x_norm, y_norm, down != 0);
}

export fn empire_touch2(x_norm: f32, y_norm: f32, down: u8) void {
    touch.setPointer2(x_norm, y_norm, down != 0);
}

export fn empire_touch_clear() void {
    touch.clear();
}

/// Placeholder frame counter for hosts that only want a heartbeat.
var host_frames: u64 = 0;
export fn empire_host_frame() u64 {
    host_frames +%= 1;
    return host_frames;
}

// Re-export backend factory for hosts that embed the full loop later.
export fn empire_backend_ready() u8 {
    _ = android_backend.getBackend();
    return 1;
}
