//! Shared library entry for packaging into an Android APK.
//! NativeActivity / JNI host loads libempire.so and calls these symbols.
//!
//! Phase B: host creates ANativeWindow, calls empire_gles_attach, then
//! either runs its own loop calling empire_frame, or embeds main later.

const android_backend = @import("engine/android_backend.zig");
const gles_backend = @import("engine/gles_backend.zig");
const touch = @import("engine/touch.zig");

export fn empire_abi_version() u32 {
    return 2;
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

var host_frames: u64 = 0;
export fn empire_host_frame() u64 {
    host_frames +%= 1;
    return host_frames;
}

/// Attach GLES to an ANativeWindow* from NativeActivity.
/// width/height may be 0 — EGL will query the surface.
export fn empire_gles_attach(window: ?*anyopaque, width: u32, height: u32) u8 {
    gles_backend.attachNativeWindow(window, width, height) catch return 0;
    return 1;
}

export fn empire_gles_detach() void {
    gles_backend.detach();
}

export fn empire_gles_request_close() void {
    gles_backend.requestClose();
}

export fn empire_backend_ready() u8 {
    _ = android_backend.getBackend();
    return 1;
}

export fn empire_gles_backend_ready() u8 {
    _ = gles_backend.getBackend();
    return 1;
}
