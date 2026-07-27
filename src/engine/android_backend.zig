//! Android / mobile backend.
//!
//! Phase A (now): runs the full game loop with touch→key mapping.
//!   - On Termux (aarch64-linux): same as headless + optional stdin later.
//!   - When linked as libempire.so into a NativeActivity, host injects
//!     touch via empire_touch() and frames via empire_frame().
//!
//! Phase B (next): GLES context owned by Java/NativeActivity; this module
//!   only pumps game + draws via GLES renderer.

const std = @import("std");
const backend = @import("backend.zig");
const input = @import("input.zig");
const touch = @import("touch.zig");

var frame_count: u64 = 0;
var close_after: u64 = 0; // 0 = never auto-close (device)
var last_ns: i128 = 0;
var dt: f64 = 1.0 / 60.0;
var mapper: input.Mapper = .{};
var screen_w: u32 = 1280;
var screen_h: u32 = 720;
var use_touch: bool = true;

// Host can force keys (debug / Bluetooth keyboard on Android)
var host_raw: input.RawKeys = .{};
var host_raw_valid: bool = false;

fn initImpl(title: []const u8, width: u32, height: u32) !void {
    screen_w = if (width == 0) 1280 else width;
    screen_h = if (height == 0) 720 else height;
    frame_count = 0;
    mapper = .{};
    last_ns = std.time.nanoTimestamp();
    touch.clear();
    std.debug.print("[AndroidBackend] {s} {d}x{d} touch={}\n", .{ title, screen_w, screen_h, use_touch });
}

fn shutdownImpl() void {
    std.debug.print("[AndroidBackend] frames={d}\n", .{frame_count});
}

fn beginFrameImpl() void {
    frame_count += 1;
    const now = std.time.nanoTimestamp();
    const delta_ns = now - last_ns;
    last_ns = now;
    dt = @as(f64, @floatFromInt(delta_ns)) / 1e9;
    if (dt < 0 or dt > 0.25) dt = 1.0 / 60.0;
}

fn endFrameImpl() void {
    if (frame_count % 60 == 0) {
        std.debug.print("[AndroidBackend] t={d}s frame={d}\n", .{ frame_count / 60, frame_count });
    }
}

fn pollInputImpl() backend.InputState {
    return mapper.map(pollRawKeys());
}

pub fn pollRawKeys() input.RawKeys {
    if (host_raw_valid) {
        host_raw_valid = false;
        return host_raw;
    }
    if (use_touch) return touch.toRawKeys();
    return .{};
}

fn deltaTimeImpl() f64 {
    return dt;
}
fn shouldCloseImpl() bool {
    if (close_after == 0) return false;
    return frame_count >= close_after;
}

fn drawTextImpl(text: []const u8, x: i32, y: i32, color: backend.Color) void {
    _ = x;
    _ = y;
    _ = color;
    if (frame_count % 90 == 1) std.debug.print("[draw] {s}\n", .{text});
}
fn clearImpl(color: backend.Color) void {
    _ = color;
}
fn setCameraImpl(c: backend.Camera) void {
    _ = c;
}
fn drawGroundImpl(size: f32, color: backend.Color) void {
    _ = size;
    _ = color;
}
fn drawBoxImpl(pos: backend.Vec3, w: f32, h: f32, d: f32, color: backend.Color) void {
    _ = pos;
    _ = w;
    _ = h;
    _ = d;
    _ = color;
}
fn drawPlayerProxyImpl(pos: backend.Vec3, facing_yaw: f32, color: backend.Color) void {
    _ = pos;
    _ = facing_yaw;
    _ = color;
}

pub fn getBackend() backend.Backend {
    return .{ .vtable = .{
        .init = initImpl,
        .shutdown = shutdownImpl,
        .beginFrame = beginFrameImpl,
        .endFrame = endFrameImpl,
        .pollInput = pollInputImpl,
        .deltaTime = deltaTimeImpl,
        .shouldClose = shouldCloseImpl,
        .drawText = drawTextImpl,
        .clear = clearImpl,
        .setCamera = setCameraImpl,
        .drawGround = drawGroundImpl,
        .drawBox = drawBoxImpl,
        .drawPlayerProxy = drawPlayerProxyImpl,
    } };
}

// ─── C ABI for NativeActivity / JNI host ───────────────────────────

export fn empire_touch(x_norm: f32, y_norm: f32, down: u8) void {
    touch.setPointer(x_norm, y_norm, down != 0);
}

export fn empire_touch2(x_norm: f32, y_norm: f32, down: u8) void {
    touch.setPointer2(x_norm, y_norm, down != 0);
}

export fn empire_set_auto_close(frames: u64) void {
    close_after = frames;
}
