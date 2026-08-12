const std = @import("std");
const backend = @import("backend.zig");
const player = @import("../game/player.zig");
const living = @import("../game/living.zig");
const action = @import("../game/action.zig");
const era_mod = @import("../game/era.zig");
const sim_actor = @import("sim_actor.zig");
const cityscape = @import("cityscape.zig");
const character_map = @import("../game/character_map.zig");
const texture_bank = @import("gfx/texture_bank.zig");

pub const SAFEHOUSE_X: f32 = 10.0;
pub const SAFEHOUSE_Z: f32 = 18.0;

pub var anim_time_s: f32 = 0;
pub var boss_moving: bool = false;
pub var boss_yaw: f32 = 0;
pub var boss_cm: character_map.CharacterMap = .{};

pub fn followCamera(p: player.Player, height: f32, back: f32) backend.Camera {
    return .{
        .position = .{ .x = p.x + 5.0, .y = height, .z = p.y - back },
        .target = .{ .x = p.x, .y = 1.0, .z = p.y },
        .up = .{ .x = 0, .y = 1, .z = 0 },
        .fov_deg = 48,
    };
}

fn box(gfx: backend.Backend, x: f32, y: f32, z: f32, w: f32, h: f32, d: f32, col: backend.Color) void {
    gfx.drawBox(.{ .x = x, .y = y, .z = z }, w, h, d, col);
}

fn shadow(gfx: backend.Backend, x: f32, z: f32, w: f32, d: f32) void {
    box(gfx, x, 0.04, z, w, 0.06, d, backend.Color.rgb(12, 12, 14));
}

fn lotGrid(gfx: backend.Backend) void {
    const col = backend.Color.rgb(70, 76, 66);
    var ix: i32 = -4;
    while (ix <= 14) : (ix += 1) {
        const x = @as(f32, @floatFromInt(ix)) * 8.0;
        box(gfx, x, 0.02, 25.0, 0.07, 0.03, 120.0, col);
    }
    var iz: i32 = -2;
    while (iz <= 10) : (iz += 1) {
        const z = @as(f32, @floatFromInt(iz)) * 8.0;
        box(gfx, 30.0, 0.02, z, 140.0, 0.03, 0.07, col);
    }
}

/// Phase 2: try GLB mesh scaled to footprint; else procedural box building.
fn building(gfx: backend.Backend, x: f32, z: f32, w: f32, h: f32, d: f32, col: backend.Color, lit: bool) void {
    shadow(gfx, x, z, w * 1.05, d * 1.05);
    if (gfx.drawBuilding(.{ .x = x, .y = h * 0.5, .z = z }, w, h, d, col)) {
        return;
    }
    box(gfx, x, h * 0.5, z, w, h, d, col);
    box(gfx, x, h + 0.12, z, w + 0.25, 0.28, d + 0.25, texture_bank.colorOf(.roof_tar));
    box(gfx, x + w * 0.28, h + 0.65, z - d * 0.18, 0.45, 0.9, 0.45, backend.Color.rgb(58, 52, 48));
    box(gfx, x, 1.0, z + d * 0.5 - 0.04, 1.1, 2.0, 0.14, backend.Color.rgb(52, 38, 28));
    const win = if (lit) backend.Color.rgb(255, 228, 135) else backend.Color.rgb(88, 108, 138);
    box(gfx, x - w * 0.22, 3.1, z + d * 0.5 - 0.02, 0.85, 1.05, 0.1, win);
    box(gfx, x + w * 0.22, 3.1, z + d * 0.5 - 0.02, 0.85, 1.05, 0.1, win);
    if (h > 5.5) {
        box(gfx, x - w * 0.22, 5.0, z + d * 0.5 - 0.02, 0.85, 1.05, 0.1, win);
        box(gfx, x + w * 0.22, 5.0, z + d * 0.5 - 0.02, 0.85, 1.05, 0.1, win);
    }
    if (h > 8.0) {
        box(gfx, x - w * 0.22, 7.0, z + d * 0.5 - 0.02, 0.85, 1.0, 0.1, win);
        box(gfx, x + w * 0.22, 7.0, z + d * 0.5 - 0.02, 0.85, 1.0, 0.1, win);
    }
    box(gfx, x, 2.25, z + d * 0.5 + 0.35, w * 0.65, 0.1, 1.0, backend.Color.rgb(130, 38, 38));
    box(gfx, x - w * 0.48, h * 0.42, z, 0.18, h * 0.65, 1.1, texture_bank.colorOf(.metal));
}

