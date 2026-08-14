//! Phase 4 — vehicle mesh + wheel layout definitions.
//! Body GLB when present; procedural wheels always (spin + steer).

const action = @import("action.zig");

pub const WheelLayout = struct {
    /// Local offsets relative to body center (x right, y up, z forward).
    fl: [3]f32 = .{ -0.75, 0.28, 1.05 },
    fr: [3]f32 = .{ 0.75, 0.28, 1.05 },
    rl: [3]f32 = .{ -0.75, 0.28, -1.05 },
    rr: [3]f32 = .{ 0.75, 0.28, -1.05 },
    radius: f32 = 0.32,
    width: f32 = 0.22,
};

pub const BodyScale = struct {
    x: f32 = 1.0,
    y: f32 = 1.0,
    z: f32 = 1.0,
};

pub fn wheelsFor(vtype: action.VehicleType) WheelLayout {
    return switch (vtype) {
        .sedan => .{},
        .taxi => .{},
        .truck => .{
            .fl = .{ -0.95, 0.35, 1.35 },
            .fr = .{ 0.95, 0.35, 1.35 },
            .rl = .{ -0.95, 0.35, -1.25 },
            .rr = .{ 0.95, 0.35, -1.25 },
            .radius = 0.38,
            .width = 0.28,
        },
        .motorcycle => .{
            .fl = .{ 0.0, 0.32, 0.85 },
            .fr = .{ 0.0, 0.32, 0.85 }, // single front; draw once
            .rl = .{ 0.0, 0.32, -0.85 },
            .rr = .{ 0.0, 0.32, -0.85 },
            .radius = 0.30,
            .width = 0.14,
        },
    };
}

pub fn bodyScaleFor(vtype: action.VehicleType) BodyScale {
    return switch (vtype) {
        .sedan => .{ .x = 1.9, .y = 0.95, .z = 3.4 },
        .taxi => .{ .x = 1.9, .y = 0.95, .z = 3.5 },
        .truck => .{ .x = 2.3, .y = 1.35, .z = 4.4 },
        .motorcycle => .{ .x = 0.55, .y = 0.9, .z = 1.8 },
    };
}

pub fn damageTint(base: struct { r: u8, g: u8, b: u8, a: u8 }, health: u8) struct { r: u8, g: u8, b: u8, a: u8 } {
    const t = @as(f32, @floatFromInt(health)) / 100.0;
    const dark: f32 = 0.35 + 0.65 * t;
    return .{
        .r = @intFromFloat(@as(f32, @floatFromInt(base.r)) * dark),
        .g = @intFromFloat(@as(f32, @floatFromInt(base.g)) * dark),
        .b = @intFromFloat(@as(f32, @floatFromInt(base.b)) * dark),
        .a = base.a,
    };
}
