//! Phase 6 — derived vehicle instruments from Phase 5 phys state.
const std = @import("std");
const action = @import("action.zig");
const vehicle_phys = @import("vehicle_phys.zig");

pub const Telemetry = struct {
    speed_mph: f32 = 0,
    rpm: f32 = 800,
    gear: u8 = 1,
    slip: f32 = 0,
    damage: u8 = 0,
    throttle: f32 = 0,
};

pub fn sample(v: action.Vehicle) Telemetry {
    const t = vehicle_phys.tuningFor(v.vtype);
    const cy = @cos(v.yaw);
    const sy = @sin(v.yaw);
    const v_long = v.vx * cy + v.vz * sy;
    const v_lat = v.vx * (-sy) + v.vz * cy;
    const speed = v.speed;
    // world units ~ m/s-ish; display as mph-ish for era flavor
    const mph = speed * 2.237;
    const max_mph = v.max_speed * 2.237;

    var gear: u8 = 1;
    if (mph > 12) gear = 2;
    if (mph > 24) gear = 3;
    if (mph > 38) gear = 4;
    if (mph > 52) gear = 5;
    if (v_long < -0.4) gear = 0; // reverse

    const gear_ratio: f32 = switch (gear) {
        0 => 3.2,
        1 => 3.6,
        2 => 2.2,
        3 => 1.5,
        4 => 1.1,
        else => 0.85,
    };
    var rpm: f32 = 800.0 + @abs(v_long) * 280.0 * gear_ratio;
    if (speed < 0.3) rpm = 800.0 + @abs(v.steer) * 40.0;
    rpm = std.math.clamp(rpm, 700.0, 6200.0);

    const slip = std.math.clamp(@abs(v_lat) / @max(1.0, speed + 0.5), 0.0, 1.0);
    _ = t;
    _ = max_mph;
    return .{
        .speed_mph = mph,
        .rpm = rpm,
        .gear = gear,
        .slip = slip,
        .damage = if (v.health >= 100) 0 else 100 - v.health,
        .throttle = std.math.clamp(v_long / @max(1.0, v.max_speed), -1.0, 1.0),
    };
}

pub fn gearLabel(g: u8) []const u8 {
    return switch (g) {
        0 => "R",
        1 => "1",
        2 => "2",
        3 => "3",
        4 => "4",
        else => "5",
    };
}
