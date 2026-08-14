//! GPU Backend — GLFW window + OpenGL 3.3 core.

const std = @import("std");
const build_options = @import("build_options");
const backend = @import("backend.zig");
const input = @import("input.zig");
const glfw_window = @import("gfx/glfw_window.zig");
const renderer = @import("gfx/renderer.zig");
const touch = @import("touch.zig");

var window: ?glfw_window.Window = null;
var rend: renderer.Renderer = .{};
var last_time: f64 = 0;
var dt: f64 = 1.0 / 60.0;
var mapper: input.Mapper = .{};
var text_queue: [64]struct { t: [96]u8, len: usize, x: i32, y: i32, c: backend.Color } = undefined;
var text_count: usize = 0;

fn initImpl(title: []const u8, width: u32, height: u32) !void {
    var title_buf: [256]u8 = undefined;
    if (title.len >= title_buf.len) return error.TitleTooLong;
    @memcpy(title_buf[0..title.len], title);
    title_buf[title.len] = 0;
    window = try glfw_window.Window.create(@ptrCast(&title_buf), width, height);
    try rend.init(width, height);
    last_time = glfw_window.Window.time();
    mapper = .{};
    text_count = 0;
    touch.clear();
    std.debug.print("[GLBackend] OpenGL 3.3 + GLFW ready {d}x{d} touch={}\n", .{
        width,
        height,
        build_options.enable_touch,
    });
}

fn shutdownImpl() void {
    rend.shutdown();
    if (window) |*w| {
        w.destroy();
        window = null;
    }
}

fn beginFrameImpl() void {
    text_count = 0;
    const now = glfw_window.Window.time();
    dt = now - last_time;
    if (dt < 0 or dt > 0.25) dt = 1.0 / 60.0;
    last_time = now;
    if (window) |*w| {
        w.poll();
        rend.resize(w.width, w.height);
        if (build_options.enable_touch) {
            const cur = w.cursorNorm();
            const left = w.mouseLeftDown();
            const right = w.mouseRightDown();
            if (left) touch.setPointer(cur.x, cur.y, true) else touch.setPointer(-1, -1, false);
            if (right) touch.setPointer2(cur.x, cur.y, true) else touch.setPointer2(-1, -1, false);
        }
    }
}

fn endFrameImpl() void {
    var i: usize = 0;
    while (i < text_count) : (i += 1) {
        const q = text_queue[i];
        rend.drawText(q.t[0..q.len], q.x, q.y, q.c);
    }
    if (window) |*w| w.swap();
}

fn pollInputImpl() backend.InputState {
    return mapper.map(pollRawKeys());
}

