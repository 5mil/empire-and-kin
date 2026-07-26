const std = @import("std");
const backend = @import("backend.zig");
const player = @import("../game/player.zig");
const living = @import("../game/living.zig");
const action = @import("../game/action.zig");
const era_mod = @import("../game/era.zig");

pub const SAFEHOUSE_X: f32 = 10.0;
pub const SAFEHOUSE_Z: f32 = 18.0;

pub fn followCamera(p: player.Player, height: f32, back: f32) backend.Camera {
    return .{
        .position = .{ .x = p.x, .y = height, .z = p.y - back },
        .target = .{ .x = p.x, .y = 1.0, .z = p.y },
        .up = .{ .x = 0, .y = 1, .z = 0 },
        .fov_deg = 52,
    };
}

fn box(gfx: backend.Backend, x: f32, y: f32, z: f32, w: f32, h: f32, d: f32, col: backend.Color) void {
    gfx.drawBox(.{ .x = x, .y = y, .z = z }, w, h, d, col);
}

fn building(gfx: backend.Backend, x: f32, z: f32, w: f32, h: f32, d: f32, col: backend.Color, lit: bool) void {
    box(gfx, x, h * 0.5, z, w, h, d, col);
    box(gfx, x, h + 0.15, z, w + 0.3, 0.3, d + 0.3, backend.Color.rgb(45, 42, 40));
    // Chimney
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
    // Fire escape (side)
    box(gfx, x - w * 0.5 - 0.15, h * 0.45, z, 0.2, h * 0.7, 1.2, backend.Color.rgb(70, 75, 80));
}

fn sidewalk(gfx: backend.Backend, x: f32, z: f32, w: f32, d: f32) void {
    box(gfx, x, 0.06, z, w, 0.12, d, backend.Color.rgb(95, 92, 88));
}

fn crosswalk(gfx: backend.Backend, x: f32, z: f32, along_x: bool) void {
    var i: i32 = 0;
    while (i < 5) : (i += 1) {
        if (along_x) {
            box(gfx, x + @as(f32, @floatFromInt(i)) * 1.1 - 2.0, 0.06, z, 0.7, 0.05, 2.8, backend.Color.rgb(200, 200, 190));
        } else {
            box(gfx, x, 0.06, z + @as(f32, @floatFromInt(i)) * 1.1 - 2.0, 2.8, 0.05, 0.7, backend.Color.rgb(200, 200, 190));
        }
    }
}

fn jobBeacon(gfx: backend.Backend, x: f32, z: f32, near: bool, active: bool) void {
    if (!active) return;
    const base = if (near) backend.Color.rgb(40, 140, 180) else backend.Color.rgb(25, 70, 95);
    const pole = if (near) backend.Color.rgb(120, 255, 255) else backend.Color.rgb(70, 190, 255);
    box(gfx, x, 0.12, z, 2.5, 0.24, 2.5, base);
    box(gfx, x, 2.0, z, 0.5, 4.0, 0.5, pole);
    if (near) box(gfx, x, 4.4, z, 1.4, 0.35, 1.4, backend.Color.rgb(255, 240, 120));
}

fn lamp(gfx: backend.Backend, x: f32, z: f32, on: bool) void {
    box(gfx, x, 1.5, z, 0.22, 3.0, 0.22, backend.Color.rgb(35, 35, 40));
    const glow = if (on) backend.Color.rgb(255, 230, 150) else backend.Color.rgb(70, 70, 75);
    box(gfx, x, 3.2, z, 0.55, 0.4, 0.55, glow);
}

fn parkedCar(gfx: backend.Backend, x: f32, z: f32, col: backend.Color) void {
    box(gfx, x, 0.45, z, 1.8, 0.9, 3.2, col);
    box(gfx, x, 0.95, z - 0.3, 1.6, 0.5, 1.4, backend.Color.rgb(30, 40, 55));
}

fn hydrant(gfx: backend.Backend, x: f32, z: f32) void {
    box(gfx, x, 0.4, z, 0.35, 0.8, 0.35, backend.Color.rgb(180, 40, 35));
}

fn dumpster(gfx: backend.Backend, x: f32, z: f32) void {
    box(gfx, x, 0.6, z, 1.4, 1.2, 2.0, backend.Color.rgb(55, 70, 50));
}

