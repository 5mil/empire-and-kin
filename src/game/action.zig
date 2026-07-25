const std = @import("std");
const player = @import("player.zig");
const combat = @import("combat.zig");
const missions = @import("missions.zig");
const city = @import("city.zig");

// ---------------------------------------------------------------------------
// Vehicles
// ---------------------------------------------------------------------------

pub const VehicleType = enum {
    sedan,
    truck,
    motorcycle,
    taxi,
};

pub fn vehicleName(v: VehicleType) []const u8 {
    return switch (v) {
        .sedan => "Sedan",
        .truck => "Truck",
        .motorcycle => "Motorcycle",
        .taxi => "Taxi",
    };
}

pub const Vehicle = struct {
    vtype: VehicleType,
    x: f32,
    y: f32,
    speed: f32,
    max_speed: f32,
    health: u8,
    occupied: bool = false,
};

pub fn spawnVehicle(vtype: VehicleType, x: f32, y: f32) Vehicle {
    const max_spd: f32 = switch (vtype) {
        .sedan => 18.0,
        .truck => 12.0,
        .motorcycle => 22.0,
        .taxi => 16.0,
    };
    return .{
        .vtype = vtype,
        .x = x,
        .y = y,
        .speed = 0,
        .max_speed = max_spd,
        .health = 100,
        .occupied = false,
    };
}

pub fn enterVehicle(v: *Vehicle, p: *player.Player) void {
    v.occupied = true;
    p.x = v.x;
    p.y = v.y;
}

pub fn drive(v: *Vehicle, p: *player.Player, dx: f32, dy: f32, dt: f64) void {
    if (!v.occupied) return;
    const accel = @as(f32, @floatCast(dt)) * 8.0;
    v.speed = @min(v.max_speed, v.speed + accel);
    const dist = v.speed * @as(f32, @floatCast(dt));
    v.x += dx * dist;
    v.y += dy * dist;
    p.x = v.x;
    p.y = v.y;
}

// ---------------------------------------------------------------------------
// Chase
// ---------------------------------------------------------------------------

pub const ChaseState = struct {
    active: bool = false,
    pursuit_heat: u8 = 0, // 0-5
    distance: f32 = 100.0,
    escaped: bool = false,
    caught: bool = false,
};

pub fn startChase(c: *ChaseState, initial_heat: u8) void {
    c.* = .{
        .active = true,
        .pursuit_heat = initial_heat,
        .distance = 80.0 + @as(f32, @floatFromInt(initial_heat)) * 10.0,
        .escaped = false,
        .caught = false,
    };
}

pub fn tickChase(c: *ChaseState, player_speed: f32, dt: f64) void {
    if (!c.active) return;
    // Higher speed pulls away; low speed lets cops close in
    const closing = 12.0 - player_speed * 0.4;
    c.distance += @as(f32, @floatCast(dt)) * (-closing);
    if (c.distance <= 0) {
        c.distance = 0;
        c.caught = true;
        c.active = false;
    } else if (c.distance > 200) {
        c.escaped = true;
        c.active = false;
    }
}

// ---------------------------------------------------------------------------
// Open-world mission trigger
// ---------------------------------------------------------------------------

pub const WorldMission = struct {
    mission: missions.Mission,
    x: f32,
    y: f32,
    radius: f32 = 8.0,
    active: bool = true,
};

pub fn canStartMission(wm: WorldMission, p: player.Player) bool {
    if (!wm.active or wm.mission.completed) return false;
    const dx = p.x - wm.x;
    const dy = p.y - wm.y;
    return (dx * dx + dy * dy) <= (wm.radius * wm.radius);
}

// ---------------------------------------------------------------------------
// Real-time combat encounter
// ---------------------------------------------------------------------------

pub const Encounter = struct {
    enemy: combat.Fighter = .{},
    active: bool = false,
    player_cooldown: f64 = 0,
};

pub fn startEncounter(e: *Encounter, name: []const u8, hp: u8, atk: u8, def: u8) void {
    e.* = .{
        .enemy = .{ .name = name, .hp = hp, .attack = atk, .defense = def },
        .active = true,
        .player_cooldown = 0,
    };
}

pub fn combatTick(e: *Encounter, p: *player.Player, dt: f64, player_attacking: bool) void {
    if (!e.active) return;
    e.player_cooldown -= dt;
    if (player_attacking and e.player_cooldown <= 0) {
        const fake_player = combat.Fighter{ .name = p.name, .hp = p.health, .attack = 14, .defense = 6 };
        const dmg = combat.resolveHit(fake_player, e.enemy);
        combat.applyDamage(&e.enemy, dmg);
        e.player_cooldown = 0.6;
        if (!combat.isAlive(e.enemy)) {
            e.active = false;
        }
    }
    // Enemy hits back occasionally
    if (e.active and e.enemy.hp > 0) {
        if (dt > 0.5) {
            player.takeDamage(p, 2);
        }
    }
}
