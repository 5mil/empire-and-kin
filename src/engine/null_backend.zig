const std = @import("std");
const backend = @import("backend.zig");
const input = @import("input.zig");

var frame_count: u64 = 0;
var close_after_frames: u64 = 200;
var cam: backend.Camera = .{};
var player_x: f32 = 0;
var player_z: f32 = 0;
var ground_drawn: bool = false;
var mapper: input.Mapper = .{};

fn initImpl(title: []const u8, width: u32, height: u32) !void {
    _ = width;
    _ = height;
    std.debug.print("[NullBackend] {s} (alpha demo)\n", .{title});
    frame_count = 0;
    mapper = .{};
}
fn shutdownImpl() void {
    std.debug.print("[NullBackend] frames={d}\n", .{frame_count});
}
fn beginFrameImpl() void {
    frame_count += 1;
    ground_drawn = false;
}
fn endFrameImpl() void {
    if (frame_count % 40 == 0) std.debug.print("--- frame {d} ---\n", .{frame_count});
}
fn scriptedRaw() input.RawKeys {
    var raw: input.RawKeys = .{};
    if (frame_count == 5 or frame_count == 6) raw.key_1 = true;
    if (frame_count == 12 or frame_count == 13) raw.enter = true;
    if (frame_count > 20 and frame_count < 55) {
        raw.d = true;
        raw.w = true;
    }
    if (frame_count == 60 or frame_count == 61) raw.e = true;
    if (frame_count == 70 or frame_count == 71) raw.h = true;
    if (frame_count == 120 or frame_count == 121) raw.f5 = true;
    if (frame_count == 140 or frame_count == 141) raw.f = true;
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
    if (frame_count % 40 == 1) std.debug.print("[draw] {s}\n", .{text});
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
fn drawBuildingImpl(pos: backend.Vec3, w: f32, h: f32, d: f32, color: backend.Color) bool {
    _ = pos;
    _ = w;
    _ = h;
    _ = d;
    _ = color;
    return false;
}
fn drawPropImpl(pos: backend.Vec3, w: f32, h: f32, d: f32, color: backend.Color) bool {
    _ = pos;
    _ = w;
    _ = h;
    _ = d;
    _ = color;
    return false;
}
fn drawCharacterImpl(pos: backend.Vec3, facing_yaw: f32, scale: f32, color: backend.Color) bool {
    _ = pos;
    _ = facing_yaw;
    _ = scale;
    _ = color;
    return false;
}
fn drawVehicleImpl(pos: backend.Vec3, yaw: f32, pitch: f32, roll: f32, wheel_spin: f32, steer: f32, health: u8, color: backend.Color) bool {
    _ = pos;
    _ = yaw;
    _ = pitch;
    _ = roll;
    _ = wheel_spin;
    _ = steer;
    _ = health;
    _ = color;
    return false;
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
            .drawBuilding = drawBuildingImpl,
            .drawProp = drawPropImpl,
            .drawCharacter = drawCharacterImpl,
            .drawVehicle = drawVehicleImpl,
        },
    };
}