fn safehouse(gfx: backend.Backend, lit: bool) void {
    box(gfx, SAFEHOUSE_X, 2.5, SAFEHOUSE_Z, 4.5, 5.0, 4.0, backend.Color.rgb(68, 72, 78));
    box(gfx, SAFEHOUSE_X, 5.2, SAFEHOUSE_Z, 4.8, 0.35, 4.3, backend.Color.rgb(40, 40, 42));
    box(gfx, SAFEHOUSE_X, 1.1, SAFEHOUSE_Z + 2.05, 1.4, 2.2, 0.2, backend.Color.rgb(30, 120, 70));
    const win = if (lit) backend.Color.rgb(255, 200, 100) else backend.Color.rgb(80, 100, 120);
    box(gfx, SAFEHOUSE_X - 1.2, 3.4, SAFEHOUSE_Z + 2.0, 0.8, 1.0, 0.15, win);
    box(gfx, SAFEHOUSE_X + 1.2, 3.4, SAFEHOUSE_Z + 2.0, 0.8, 1.0, 0.15, win);
    box(gfx, SAFEHOUSE_X, 0.1, SAFEHOUSE_Z + 3.2, 2.0, 0.15, 1.5, backend.Color.rgb(40, 90, 55));
    // Sign plate
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
        .night => if (era == .nyc_1980s) backend.Color.rgb(5, 6, 22) else backend.Color.rgb(7, 9, 20),
        .dawn => backend.Color.rgb(55, 45, 70),
        .day => if (era == .nyc_1980s) backend.Color.rgb(55, 100, 150) else backend.Color.rgb(75, 120, 165),
        .dusk => backend.Color.rgb(110, 55, 40),
        .evening => if (era == .nyc_1980s) backend.Color.rgb(15, 16, 40) else backend.Color.rgb(20, 22, 38),
    };
    gfx.clear(clear_col);

    if (cam_opt) |c| gfx.setCamera(c) else gfx.setCamera(followCamera(p, 11.0, 15.0));

    gfx.drawGround(200.0, backend.Color.rgb(42, 40, 38));
    box(gfx, 12, 0.03, 20, 11.0, 0.08, 72.0, backend.Color.rgb(24, 24, 26));
    box(gfx, 12, 0.03, 20, 58.0, 0.07, 11.0, backend.Color.rgb(24, 24, 26));

    // Crosswalks at intersection
    crosswalk(gfx, 12, 15.2, true);
    crosswalk(gfx, 12, 24.8, true);
    crosswalk(gfx, 6.8, 20, false);
    crosswalk(gfx, 17.2, 20, false);

    box(gfx, 12, 0.05, 12, 0.25, 0.04, 2.0, backend.Color.rgb(180, 160, 60));
    box(gfx, 12, 0.05, 20, 0.25, 0.04, 2.0, backend.Color.rgb(180, 160, 60));
    box(gfx, 12, 0.05, 28, 0.25, 0.04, 2.0, backend.Color.rgb(180, 160, 60));

    sidewalk(gfx, 12, 25.5, 55, 2.2);
    sidewalk(gfx, 12, 14.5, 55, 2.2);
    sidewalk(gfx, 6.5, 20, 2.2, 55);
    sidewalk(gfx, 17.5, 20, 2.2, 55);

    // Alley strip
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

    safehouse(gfx, nightish);

    lamp(gfx, 7, 20, nightish);
    lamp(gfx, 17, 20, nightish);
    lamp(gfx, 12, 15.5, nightish);
    lamp(gfx, 12, 25.5, nightish);
    lamp(gfx, 2, 20, nightish);
    lamp(gfx, 24, 20, nightish);
    hydrant(gfx, 8.2, 16.2);
    hydrant(gfx, 15.5, 24.2);

    parkedCar(gfx, 5.5, 22.5, backend.Color.rgb(50, 55, 70));
    parkedCar(gfx, 18.5, 17.5, backend.Color.rgb(90, 40, 35));
    parkedCar(gfx, 8.0, 15.0, backend.Color.rgb(35, 45, 40));

    const n1 = near_job and dist2(p.x, p.y, 16, 22) < 36;
    const n2 = near_job and dist2(p.x, p.y, 8, 28) < 36;
    const n3 = near_job and dist2(p.x, p.y, 22, 12) < 36;
    jobBeacon(gfx, 16.0, 22.0, n1, true);
    jobBeacon(gfx, 8.0, 28.0, n2, true);
    jobBeacon(gfx, 22.0, 12.0, n3, true);

    if (car) |v| {
        const col = if (v.occupied) backend.Color.rgb(45, 130, 210) else backend.Color.rgb(70, 70, 80);
        box(gfx, v.x, 0.5, v.y, 2.0, 1.0, 3.5, col);
        box(gfx, v.x, 1.05, v.y - 0.4, 1.7, 0.45, 1.5, backend.Color.rgb(25, 35, 50));
    }

    const px = p.x;
    const pz = p.y;
    box(gfx, px, 0.7, pz, 0.65, 1.2, 0.55, backend.Color.rgb(40, 45, 70));
    box(gfx, px, 1.55, pz, 0.5, 0.5, 0.45, backend.Color.rgb(220, 180, 140));
    box(gfx, px, 1.9, pz, 0.55, 0.25, 0.5, backend.Color.rgb(30, 30, 35));
}

fn dist2(ax: f32, ay: f32, bx: f32, by: f32) f32 {
    const dx = ax - bx;
    const dy = ay - by;
    return dx * dx + dy * dy;
}
