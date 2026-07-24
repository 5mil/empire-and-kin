const std = @import("std");
const city = @import("city.zig");
const player = @import("player.zig");
const time = @import("time.zig");

// ---------------------------------------------------------------------------
// Day / Night
// ---------------------------------------------------------------------------

pub const Period = enum {
    night, // 0-5
    dawn, // 5-7
    day, // 7-18
    dusk, // 18-21
    evening, // 21-24
};

pub fn currentPeriod(clock: time.Clock) Period {
    const h = clock.hour();
    if (h < 5) return .night;
    if (h < 7) return .dawn;
    if (h < 18) return .day;
    if (h < 21) return .dusk;
    return .evening;
}

pub fn periodName(p: Period) []const u8 {
    return switch (p) {
        .night => "Night",
        .dawn => "Dawn",
        .day => "Day",
        .dusk => "Dusk",
        .evening => "Evening",
    };
}

/// Activity multiplier for civilians / traffic (higher = busier streets)
pub fn activityLevel(p: Period) f32 {
    return switch (p) {
        .night => 0.25,
        .dawn => 0.45,
        .day => 1.0,
        .dusk => 0.85,
        .evening => 0.60,
    };
}

// ---------------------------------------------------------------------------
// Pedestrians & Traffic (lightweight stubs)
// ---------------------------------------------------------------------------

pub const Pedestrian = struct {
    x: f32,
    y: f32,
    heading: f32, // radians
    speed: f32,
    active: bool = true,
};

pub const Vehicle = struct {
    x: f32,
    y: f32,
    heading: f32,
    speed: f32,
    active: bool = true,
};

pub const MAX_PEDS = 24;
pub const MAX_VEHICLES = 12;

pub const StreetLife = struct {
    peds: [MAX_PEDS]Pedestrian = undefined,
    ped_count: u8 = 0,
    vehicles: [MAX_VEHICLES]Vehicle = undefined,
    vehicle_count: u8 = 0,
};

pub fn spawnStreetLife(life: *StreetLife, density: f32) void {
    // density 0..1 controls how many we activate
    const target_peds: u8 = @intFromFloat(density * @as(f32, MAX_PEDS));
    const target_cars: u8 = @intFromFloat(density * @as(f32, MAX_VEHICLES));

    life.ped_count = target_peds;
    var i: u8 = 0;
    while (i < target_peds) : (i += 1) {
        life.peds[i] = .{
            .x = @floatFromInt(i * 3),
            .y = @floatFromInt((i * 7) % 40),
            .heading = @as(f32, @floatFromInt(i)) * 0.4,
            .speed = 1.2 + @as(f32, @floatFromInt(i % 5)) * 0.15,
            .active = true,
        };
    }

    life.vehicle_count = target_cars;
    i = 0;
    while (i < target_cars) : (i += 1) {
        life.vehicles[i] = .{
            .x = @floatFromInt(i * 8),
            .y = 10.0 + @as(f32, @floatFromInt(i % 3)) * 5.0,
            .heading = 0.0,
            .speed = 6.0 + @as(f32, @floatFromInt(i % 4)),
            .active = true,
        };
    }
}

pub fn tickStreetLife(life: *StreetLife, dt: f64) void {
    const dt32: f32 = @floatCast(dt);
    var i: u8 = 0;
    while (i < life.ped_count) : (i += 1) {
        if (!life.peds[i].active) continue;
        life.peds[i].x += @cos(life.peds[i].heading) * life.peds[i].speed * dt32;
        life.peds[i].y += @sin(life.peds[i].heading) * life.peds[i].speed * dt32;
    }
    i = 0;
    while (i < life.vehicle_count) : (i += 1) {
        if (!life.vehicles[i].active) continue;
        life.vehicles[i].x += @cos(life.vehicles[i].heading) * life.vehicles[i].speed * dt32;
        life.vehicles[i].y += @sin(life.vehicles[i].heading) * life.vehicles[i].speed * dt32;
    }
}

// ---------------------------------------------------------------------------
// Dynamic Police Response
// ---------------------------------------------------------------------------

pub const PoliceState = struct {
    alert_level: u8 = 0, // 0-5
    units_nearby: u8 = 0,
    last_response_time: f64 = 0,
};

/// Heat from district + player wanted level drives police presence.
pub fn updatePolice(
    police: *PoliceState,
    district_heat: u8,
    player_wanted: u8,
    period: Period,
    clock_elapsed: f64,
) void {
    // Base alert from district heat and player stars
    var alert: u32 = district_heat / 20 + player_wanted;
    // Night = slightly higher chance of patrols noticing
    if (period == .night or period == .evening) {
        alert += 1;
    }
    police.alert_level = @min(5, @as(u8, @intCast(alert)));

    // Units scale with alert
    police.units_nearby = police.alert_level * 2;
    police.last_response_time = clock_elapsed;
}

pub fn policeStatus(p: PoliceState) []const u8 {
    return switch (p.alert_level) {
        0 => "Quiet",
        1 => "Light patrols",
        2 => "Increased presence",
        3 => "Active search",
        4 => "Heavy response",
        else => "City-wide alert",
    };
}
