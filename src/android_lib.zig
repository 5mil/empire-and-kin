//! Shared library for Android APK. NativeActivity loads libempire.so.
const std = @import("std");
const android_backend = @import("engine/android_backend.zig");
const gles_backend = @import("engine/gles_backend.zig");
const touch = @import("engine/touch.zig");
const backend = @import("engine/backend.zig");

export fn empire_abi_version() u32 {
    return 3;
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

/// Device smoke frame — sky + ground + boxes until full main is embedded.
export fn empire_frame() void {
    host_frames +%= 1;
    const gfx = gles_backend.getBackend();
    gfx.beginFrame();
    const t = @as(f32, @floatFromInt(host_frames % 600)) / 600.0;
    const sky = backend.Color.rgb(
        @intFromFloat(40.0 + 30.0 * t),
        @intFromFloat(70.0 + 40.0 * t),
        @intFromFloat(110.0 + 20.0 * t),
    );
    gfx.clear(sky);
    gfx.setCamera(.{
        .position = .{ .x = 12, .y = 18, .z = 2 },
        .target = .{ .x = 12, .y = 1, .z = 20 },
        .up = .{ .x = 0, .y = 1, .z = 0 },
        .fov_deg = 48,
    });
    gfx.drawGround(200.0, backend.Color.rgb(55, 52, 48));
    gfx.drawBox(.{ .x = 5, .y = 3, .z = 18 }, 4, 6, 4, backend.Color.rgb(90, 70, 60));
    gfx.drawBox(.{ .x = 14, .y = 4, .z = 22 }, 5, 8, 4, backend.Color.rgb(70, 75, 85));
    gfx.drawBox(.{ .x = 22, .y = 2.5, .z = 16 }, 4, 5, 4, backend.Color.rgb(85, 65, 55));
    gfx.drawPlayerProxy(.{ .x = 12, .y = 1, .z = 20 }, 0.3, backend.Color.rgb(200, 180, 60));
    gfx.drawText("EMPIRE & KIN", 40, 40, backend.Color.rgb(220, 200, 140));
    gfx.drawText("device smoke — touch L stick / R buttons", 40, 64, backend.Color.rgb(160, 160, 150));
    gfx.endFrame();
}

export fn empire_set_device_mode() void {
    android_backend.setAutoClose(0);
    android_backend.setUseTouchPath(true);
}
