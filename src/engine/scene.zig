const std = @import("std");
const backend = @import("backend.zig");
const player = @import("../game/player.zig");
const living = @import("../game/living.zig");
const action = @import("../game/action.zig");
const era_mod = @import("../game/era.zig");
const sim_actor = @import("sim_actor.zig");

pub const SAFEHOUSE_X: f32 = 10.0;
pub const SAFEHOUSE_Z: f32 = 18.0;

/// Wall-clock for procedural anim (set each frame from main).
pub var anim_time_s: f32 = 0;
/// Boss horizontal motion this frame.
pub var boss_moving: bool = false;

pub fn followCamera(p: player.Player, height: f32, back: f32) backend.Camera {
    return .{
        .position = .{ .x = p.x + 4.5, .y = height, .z = p.y - back },
        .target = .{ .x = p.x, .y = 0.8, .z = p.y },
        .up = .{ .x = 0, .y = 1, .z = 0 },
        .fov_deg = 46,
    };
}

fn box(gfx: backend.Backend, x: f32, y: f32, z: f32, w: f32, h: f32, d: f32, col: backend.Color) void {
    gfx.drawBox(.{ .x = x, .y = y, .z = z }, w, h, d, col);
}

fn shadow(gfx: backend.Backend, x: f32, z: f32, w: f32, d: f32) void {
    box(gfx, x, 0.04, z, w, 0.06, d, backend.Color.rgb(12, 12, 14));
}

fn lotGrid(gfx: backend.Backend) void {
    const col = backend.Color.rgb(72, 78, 68);
    var ix: i32 = -2;
    while (ix <= 12) : (ix += 1) {
        const x = @as(f32, @floatFromInt(ix)) * 8.0;
        box(gfx, x, 0.02, 20.0, 0.08, 0.03, 90.0, col);
    }
    var iz: i32 = 0;
    while (iz <= 8) : (iz += 1) {
        const z = @as(f32, @floatFromInt(iz)) * 8.0 + 4.0;
        box(gfx, 20.0, 0.02, z, 100.0, 0.03, 0.08, col);
    }
}

fn building(gfx: backend.Backend, x: f32, z: f32, w: f32, h: f32, d: f32, col: backend.Color, lit: bool) void {
    shadow(gfx, x, z, w * 1.05, d * 1.05);
    box(gfx, x, h * 0.5, z, w, h, d, col);
    box(gfx, x, h + 0.15, z, w + 0.3, 0.3, d + 0.3, backend.Color.rgb(45, 42, 40));
    box(gfx, x + w * 0.3, h + 0.7, z - d * 0.2, 0.5, 1.0, 0.5, backend.Color.rgb(60, 55, 50));
    box(gfx, x, 1.0, z + d * 0.5 - 0.05, 1.2, 2.0, 0.15, backend.Color.rgb(55, 40, 30));
    const win = if (lit) backend.Color.rgb(255, 230, 140) else backend.Color.rgb(90, 110, 140);
    box(gfx, x - w * 0.25, 3.2, z + d * 0.5 - 0.02, 0.9, 1.1, 0.12, win);
    box(gfx, x + w * 0.25, 3.2, z + d * 0.5 - 0.02, 0.9, 1.1, 0.12, win);
    if (h > 5.5) {
        box(gfx, x - w * 0.25, 5.2, z + d * 0.5 - 0.02, 0.9, 1.1, 0.12, win);
        box(gfx, x + w * 0.25, 5.2, z + d * 0.5 - 0.02, 0.9, 1.1, 0.12, win);
    }
    box(gfx, x, 2.3, z + d * 0.5 + 0.4, w * 0.7, 0.12, 1.2, backend.Color.rgb(140, 40, 40));
    box(gfx, x - w * 0.5 - 0.15, h * 0.45, z, 0.2, h * 0.7, 1.2, backend.Color.rgb(70, 75, 80));
}

fn sidewalk(gfx: backend.Backend, x: f32, z: f32, w: f32, d: f32) void {
    box(gfx, x, 0.06, z, w, 0.12, d, backend.Color.rgb(110, 108, 102));
}

fn crosswalk(gfx: backend.Backend, x: f32, z: f32, along_x: bool) void {
    var i: i32 = 0;
    while (i < 5) : (i += 1) {
        if (along_x) {
            box(gfx, x + @as(f32, @floatFromInt(i)) * 1.1 - 2.0, 0.06, z, 0.7, 0.05, 2.8, backend.Color.rgb(210, 210, 200));
        } else {
            box(gfx, x, 0.06, z + @as(f32, @floatFromInt(i)) * 1.1 - 2.0, 2.8, 0.05, 0.7, backend.Color.rgb(210, 210, 200));
        }
    }
}

