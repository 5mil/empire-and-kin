const std = @import("std");
const backend = @import("backend.zig");
const input = @import("input.zig");

var frame_count: u64 = 0;
var close_after_frames: u64 = 90;
var cam: backend.Camera = .{};
var player_x: f32 = 0;
var player_z: f32 = 0;
var ground_drawn: bool = false;
var mapper: input.Mapper = .{};

const MAP_W: usize = 41;
const MAP_H: usize = 21;

fn initImpl(title: []const u8, width: u32, height: u32) !void {
    _ = width;
    _ = height;
    std.debug.print("[NullBackend] init: {s} (Step 4 input)\n", .{title});
    std.debug.print("[NullBackend] bindings: {s}\n", .{input.bindingHelp()});
    frame_count = 0;
    mapper = .{};
}

fn shutdownImpl() void {
    std.debug.print("[NullBackend] shutdown after {d} frames\n", .{frame_count});
}

fn beginFrameImpl() void {
    frame_count += 1;
    ground_drawn = false;
}

fn endFrameImpl() void {
    if (frame_count % 30 == 0) printAsciiScene();
}

fn scriptedRaw() input.RawKeys {
    var raw: input.RawKeys = .{};
    if (frame_count < 45) {
        raw.d = true;
        raw.w = true;
    } else if (frame_count < 55) {
        raw.a = true;
    }
    if (frame_count == 65 or frame_count == 66) raw.escape = true;
    if (frame_count == 75 or frame_count == 76) raw.escape = true;
    return raw;
}

fn pollInputImpl() backend.InputState {
    return mapper.map(scriptedRaw());
}

pub fn pollRawKeys() input.RawKeys {
    return scriptedRaw();
}

fn deltaTimeImpl() f64 {
    return 1.0 / 30.0;
}

fn shouldCloseImpl() bool {
    return frame_count >= close_after_frames;
}

fn drawTextImpl(text: []const u8, x: i32, y: i32, color: backend.Color) void {
    _ = x;
    _ = y;
    _ = color;
    if (frame_count % 30 == 1) std.debug.print("[hud] {s}\n", .{text});
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
}
fn drawPlayerProxyImpl(pos: backend.Vec3, facing_yaw: f32, color: backend.Color) void {
    _ = facing_yaw;
    _ = color;
    player_x = pos.x;
    player_z = pos.z;
}

fn printAsciiScene() void {
    var grid: [MAP_H][MAP_W]u8 = undefined;
    var row: usize = 0;
    while (row < MAP_H) : (row += 1) {
        var col: usize = 0;
        while (col < MAP_W) : (col += 1) grid[row][col] = if (ground_drawn) '.' else ' ';
    }
    const px = @as(i32, @intFromFloat(player_x)) + @as(i32, MAP_W / 2);
    const pz = @as(i32, @intFromFloat(player_z)) + @as(i32, MAP_H / 2);
    if (px >= 0 and px < MAP_W and pz >= 0 and pz < MAP_H) grid[@intCast(pz)][@intCast(px)] = '@';
    std.debug.print("\n--- scene frame {d} player ({d:.1},{d:.1}) ---\n", .{ frame_count, player_x, player_z });
    row = 0;
    while (row < MAP_H) : (row += 1) std.debug.print("{s}\n", .{grid[row][0..MAP_W]});
}

pub fn getBackend() backend.Backend {
    return .{
        .vtable = .{
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
        },
    };
}
