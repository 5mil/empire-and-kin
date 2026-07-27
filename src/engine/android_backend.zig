//! Android / mobile backend.
//!
//! Phase A: full game loop parity with NullBackend PC dev tests.
//!   - Fixed 30 Hz dt (deterministic like NullBackend)
//!   - Scripted acceptance demo (boot → era → move → job → save)
//!   - Touch path exercised via normalized pointer injection
//!   - Richer [draw] / position telemetry
//!
//! Test: zig build run-android
//! Device (Termux): zig build -Dandroid=true -Dtarget=aarch64-linux
//!
//! Phase B: GLES from NativeActivity; this module still pumps game + touch.

const std = @import("std");
const backend = @import("backend.zig");
const input = @import("input.zig");
const touch = @import("touch.zig");

var frame_count: u64 = 0;
/// Match NullBackend default (~200 frames). 0 = run forever (device/host).
var close_after: u64 = 200;
var last_ns: i128 = 0;
var dt: f64 = 1.0 / 30.0;
var mapper: input.Mapper = .{};
var screen_w: u32 = 1280;
var screen_h: u32 = 720;
var use_touch_path: bool = true;

var host_raw: input.RawKeys = .{};
var host_raw_valid: bool = false;

var cam: backend.Camera = .{};
var player_x: f32 = 0;
var player_z: f32 = 0;
var ground_drawn: bool = false;
var boxes_this_frame: u32 = 0;
var text_lines_logged: u32 = 0;

fn initImpl(title: []const u8, width: u32, height: u32) !void {
    screen_w = if (width == 0) 1280 else width;
    screen_h = if (height == 0) 720 else height;
    frame_count = 0;
    mapper = .{};
    last_ns = std.time.nanoTimestamp();
    touch.clear();
    ground_drawn = false;
    boxes_this_frame = 0;
    text_lines_logged = 0;
    std.debug.print("[AndroidBackend] {s} {d}x{d} touch_path={} close_after={d}\n", .{
        title,
        screen_w,
        screen_h,
        use_touch_path,
        close_after,
    });
    std.debug.print("[AndroidBackend] PC-parity demo: boot→era→move→job→save\n", .{});
}

fn shutdownImpl() void {
    std.debug.print("[AndroidBackend] === DEMO SUMMARY ===\n", .{});
    std.debug.print("[AndroidBackend] frames={d} player=({d:.1},{d:.1}) ground={}\n", .{
        frame_count,
        player_x,
        player_z,
        ground_drawn,
    });
    std.debug.print("[AndroidBackend] text_lines_seen≈{d} (sampled)\n", .{text_lines_logged});
}

fn beginFrameImpl() void {
    frame_count += 1;
    boxes_this_frame = 0;
    // Fixed timestep for parity with NullBackend (ignore wall clock jitter)
    dt = 1.0 / 30.0;
    _ = last_ns;
    last_ns = std.time.nanoTimestamp();
}

fn endFrameImpl() void {
    if (frame_count % 40 == 0) {
        std.debug.print("--- android frame {d} pos=({d:.1},{d:.1}) boxes={d} ---\n", .{
            frame_count,
            player_x,
            player_z,
            boxes_this_frame,
        });
    }
}

/// Scripted acceptance path — same milestones as NullBackend, plus touch zones.
fn scriptedRaw() input.RawKeys {
    var raw: input.RawKeys = .{};

    // --- Boot / era (match NullBackend) ---
    if (frame_count == 5 or frame_count == 6) raw.key_1 = true; // New Game
    if (frame_count == 12 or frame_count == 13) raw.enter = true; // Confirm era

    // --- Free-roam movement ---
    if (frame_count > 20 and frame_count < 55) {
        raw.d = true;
        raw.w = true;
    }

    // --- Job start ---
    if (frame_count == 60 or frame_count == 61) raw.e = true;

    // --- Hints ---
    if (frame_count == 70 or frame_count == 71) raw.h = true;

    // --- Brief pause menu peek ---
    if (frame_count == 90 or frame_count == 91) raw.space = true;
    if (frame_count == 100 or frame_count == 101) raw.space = true; // unpause

    // --- Quick-save ---
    if (frame_count == 120 or frame_count == 121) raw.f5 = true;

    // --- Secondary / combat poke ---
    if (frame_count == 140 or frame_count == 141) raw.f = true;

    // --- Move again toward end ---
    if (frame_count > 150 and frame_count < 180) {
        raw.a = true;
        raw.s = true;
    }

    return raw;
}

