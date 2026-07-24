const std = @import("std");
const backend = @import("backend.zig");

/// Headless backend with a simple top-down ASCII “scene” every N frames.
/// Real Magister/Arcis/RealCity backend will draw actual meshes/lighting.

var frame_count: u64 = 0;
var close_after_frames: u64 = 90;
var cam: backend.Camera = .{};
var player_x: f32 = 0;
var player_z: f32 = 0;
var ground_drawn: bool = false;

const MAP_W: usize = 41;
const MAP_H: usize = 21;

fn initImpl(title: []const u8, width: u32, height: u32) !void {
    _ = width;
    _ = height;
    std.debug.print("[NullBackend] init: {s} (Step 3 minimal scene)\n", .{title});
    frame_count = 0;
    player_x = 0;
    player_z = 0;
}

fn shutdownImpl() void {
    std.debug.print("[NullBackend] shutdown after {d} frames\n", .{frame_count});
}

fn beginFrameImpl() void {
    frame_count += 1;
    ground_drawn = false;
}

fn endFrameImpl() void {
    if (frame_count % 30 == 0) {
        printAsciiScene();
    }
}

fn pollInputImpl() backend.InputState {
    if (frame_count < 50) {
        return .{ .move_x = 0.6, .move_y = 0.15 };
    }
    if (frame_count == 60) {
        return .{ .pause = true };
    }
    return .{};
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
    if (frame_count % 30 == 1) {
        std.debug.print("[hud] {s}\n", .{text});
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
        while (col < MAP_W) : (col += 1) {
            grid[row][col] = if (ground_drawn) '.' else ' ';
        }
    }

    const px = @as(i32, @intFromFloat(player_x)) + @as(i32, MAP_W / 2);
    const pz = @as(i32, @intFromFloat(player_z)) + @as(i32, MAP_H / 2);
    if (px >= 0 and px < MAP_W and pz >= 0 and pz < MAP_H) {
        grid[@intCast(pz)][@intCast(px)] = '@';
    }

    const buildings = [_][2]i32{ .{ 5, 3 }, .{ -8, 6 }, .{ 12, -4 }, .{ -3, -7 } };
    for (buildings) |b| {
        const bx = b[0] + @as(i32, MAP_W / 2);
        const bz = b[1] + @as(i32, MAP_H / 2);
        if (bx >= 0 and bx < MAP_W and bz >= 0 and bz < MAP_H) {
            grid[@intCast(bz)][@intCast(bx)] = '#';
        }
    }

    std.debug.print("\n--- scene (top-down) frame {d} ---\n", .{frame_count});
    std.debug.print("cam eye=({d:.1},{d:.1},{d:.1}) target=({d:.1},{d:.1},{d:.1})\n", .{
        cam.position.x, cam.position.y, cam.position.z,
        cam.target.x,   cam.target.y,   cam.target.z,
    });
    std.debug.print("player @ ({d:.1}, {d:.1})  legend: @ player  # building  . ground\n", .{ player_x, player_z });
    row = 0;
    while (row < MAP_H) : (row += 1) {
        std.debug.print("{s}\n", .{grid[row][0..MAP_W]});
    }
    std.debug.print("-----------------------------\n");
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