fn jobBeacon(gfx: backend.Backend, x: f32, z: f32, near: bool, active: bool) void {
    if (!active) return;
    shadow(gfx, x, z, 2.2, 2.2);
    const base = if (near) backend.Color.rgb(50, 180, 120) else backend.Color.rgb(30, 100, 70);
    box(gfx, x, 0.15, z, 1.8, 0.2, 1.8, base);
    box(gfx, x, 1.2, z, 0.35, 2.0, 0.35, if (near) backend.Color.rgb(100, 255, 160) else backend.Color.rgb(60, 160, 100));
    if (near) box(gfx, x, 2.4, z, 0.6, 0.6, 0.6, backend.Color.rgb(255, 240, 120));
}

fn lamp(gfx: backend.Backend, x: f32, z: f32, on: bool) void {
    box(gfx, x, 1.5, z, 0.22, 3.0, 0.22, backend.Color.rgb(35, 35, 40));
    const glow = if (on) backend.Color.rgb(255, 230, 150) else backend.Color.rgb(70, 70, 75);
    box(gfx, x, 3.2, z, 0.55, 0.4, 0.55, glow);
}

fn parkedCar(gfx: backend.Backend, x: f32, z: f32, col: backend.Color) void {
    shadow(gfx, x, z, 2.2, 3.6);
    box(gfx, x, 0.45, z, 1.8, 0.9, 3.2, col);
    box(gfx, x, 0.95, z - 0.3, 1.6, 0.5, 1.4, backend.Color.rgb(30, 40, 55));
}

fn hydrant(gfx: backend.Backend, x: f32, z: f32) void {
    box(gfx, x, 0.4, z, 0.35, 0.8, 0.35, backend.Color.rgb(180, 40, 35));
}

fn dumpster(gfx: backend.Backend, x: f32, z: f32) void {
    shadow(gfx, x, z, 1.6, 2.2);
    box(gfx, x, 0.6, z, 1.4, 1.2, 2.0, backend.Color.rgb(55, 70, 50));
}

fn waterTower(gfx: backend.Backend, x: f32, z: f32) void {
    box(gfx, x, 9.0, z, 2.2, 2.5, 2.2, backend.Color.rgb(90, 95, 100));
    box(gfx, x, 7.0, z, 0.4, 4.0, 0.4, backend.Color.rgb(70, 70, 75));
    box(gfx, x + 0.8, 7.0, z + 0.8, 0.35, 4.0, 0.35, backend.Color.rgb(70, 70, 75));
    box(gfx, x - 0.8, 7.0, z - 0.8, 0.35, 4.0, 0.35, backend.Color.rgb(70, 70, 75));
}

fn tree(gfx: backend.Backend, x: f32, z: f32) void {
    shadow(gfx, x, z, 1.6, 1.6);
    box(gfx, x, 1.2, z, 0.35, 2.4, 0.35, backend.Color.rgb(70, 50, 30));
    box(gfx, x, 3.2, z, 1.8, 1.6, 1.8, backend.Color.rgb(40, 90, 45));
}

fn gateArch(gfx: backend.Backend, x: f32, z: f32) void {
    box(gfx, x - 1.5, 1.5, z, 0.4, 3.0, 0.4, backend.Color.rgb(80, 75, 70));
    box(gfx, x + 1.5, 1.5, z, 0.4, 3.0, 0.4, backend.Color.rgb(80, 75, 70));
    box(gfx, x, 3.2, z, 3.4, 0.35, 0.5, backend.Color.rgb(100, 90, 70));
}