pub fn pollRawKeys() input.RawKeys {
    var raw: input.RawKeys = .{};
    if (window) |*w| {
        const k = glfw_window.c;
        raw.w = w.keyDown(k.GLFW_KEY_W);
        raw.a = w.keyDown(k.GLFW_KEY_A);
        raw.s = w.keyDown(k.GLFW_KEY_S);
        raw.d = w.keyDown(k.GLFW_KEY_D);
        raw.up = w.keyDown(k.GLFW_KEY_UP);
        raw.down = w.keyDown(k.GLFW_KEY_DOWN);
        raw.left = w.keyDown(k.GLFW_KEY_LEFT);
        raw.right = w.keyDown(k.GLFW_KEY_RIGHT);
        raw.e = w.keyDown(k.GLFW_KEY_E);
        raw.f = w.keyDown(k.GLFW_KEY_F);
        raw.q = w.keyDown(k.GLFW_KEY_Q);
        raw.r = w.keyDown(k.GLFW_KEY_R);
        raw.h = w.keyDown(k.GLFW_KEY_H);
        raw.x = w.keyDown(k.GLFW_KEY_X);
        raw.m = w.keyDown(k.GLFW_KEY_M);
        raw.c = w.keyDown(k.GLFW_KEY_C);
        raw.shift = w.keyDown(k.GLFW_KEY_LEFT_SHIFT) or w.keyDown(k.GLFW_KEY_RIGHT_SHIFT);
        raw.bracket_l = w.keyDown(k.GLFW_KEY_LEFT_BRACKET);
        raw.bracket_r = w.keyDown(k.GLFW_KEY_RIGHT_BRACKET);
        raw.tab = w.keyDown(k.GLFW_KEY_TAB);
        raw.enter = w.keyDown(k.GLFW_KEY_ENTER);
        raw.escape = w.keyDown(k.GLFW_KEY_ESCAPE);
        raw.space = w.keyDown(k.GLFW_KEY_SPACE);
        raw.key_1 = w.keyDown(k.GLFW_KEY_1);
        raw.key_2 = w.keyDown(k.GLFW_KEY_2);
        raw.key_3 = w.keyDown(k.GLFW_KEY_3);
        raw.key_4 = w.keyDown(k.GLFW_KEY_4);
        raw.key_5 = w.keyDown(k.GLFW_KEY_5);
        raw.f5 = w.keyDown(k.GLFW_KEY_F5);
        raw.f9 = w.keyDown(k.GLFW_KEY_F9);
    }
    if (build_options.enable_touch) {
        const t = touch.toRawKeys();
        if (t.w) raw.w = true;
        if (t.a) raw.a = true;
        if (t.s) raw.s = true;
        if (t.d) raw.d = true;
        if (t.e) raw.e = true;
        if (t.f) raw.f = true;
        if (t.r) raw.r = true;
        if (t.space) raw.space = true;
        if (t.f5) raw.f5 = true;
        if (t.enter) raw.enter = true;
        if (t.key_1) raw.key_1 = true;
        if (t.key_2) raw.key_2 = true;
        if (@abs(t.stick_x) > 0.15) raw.stick_x = t.stick_x;
        if (@abs(t.stick_y) > 0.15) raw.stick_y = t.stick_y;
    }
    return raw;
}

fn deltaTimeImpl() f64 {
    return dt;
}
fn shouldCloseImpl() bool {
    if (window) |*w| return w.shouldClose();
    return true;
}
fn drawTextImpl(text: []const u8, x: i32, y: i32, color: backend.Color) void {
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
    rend.beginFrame(color);
}
fn setCameraImpl(cam: backend.Camera) void {
    rend.setCamera(cam);
}
fn drawGroundImpl(size: f32, color: backend.Color) void {
    rend.drawGround(size, color);
}
fn drawBoxImpl(pos: backend.Vec3, w: f32, h: f32, d: f32, color: backend.Color) void {
    rend.drawBox(pos, w, h, d, color);
}
fn drawPlayerProxyImpl(pos: backend.Vec3, facing_yaw: f32, color: backend.Color) void {
    rend.drawPlayerProxy(pos, facing_yaw, color);
}
fn drawBuildingImpl(pos: backend.Vec3, w: f32, h: f32, d: f32, color: backend.Color) bool {
    return rend.drawBuilding(pos, w, h, d, color);
}
fn drawPropImpl(pos: backend.Vec3, w: f32, h: f32, d: f32, color: backend.Color) bool {
    return rend.drawProp(pos, w, h, d, color);
}
fn drawCharacterImpl(pos: backend.Vec3, facing_yaw: f32, scale: f32, color: backend.Color) bool {
    return rend.drawCharacter(pos, facing_yaw, scale, color);
}
fn drawVehicleImpl(pos: backend.Vec3, yaw: f32, wheel_spin: f32, steer: f32, health: u8, color: backend.Color) bool {
    return rend.drawVehicle(pos, yaw, wheel_spin, steer, health, color);
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
        .drawProp = drawPropImpl,
        .drawCharacter = drawCharacterImpl,
        .drawVehicle = drawVehicleImpl,
    } };
}
