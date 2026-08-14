const std = @import("std");
const player = @import("player.zig");
const combat = @import("combat.zig");
const missions = @import("missions.zig");
const city = @import("city.zig");
const vehicle_phys = @import("vehicle_phys.zig");

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
    yaw: f32 = 0,
    wheel_spin: f32 = 0,
    steer: f32 = 0,
    // Phase 5 physics
    vx: f32 = 0,
    vz: f32 = 0,
    yaw_rate: f32 = 0,
    body_y: f32 = 0.42,
    vy: f32 = 0,
    pitch: f32 = 0,
    roll: f32 = 0,
};

pub fn spawnVehicle(vtype: VehicleType, x: f32, y: f32) Vehicle {
    const max_spd: f32 = switch (vtype) {
        .sedan => 16.0,
        .truck => 11.0,
        .motorcycle => 20.0,
        .taxi => 15.0,
    };
    const rest: f32 = switch (vtype) {
        .truck => 0.55,
        .motorcycle => 0.38,
        else => 0.42,
    };
    return .{
        .vtype = vtype,
        .x = x,
        .y = y,
        .speed = 0,
        .max_speed = max_spd,
        .health = 100,
        .occupied = false,
        .yaw = 0,
        .wheel_spin = 0,
        .steer = 0,
        .vx = 0,
        .vz = 0,
        .yaw_rate = 0,
        .body_y = rest,
        .vy = 0,
        .pitch = 0,
        .roll = 0,
    };
}

pub fn enterVehicle(v: *Vehicle, p: *player.Player) void {
    v.occupied = true;
    p.x = v.x;
    p.y = v.y;
}

pub fn exitVehicle(v: *Vehicle, p: *player.Player) void {
    v.occupied = false;
    v.speed = 0;
    v.vx = 0;
    v.vz = 0;
    v.yaw_rate = 0;
    v.steer = 0;
    p.x = v.x;
    p.y = v.y;
}

pub fn nearVehicle(v: Vehicle, p: player.Player, radius: f32) bool {
    const dx = p.x - v.x;
    const dy = p.y - v.y;
    return (dx * dx + dy * dy) <= (radius * radius);
}

/// Phase 5: throttle = move_y, steer = move_x, handbrake = Shift.
pub fn drive(v: *Vehicle, p: *player.Player, move_x: f32, move_y: f32, handbrake: bool, dt: f64) void {
    if (!v.occupied) return;
    const mapped = vehicle_phys.inputsFromMove(move_x, move_y);
    vehicle_phys.integrate(v, mapped.throttle, mapped.steer, handbrake, dt);
    p.x = v.x;
    p.y = v.y;
    p.facing_yaw = v.yaw;
}

pub const ChaseState = struct {
    active: bool = false,
    pursuit_heat: u8 = 0,
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
    if (e.active and e.enemy.hp > 0) {
        if (dt > 0.5) {
            player.takeDamage(p, 2);
        }
    }
}