fn safehouse(gfx: backend.Backend, lit: bool) void {
    shadow(gfx, SAFEHOUSE_X, SAFEHOUSE_Z, 5.0, 4.5);
    box(gfx, SAFEHOUSE_X, 2.5, SAFEHOUSE_Z, 4.5, 5.0, 4.0, backend.Color.rgb(68, 72, 78));
    box(gfx, SAFEHOUSE_X, 5.2, SAFEHOUSE_Z, 4.8, 0.35, 4.3, backend.Color.rgb(40, 40, 42));
    box(gfx, SAFEHOUSE_X, 1.1, SAFEHOUSE_Z + 2.05, 1.4, 2.2, 0.2, backend.Color.rgb(30, 120, 70));
    const win = if (lit) backend.Color.rgb(255, 200, 100) else backend.Color.rgb(80, 100, 120);
    box(gfx, SAFEHOUSE_X - 1.2, 3.4, SAFEHOUSE_Z + 2.0, 0.8, 1.0, 0.15, win);
    box(gfx, SAFEHOUSE_X + 1.2, 3.4, SAFEHOUSE_Z + 2.0, 0.8, 1.0, 0.15, win);
    box(gfx, SAFEHOUSE_X, 0.1, SAFEHOUSE_Z + 3.2, 2.0, 0.15, 1.5, backend.Color.rgb(40, 90, 55));
    box(gfx, SAFEHOUSE_X, 3.0, SAFEHOUSE_Z + 2.1, 2.2, 0.5, 0.1, backend.Color.rgb(20, 80, 40));
}

pub fn nearSafehouse(p: player.Player) bool {
    const dx = p.x - SAFEHOUSE_X;
    const dz = p.y - (SAFEHOUSE_Z + 2.5);
    return dx * dx + dz * dz < 4.0 * 4.0;
}