fn sidewalk(gfx: backend.Backend, x: f32, z: f32, w: f32, d: f32) void {
    box(gfx, x, 0.06, z, w, 0.12, d, texture_bank.colorOf(.sidewalk));
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

fn avenue(gfx: backend.Backend, x: f32, z: f32, len: f32, along_z: bool) void {
    const asphalt = texture_bank.colorOf(.asphalt);
    if (along_z) {
        box(gfx, x, 0.03, z, 11.0, 0.08, len, asphalt);
        var i: i32 = 0;
        const n: i32 = @intFromFloat(len / 6.0);
        while (i < n) : (i += 1) {
            const zz = z - len * 0.5 + @as(f32, @floatFromInt(i)) * 6.0 + 3.0;
            box(gfx, x, 0.05, zz, 0.22, 0.04, 2.0, backend.Color.rgb(175, 155, 55));
        }
    } else {
        box(gfx, x, 0.03, z, len, 0.07, 11.0, asphalt);
        var i: i32 = 0;
        const n: i32 = @intFromFloat(len / 6.0);
        while (i < n) : (i += 1) {
            const xx = x - len * 0.5 + @as(f32, @floatFromInt(i)) * 6.0 + 3.0;
            box(gfx, xx, 0.05, z, 2.0, 0.04, 0.22, backend.Color.rgb(175, 155, 55));
        }
    }
}

fn jobBeacon(gfx: backend.Backend, x: f32, z: f32, near: bool) void {
    shadow(gfx, x, z, 2.2, 2.2);
    const base = if (near) backend.Color.rgb(50, 180, 120) else backend.Color.rgb(30, 100, 70);
    box(gfx, x, 0.15, z, 1.8, 0.2, 1.8, base);
    box(gfx, x, 1.2, z, 0.35, 2.0, 0.35, if (near) backend.Color.rgb(100, 255, 160) else backend.Color.rgb(60, 160, 100));
    if (near) box(gfx, x, 2.4, z, 0.6, 0.6, 0.6, backend.Color.rgb(255, 240, 120));
}

fn lamp(gfx: backend.Backend, x: f32, z: f32, on: bool) void {
    const glow = if (on) backend.Color.rgb(255, 230, 150) else backend.Color.rgb(70, 70, 75);
    // Prefer prop mesh; center roughly mid-pole height.
    if (gfx.drawProp(.{ .x = x, .y = 1.6, .z = z }, 0.6, 3.2, 0.6, texture_bank.colorOf(.metal))) {
        if (on) box(gfx, x, 3.2, z, 0.4, 0.25, 0.4, glow);
        return;
    }
    box(gfx, x, 1.5, z, 0.22, 3.0, 0.22, texture_bank.colorOf(.metal));
    box(gfx, x, 3.2, z, 0.55, 0.4, 0.55, glow);
}

fn parkedCar(gfx: backend.Backend, x: f32, z: f32, col: backend.Color) void {
    shadow(gfx, x, z, 2.2, 3.6);
    box(gfx, x, 0.45, z, 1.8, 0.9, 3.2, col);
    box(gfx, x, 0.95, z - 0.3, 1.6, 0.5, 1.4, backend.Color.rgb(30, 40, 55));
}

fn hydrant(gfx: backend.Backend, x: f32, z: f32) void {
    if (gfx.drawProp(.{ .x = x, .y = 0.4, .z = z }, 0.45, 0.9, 0.45, backend.Color.rgb(180, 40, 35))) return;
    box(gfx, x, 0.4, z, 0.35, 0.8, 0.35, backend.Color.rgb(180, 40, 35));
}

fn dumpster(gfx: backend.Backend, x: f32, z: f32) void {
    shadow(gfx, x, z, 1.6, 2.2);
    if (gfx.drawProp(.{ .x = x, .y = 0.6, .z = z }, 1.4, 1.2, 2.0, backend.Color.rgb(55, 70, 50))) return;
    box(gfx, x, 0.6, z, 1.4, 1.2, 2.0, backend.Color.rgb(55, 70, 50));
}

fn waterTower(gfx: backend.Backend, x: f32, z: f32) void {
    box(gfx, x, 9.0, z, 2.2, 2.5, 2.2, texture_bank.colorOf(.metal));
    box(gfx, x, 7.0, z, 0.4, 4.0, 0.4, backend.Color.rgb(70, 70, 75));
    box(gfx, x + 0.8, 7.0, z + 0.8, 0.35, 4.0, 0.35, backend.Color.rgb(70, 70, 75));
    box(gfx, x - 0.8, 7.0, z - 0.8, 0.35, 4.0, 0.35, backend.Color.rgb(70, 70, 75));
}

fn tree(gfx: backend.Backend, x: f32, z: f32) void {
    shadow(gfx, x, z, 1.6, 1.6);
    if (gfx.drawProp(.{ .x = x, .y = 2.0, .z = z }, 2.0, 4.0, 2.0, texture_bank.colorOf(.foliage))) return;
    box(gfx, x, 1.2, z, 0.35, 2.4, 0.35, backend.Color.rgb(70, 50, 30));
    box(gfx, x, 3.2, z, 1.8, 1.6, 1.8, texture_bank.colorOf(.foliage));
}

fn gateArch(gfx: backend.Backend, x: f32, z: f32) void {
    box(gfx, x - 1.5, 1.5, z, 0.4, 3.0, 0.4, backend.Color.rgb(80, 75, 70));
    box(gfx, x + 1.5, 1.5, z, 0.4, 3.0, 0.4, backend.Color.rgb(80, 75, 70));
    box(gfx, x, 3.2, z, 3.4, 0.35, 0.5, backend.Color.rgb(100, 90, 70));
}

fn districtSign(gfx: backend.Backend, x: f32, z: f32, tall: bool) void {
    const h: f32 = if (tall) 2.2 else 1.6;
    box(gfx, x, h * 0.5, z, 0.15, h, 0.15, backend.Color.rgb(40, 40, 45));
    box(gfx, x, h + 0.2, z, 2.4, 0.5, 0.12, backend.Color.rgb(30, 90, 50));
}

fn safehouse(gfx: backend.Backend, lit: bool) void {
    shadow(gfx, SAFEHOUSE_X, SAFEHOUSE_Z, 5.0, 4.5);
    if (!gfx.drawBuilding(.{ .x = SAFEHOUSE_X, .y = 2.5, .z = SAFEHOUSE_Z }, 4.5, 5.0, 4.0, texture_bank.colorOf(.concrete))) {
        box(gfx, SAFEHOUSE_X, 2.5, SAFEHOUSE_Z, 4.5, 5.0, 4.0, texture_bank.colorOf(.concrete));
        box(gfx, SAFEHOUSE_X, 5.2, SAFEHOUSE_Z, 4.8, 0.35, 4.3, texture_bank.colorOf(.roof_tar));
    }
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

fn dist2(ax: f32, ay: f32, bx: f32, by: f32) f32 {
    const dx = ax - bx;
    const dy = ay - by;
    return dx * dx + dy * dy;
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
        .night => if (era == .nyc_1980s) backend.Color.rgb(6, 8, 24) else backend.Color.rgb(8, 10, 22),
        .dawn => backend.Color.rgb(65, 50, 80),
        .day => if (era == .nyc_1980s) backend.Color.rgb(65, 115, 165) else backend.Color.rgb(90, 140, 185),
        .dusk => backend.Color.rgb(125, 65, 48),
        .evening => if (era == .nyc_1980s) backend.Color.rgb(18, 20, 44) else backend.Color.rgb(24, 26, 44),
    };
    gfx.clear(clear_col);

    if (cam_opt) |c| gfx.setCamera(c) else gfx.setCamera(followCamera(p, 19.0, 20.0));

    gfx.drawGround(320.0, backend.Color.rgb(56, 60, 50));
    lotGrid(gfx);

    avenue(gfx, 12, 20, 80.0, true);
    avenue(gfx, 40, 20, 80.0, true);
    avenue(gfx, 60, 20, 70.0, true);
    avenue(gfx, 30, 20, 100.0, false);
    avenue(gfx, 30, 40, 100.0, false);
    avenue(gfx, 30, 0, 90.0, false);

    crosswalk(gfx, 12, 15.2, true);
    crosswalk(gfx, 12, 24.8, true);
    crosswalk(gfx, 6.8, 20, false);
    crosswalk(gfx, 17.2, 20, false);
    crosswalk(gfx, 40, 15.2, true);
    crosswalk(gfx, 40, 24.8, true);
    crosswalk(gfx, 34.8, 20, false);
    crosswalk(gfx, 45.2, 20, false);
    crosswalk(gfx, 12, 35.0, true);
    crosswalk(gfx, 40, 35.0, true);

    sidewalk(gfx, 12, 25.5, 90, 2.2);
    sidewalk(gfx, 12, 14.5, 90, 2.2);
    sidewalk(gfx, 6.5, 20, 2.2, 70);
    sidewalk(gfx, 17.5, 20, 2.2, 70);
    sidewalk(gfx, 40, 25.5, 50, 2.0);
    sidewalk(gfx, 40, 14.5, 50, 2.0);
    sidewalk(gfx, 34.5, 20, 2.0, 50);
    sidewalk(gfx, 45.5, 20, 2.0, 50);
    sidewalk(gfx, 30, 40, 80, 2.0);
    sidewalk(gfx, 30, 35, 80, 2.0);

    box(gfx, -4, 0.04, 20, 3.0, 0.08, 50.0, backend.Color.rgb(28, 26, 26));
    dumpster(gfx, -3.5, 17.0);
    dumpster(gfx, -3.5, 24.0);
    dumpster(gfx, 25.0, 32.0);
    dumpster(gfx, 58.0, 32.0);

    for (cityscape.BUILDINGS) |b| {
        const base = cityscape.colorOf(b);
        building(gfx, b.x, b.z, b.w, b.h, b.d, base, nightish);
    }

    waterTower(gfx, 16.0, 29.0);
    waterTower(gfx, 48.0, 29.5);
    waterTower(gfx, 30.0, 50.0);
    safehouse(gfx, nightish);

    for (cityscape.LAMPS) |lp| lamp(gfx, lp.x, lp.z, nightish);

    hydrant(gfx, 8.2, 16.2);
    hydrant(gfx, 15.5, 24.2);
    hydrant(gfx, 43.0, 16.5);
    hydrant(gfx, 36.0, 36.0);
    hydrant(gfx, 58.0, 18.0);

    for (cityscape.TREES) |t| tree(gfx, t.x, t.z);

    for (cityscape.PARKED) |pc| {
        parkedCar(gfx, pc.x, pc.z, backend.Color.rgb(pc.r, pc.g, pc.b));
    }

    gateArch(gfx, 30.0, 20.0);
    gateArch(gfx, -2.0, 20.0);
    gateArch(gfx, 50.0, 20.0);
    gateArch(gfx, 12.0, 40.0);

    districtSign(gfx, 10.0, 26.0, false);
    districtSign(gfx, 38.0, 38.0, true);
    districtSign(gfx, 70.0, 22.0, true);

    for (cityscape.JOBS) |jb| {
        const near = near_job and dist2(p.x, p.y, jb.x, jb.z) < 36;
        jobBeacon(gfx, jb.x, jb.z, near);
    }

    if (car) |v| {
        shadow(gfx, v.x, v.y, 2.4, 3.8);
        const col = if (v.occupied) backend.Color.rgb(45, 130, 210) else backend.Color.rgb(70, 70, 80);
        box(gfx, v.x, 0.5, v.y, 2.0, 1.0, 3.5, col);
        box(gfx, v.x, 1.05, v.y - 0.4, 1.7, 0.45, 1.5, backend.Color.rgb(25, 35, 50));
    }

    sim_actor.drawBossMapped(gfx, p.x, p.y, boss_yaw, anim_time_s, boss_moving, boss_cm);
}
