//! GLES 3.0 backend — visual parity with desktop GLBackend.

const std = @import("std");
const backend = @import("backend.zig");
const input = @import("input.zig");
const touch = @import("touch.zig");
const renderer = @import("gfx/renderer.zig");
const egl_android = @import("gfx/egl_android.zig");

var egl: ?egl_android.Context = null;
var rend: renderer.Renderer = .{};
var last_ns: i128 = 0;
var dt: f64 = 1.0 / 60.0;
var mapper: input.Mapper = .{};
var text_queue: [64]struct { t: [96]u8, len: usize, x: i32, y: i32, c: backend.Color } = undefined;
var text_count: usize = 0;
var close_requested: bool = false;
var attached: bool = false;

pub fn attachNativeWindow(window: egl_android.c.EGLNativeWindowType, width: u32, height: u32) !void {
    if (egl != null) {
        egl.?.destroy();
        egl = null;
    }
    egl = try egl_android.Context.createFromWindow(window, width, height);
    try rend.init(egl.?.width, egl.?.height);
    attached = true;
    last_ns = std.time.nanoTimestamp();
    std.debug.print("[GLESBackend] attached {d}x{d}\n", .{ egl.?.width, egl.?.height });
}

pub fn detach() void {
    rend.shutdown();
    if (egl) |*e| {
        e.destroy();
        egl = null;
    }
    attached = false;
}

pub fn requestClose() void {
    close_requested = true;
}

fn initImpl(title: []const u8, width: u32, height: u32) !void {
    _ = width;
    _ = height;
    mapper = .{};
    text_count = 0;
    close_requested = false;
    last_ns = std.time.nanoTimestamp();
    std.debug.print("[GLESBackend] init '{s}' attached={}\n", .{ title, attached });
}

fn shutdownImpl() void {
    detach();
    std.debug.print("[GLESBackend] shutdown\n", .{});
}

fn beginFrameImpl() void {
    text_count = 0;
    const now = std.time.nanoTimestamp();
    dt = @as(f64, @floatFromInt(now - last_ns)) / 1e9;
    if (dt < 0 or dt > 0.25) dt = 1.0 / 60.0;
    last_ns = now;
    if (egl) |*e| {
        e.querySize();
        rend.resize(e.width, e.height);
    }
}

fn endFrameImpl() void {
    if (!attached) return;
    var i: usize = 0;
    while (i < text_count) : (i += 1) {
        const q = text_queue[i];
        rend.drawText(q.t[0..q.len], q.x, q.y, q.c);
    }
    if (egl) |e| {
        const w: i32 = @intCast(e.width);
        const h: i32 = @intCast(e.height);
        rend.drawText("STICK", @divTrunc(w * 12, 100), @divTrunc(h * 92, 100), backend.Color.rgb(180, 200, 220));
        rend.drawText("[E]", @divTrunc(w * 76, 100), @divTrunc(h * 78, 100), backend.Color.rgb(120, 255, 180));
        rend.drawText("[F]", @divTrunc(w * 90, 100), @divTrunc(h * 78, 100), backend.Color.rgb(255, 140, 120));
    }
    if (egl) |*e| e.swap();
}

fn pollInputImpl() backend.InputState {
    return mapper.map(pollRawKeys());
}

pub fn pollRawKeys() input.RawKeys {
    return touch.toRawKeys();
}

fn deltaTimeImpl() f64 {
    return dt;
}
fn shouldCloseImpl() bool {
    return close_requested;
}

fn drawTextImpl(text: []const u8, x: i32, y: i32, color: backend.Color) void {
    if (!attached) return;
    if (text_count >= text_queue.len) return;
    const n = @min(text.len, 95);
    @memcpy(text_queue[text_count].t[0..n], text[0..n]);
    text_queue[text_count].len = n;
    text_queue[text_count].x = x;
    text_queue[text_count].y = y;
    text_queue[text_count].c = color;
    text_count += 1;
}

fn clearImpl(color: backend.Color) void {
    if (attached) rend.beginFrame(color);
}
fn setCameraImpl(cam: backend.Camera) void {
    if (attached) rend.setCamera(cam);
}
fn drawGroundImpl(size: f32, color: backend.Color) void {
    if (attached) rend.drawGround(size, color);
}
fn drawBoxImpl(pos: backend.Vec3, w: f32, h: f32, d: f32, color: backend.Color) void {
    if (attached) rend.drawBox(pos, w, h, d, color);
}
fn drawPlayerProxyImpl(pos: backend.Vec3, facing_yaw: f32, color: backend.Color) void {
    if (attached) rend.drawPlayerProxy(pos, facing_yaw, color);
}
fn drawBuildingImpl(pos: backend.Vec3, w: f32, h: f32, d: f32, color: backend.Color) bool {
    if (!attached) return false;
    return rend.drawBuilding(pos, w, h, d, color);
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
        .drawBuilding = drawBuildingImpl,
    } };
}