pub fn drawMinimalScene(
    gfx: backend.Backend,
    p: player.Player,
    period: living.Period,
    car: ?action.Vehicle,
    cam_opt: ?backend.Camera,
    era: era_mod.Era,
    near_job: bool,
) void {
    const nightish = period == .night or period == .evening;
    const clear_col = switch (period) {
        .night => if (era == .nyc_1980s) backend.Color.rgb(8, 10, 28) else backend.Color.rgb(10, 12, 26),
        .dawn => backend.Color.rgb(70, 55, 85),
        .day => if (era == .nyc_1980s) backend.Color.rgb(70, 120, 170) else backend.Color.rgb(95, 145, 190),
        .dusk => backend.Color.rgb(130, 70, 50),
        .evening => if (era == .nyc_1980s) backend.Color.rgb(20, 22, 48) else backend.Color.rgb(28, 30, 48),
    };
    gfx.clear(clear_col);

    if (cam_opt) |c| gfx.setCamera(c) else gfx.setCamera(followCamera(p, 17.5, 18.0));

    gfx.drawGround(200.0, backend.Color.rgb(58, 62, 52));
    lotGrid(gfx);
    box(gfx, 12, 0.03, 20, 11.0, 0.08, 72.0, backend.Color.rgb(32, 32, 34));
    box(gfx, 12, 0.03, 20, 58.0, 0.07, 11.0, backend.Color.rgb(32, 32, 34));
    box(gfx, 40, 0.03, 20, 30.0, 0.07, 11.0, backend.Color.rgb(30, 30, 32));
    box(gfx, 45, 0.03, 20, 11.0, 0.08, 40.0, backend.Color.rgb(30, 30, 32));

    crosswalk(gfx, 12, 15.2, true);
    crosswalk(gfx, 12, 24.8, true);
    crosswalk(gfx, 6.8, 20, false);
    crosswalk(gfx, 17.2, 20, false);
    crosswalk(gfx, 30, 20, false);

    box(gfx, 12, 0.05, 12, 0.25, 0.04, 2.0, backend.Color.rgb(180, 160, 60));
    box(gfx, 12, 0.05, 20, 0.25, 0.04, 2.0, backend.Color.rgb(180, 160, 60));
    box(gfx, 12, 0.05, 28, 0.25, 0.04, 2.0, backend.Color.rgb(180, 160, 60));

    sidewalk(gfx, 12, 25.5, 55, 2.2);
    sidewalk(gfx, 12, 14.5, 55, 2.2);
    sidewalk(gfx, 6.5, 20, 2.2, 55);
    sidewalk(gfx, 17.5, 20, 2.2, 55);
    sidewalk(gfx, 45, 25.5, 25, 2.0);
    sidewalk(gfx, 45, 14.5, 25, 2.0);

    box(gfx, 0.5, 0.04, 20, 3.0, 0.08, 40.0, backend.Color.rgb(30, 28, 28));
    dumpster(gfx, 0.8, 17.0);
    dumpster(gfx, 0.8, 24.0);

    building(gfx, 3.5, 28.5, 5.2, 6.5, 4.2, backend.Color.rgb(98, 78, 68), nightish);
    building(gfx, 11.5, 29.2, 5.0, 7.5, 4.0, backend.Color.rgb(70, 74, 82), nightish);
    building(gfx, 19.5, 28.3, 5.2, 5.8, 4.2, backend.Color.rgb(90, 72, 64), nightish);
    building(gfx, 27.0, 28.8, 4.5, 6.2, 3.8, backend.Color.rgb(82, 70, 62), nightish);
    building(gfx, 3.5, 11.5, 5.0, 5.5, 4.0, backend.Color.rgb(85, 76, 70), nightish);
    building(gfx, 11.5, 10.8, 5.0, 6.5, 4.0, backend.Color.rgb(68, 72, 80), nightish);
    building(gfx, 19.5, 11.5, 5.2, 5.5, 4.0, backend.Color.rgb(92, 80, 72), nightish);
    building(gfx, 27.0, 11.2, 4.5, 5.8, 3.8, backend.Color.rgb(78, 68, 60), nightish);

    building(gfx, 41.0, 28.2, 5.5, 7.0, 4.0, backend.Color.rgb(60, 65, 72), nightish);
    building(gfx, 49.0, 28.0, 5.5, 6.5, 4.0, backend.Color.rgb(55, 58, 65), nightish);
    building(gfx, 41.0, 11.5, 5.5, 6.0, 4.0, backend.Color.rgb(65, 62, 58), nightish);
    building(gfx, 49.0, 11.3, 5.5, 5.8, 4.0, backend.Color.rgb(58, 60, 68), nightish);

    waterTower(gfx, 11.5, 29.2);
    waterTower(gfx, 49.0, 28.0);
    safehouse(gfx, nightish);

    lamp(gfx, 7, 20, nightish);
    lamp(gfx, 17, 20, nightish);
    lamp(gfx, 12, 15.5, nightish);
    lamp(gfx, 12, 25.5, nightish);
    lamp(gfx, 2, 20, nightish);
    lamp(gfx, 24, 20, nightish);
    lamp(gfx, 35, 20, nightish);
    lamp(gfx, 45, 20, nightish);
    hydrant(gfx, 8.2, 16.2);
    hydrant(gfx, 15.5, 24.2);
    hydrant(gfx, 43.0, 16.5);

    tree(gfx, 4.0, 16.0);
    tree(gfx, 20.0, 25.0);
    tree(gfx, 9.0, 27.0);

    parkedCar(gfx, 5.5, 22.5, backend.Color.rgb(50, 55, 70));
    parkedCar(gfx, 18.5, 17.5, backend.Color.rgb(90, 40, 35));
    parkedCar(gfx, 8.0, 15.0, backend.Color.rgb(35, 45, 40));
    parkedCar(gfx, 22.0, 23.0, backend.Color.rgb(40, 50, 55));
    parkedCar(gfx, 43.0, 22.0, backend.Color.rgb(45, 50, 55));

    gateArch(gfx, 30.0, 20.0);
    gateArch(gfx, -1.0, 20.0);
    gateArch(gfx, 42.0, 20.0);

    const n1 = near_job and dist2(p.x, p.y, 16, 22) < 36;
    const n2 = near_job and dist2(p.x, p.y, 8, 28) < 36;
    const n3 = near_job and dist2(p.x, p.y, 22, 12) < 36;
    const n4 = near_job and dist2(p.x, p.y, 12, 16) < 36;
    const n5 = near_job and dist2(p.x, p.y, 26, 18) < 36;
    const n6 = near_job and dist2(p.x, p.y, 45, 22) < 36;
    jobBeacon(gfx, 16.0, 22.0, n1, true);
    jobBeacon(gfx, 8.0, 28.0, n2, true);
    jobBeacon(gfx, 22.0, 12.0, n3, true);
    jobBeacon(gfx, 12.0, 16.0, n4, true);
    jobBeacon(gfx, 26.0, 18.0, n5, true);
    jobBeacon(gfx, 45.0, 22.0, n6, true);

    if (car) |v| {
        shadow(gfx, v.x, v.y, 2.4, 3.8);
        const col = if (v.occupied) backend.Color.rgb(45, 130, 210) else backend.Color.rgb(70, 70, 80);
        box(gfx, v.x, 0.5, v.y, 2.0, 1.0, 3.5, col);
        box(gfx, v.x, 1.05, v.y - 0.4, 1.7, 0.45, 1.5, backend.Color.rgb(25, 35, 50));
    }

    // Animated boss (procedural walk until Quaternius GLB lands)
    sim_actor.drawBoss(gfx, p.x, p.y, anim_time_s, boss_moving);
}

fn dist2(ax: f32, ay: f32, bx: f32, by: f32) f32 {
    const dx = ax - bx;
    const dy = ay - by;
    return dx * dx + dy * dy;
}