/// Drive virtual touch zones so the touch→RawKeys path is exercised
/// (in addition to direct scripted keys). Stick bottom-left while moving.
fn injectScriptedTouch() void {
    touch.clear();
    // During roam frames: finger on stick (normalized, origin top-left)
    if (frame_count > 20 and frame_count < 55) {
        // stick center + bias up-right → W+D
        touch.setPointer(0.22, 0.70, true);
    }
    // Job interact: finger on [E] zone
    if (frame_count == 60 or frame_count == 61) {
        touch.setPointer2(0.80, 0.79, true);
    }
    // Pause button
    if (frame_count == 90 or frame_count == 91) {
        touch.setPointer2(0.94, 0.60, true);
    }
    // F5 zone
    if (frame_count == 120 or frame_count == 121) {
        touch.setPointer(0.08, 0.16, true);
    }
    // Attack [F]
    if (frame_count == 140 or frame_count == 141) {
        touch.setPointer2(0.94, 0.79, true);
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

    // Host/JNI path always wins when set; otherwise merge scripted + touch
    const scripted = scriptedRaw();
    if (use_touch_path) {
        injectScriptedTouch();
        const from_touch = touch.toRawKeys();
        // Prefer scripted for reliability; OR in touch so both paths are live
        var merged = scripted;
        if (from_touch.w) merged.w = true;
        if (from_touch.a) merged.a = true;
        if (from_touch.s) merged.s = true;
        if (from_touch.d) merged.d = true;
        if (from_touch.e) merged.e = true;
        if (from_touch.f) merged.f = true;
        if (from_touch.r) merged.r = true;
        if (from_touch.space) merged.space = true;
        if (from_touch.f5) merged.f5 = true;
        if (from_touch.enter) merged.enter = true;
        if (from_touch.key_1) merged.key_1 = true;
        if (from_touch.key_2) merged.key_2 = true;
        // stick axes from touch when active
        if (from_touch.stick_x != 0) merged.stick_x = from_touch.stick_x;
        if (from_touch.stick_y != 0) merged.stick_y = from_touch.stick_y;
        return merged;
    }
    return scripted;
}

pub fn injectRaw(raw: input.RawKeys) void {
    host_raw = raw;
    host_raw_valid = true;
}

pub fn setAutoClose(frames: u64) void {
    close_after = frames;
}

pub fn setUseTouchPath(on: bool) void {
    use_touch_path = on;
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
    if (frame_count % 40 == 1) {
        std.debug.print("[draw] {s}\n", .{text});
        text_lines_logged +%= 1;
    }
}
fn clearImpl(color: backend.Color) void {
    _ = color;
}
fn setCameraImpl(c: backend.Camera) void {
    cam = c;
}
fn drawGroundImpl(size: f32, color: backend.Color) void {
    _ = size;
    _ = color;
    ground_drawn = true;
}
fn drawBoxImpl(pos: backend.Vec3, w: f32, h: f32, d: f32, color: backend.Color) void {
    _ = pos;
    _ = w;
    _ = h;
    _ = d;
    _ = color;
    boxes_this_frame +%= 1;
}
fn drawPlayerProxyImpl(pos: backend.Vec3, facing_yaw: f32, color: backend.Color) void {
    _ = facing_yaw;
    _ = color;
    player_x = pos.x;
    player_z = pos.z;
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
