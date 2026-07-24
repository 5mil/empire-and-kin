const std = @import("std");
const city = @import("city.zig");

pub const Player = struct {
    name: []const u8,
    x: f32 = 0.0,
    y: f32 = 0.0,
    speed: f32 = 4.5,
    facing_yaw: f32 = 0,
    current_district: city.DistrictType = .little_italy,
    wanted_level: u8 = 0,
    health: u8 = 100,
};

pub fn create(name: []const u8) Player {
    return .{
        .name = name,
        .x = 10.0,
        .y = 20.0,
        .current_district = .little_italy,
    };
}

pub fn move(p: *Player, dx: f32, dy: f32, dt: f64) void {
    const dist = @as(f32, @floatCast(dt)) * p.speed;
    p.x += dx * dist;
    p.y += dy * dist;
    if (dx * dx + dy * dy > 0.01) {
        p.facing_yaw = std.math.atan2(dy, dx);
    }
}

pub fn setDistrict(p: *Player, d: city.DistrictType) void {
    p.current_district = d;
}

pub fn takeDamage(p: *Player, amount: u8) void {
    if (amount >= p.health) {
        p.health = 0;
    } else {
        p.health -= amount;
    }
}
