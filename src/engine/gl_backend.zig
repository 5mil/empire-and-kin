//! GPU Backend — SDL2 window + OpenGL 3.3 core.

const std = @import("std");
const backend = @import("backend.zig");
const input = @import("input.zig");
const sdl_window = @import("gfx/sdl_window.zig");
const renderer = @import("gfx/renderer.zig");

var window: ?sdl_window.Window = null;
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
    window = try sdl_window.Window.create(@ptrCast(&title_buf), width, height);
    try rend.init(width, height);
    last_time = sdl_window.Window.time();
    mapper = .{};
    text_count = 0;
    std.debug.print("[GLBackend] OpenGL 3.3 + SDL2 ready {d}x{d}\n", .{ width, height });
}

fn shutdownImpl() void {
    rend.shutdown();
    if (window) |*w| { w.destroy(); window = null; }
}

fn beginFrameImpl() void {
    text_count = 0;
    const now = sdl_window.Window.time();
    dt = now - last_time;
    if (dt < 0 or dt > 0.25) dt = 1.0 / 60.0;
    last_time = now;
    if (window) |*w| { w.poll(); rend.resize(w.width, w.height); }
}

fn endFrameImpl() void {
    var i: usize = 0;
    while (i < text_count) : (i += 1) {
        const q = text_queue[i];
        rend.drawTextProxy(q.x, q.y, q.len, q.c);
    }
    if (window) |*w| w.swap();
}

fn pollInputImpl() backend.InputState { return mapper.map(pollRawKeys()); }

pub fn pollRawKeys() input.RawKeys {
    var raw: input.RawKeys = .{};
    if (window) |*w| {
        const sc = sdl_window.c;
        raw.w = w.keyDown(sc.SDL_SCANCODE_W);
        raw.a = w.keyDown(sc.SDL_SCANCODE_A);
        raw.s = w.keyDown(sc.SDL_SCANCODE_S);
        raw.d = w.keyDown(sc.SDL_SCANCODE_D);
        raw.e = w.keyDown(sc.SDL_SCANCODE_E);
        raw.f = w.keyDown(sc.SDL_SCANCODE_F);
        raw.q = w.keyDown(sc.SDL_SCANCODE_Q);
        raw.r = w.keyDown(sc.SDL_SCANCODE_R);
        raw.h = w.keyDown(sc.SDL_SCANCODE_H);
        raw.x = w.keyDown(sc.SDL_SCANCODE_X);
        raw.tab = w.keyDown(sc.SDL_SCANCODE_TAB);
        raw.enter = w.keyDown(sc.SDL_SCANCODE_RETURN);
        raw.escape = w.keyDown(sc.SDL_SCANCODE_ESCAPE);
        raw.space = w.keyDown(sc.SDL_SCANCODE_SPACE);
        raw.key_1 = w.keyDown(sc.SDL_SCANCODE_1);
        raw.key_2 = w.keyDown(sc.SDL_SCANCODE_2);
        raw.key_3 = w.keyDown(sc.SDL_SCANCODE_3);
        raw.key_4 = w.keyDown(sc.SDL_SCANCODE_4);
        raw.key_5 = w.keyDown(sc.SDL_SCANCODE_5);
        raw.f5 = w.keyDown(sc.SDL_SCANCODE_F5);
        raw.f9 = w.keyDown(sc.SDL_SCANCODE_F9);
        raw.up = w.keyDown(sc.SDL_SCANCODE_UP);
        raw.down = w.keyDown(sc.SDL_SCANCODE_DOWN);
        raw.left = w.keyDown(sc.SDL_SCANCODE_LEFT);
        raw.right = w.keyDown(sc.SDL_SCANCODE_RIGHT);
    }
    return raw;
}

fn deltaTimeImpl() f64 { return dt; }
fn shouldCloseImpl() bool { if (window) |*w| return w.shouldClose(); return true; }

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

fn clearImpl(color: backend.Color) void { rend.beginFrame(color); }
fn setCameraImpl(cam: backend.Camera) void { rend.setCamera(cam); }
fn drawGroundImpl(size: f32, color: backend.Color) void { rend.drawGround(size, color); }
fn drawBoxImpl(pos: backend.Vec3, w: f32, h: f32, d: f32, color: backend.Color) void { rend.drawBox(pos, w, h, d, color); }
fn drawPlayerProxyImpl(pos: backend.Vec3, facing_yaw: f32, color: backend.Color) void { rend.drawPlayerProxy(pos, facing_yaw, color); }
fn drawVehicleImpl(pos: backend.Vec3, yaw: f32, occupied: bool, color: backend.Color) void { rend.drawVehicle(pos, yaw, occupied, color); }

pub fn getBackend() backend.Backend {
    return .{ .vtable = .{
        .init = initImpl, .shutdown = shutdownImpl, .beginFrame = beginFrameImpl, .endFrame = endFrameImpl,
        .pollInput = pollInputImpl, .deltaTime = deltaTimeImpl, .shouldClose = shouldCloseImpl,
        .drawText = drawTextImpl, .clear = clearImpl, .setCamera = setCameraImpl,
        .drawGround = drawGroundImpl, .drawBox = drawBoxImpl, .drawPlayerProxy = drawPlayerProxyImpl, .drawVehicle = drawVehicleImpl,
    }};
}
