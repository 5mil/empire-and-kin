const std = @import("std");
const backend = @import("backend.zig");
const player = @import("../game/player.zig");
const living = @import("../game/living.zig");
const action = @import("../game/action.zig");
const era_mod = @import("../game/era.zig");

pub fn followCamera(p: player.Player, height: f32, back: f32) backend.Camera {
    return .{
        .position = .{ .x = p.x, .y = height, .z = p.y - back },
        .target = .{ .x = p.x, .y = 1.0, .z = p.y },
        .up = .{ .x = 0, .y = 1, .z = 0 },
        .fov_deg = 52,
    };
}

fn building(gfx: backend.Backend, x: f32, z: f32, w: f32, h: f32, d: f32, col: backend.Color) void {
    gfx.drawBox(.{ .x = x, .y = h * 0.5, .z = z }, w, h, d, col);
}

fn jobBeacon(gfx: backend.Backend, x: f32, z: f32, near: bool, active: bool) void {
    if (!active) return;
    const base = if (near) backend.Color.rgb(40, 140, 180) else backend.Color.rgb(25, 70, 95);
    const pole = if (near) backend.Color.rgb(120, 255, 255) else backend.Color.rgb(70, 190, 255);
    gfx.drawBox(.{ .x = x, .y = 0.12, .z = z }, 2.5, 0.24, 2.5, base);
    gfx.drawBox(.{ .x = x, .y = 2.0, .z = z }, 0.5, 4.0, 0.5, pole);
    if (near) {
        gfx.drawBox(.{ .x = x, .y = 4.4, .z = z }, 1.4, 0.35, 1.4, backend.Color.rgb(255, 240, 120));
    }
}

fn lamp(gfx: backend.Backend, x: f32, z: f32) void {
    gfx.drawBox(.{ .x = x, .y = 1.5, .z = z }, 0.25, 3.0, 0.25, backend.Color.rgb(40, 40, 45));
    gfx.drawBox(.{ .x = x, .y = 3.2, .z = z }, 0.6, 0.4, 0.6, backend.Color.rgb(255, 220, 140));
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
    // design 06: era-tinted sky
    const clear_col = switch (period) {
        .night => if (era == .nyc_1980s) backend.Color.rgb(6, 8, 28) else backend.Color.rgb(8, 10, 22),
        .dawn => backend.Color.rgb(40, 35, 55),
        .day => if (era == .nyc_1980s) backend.Color.rgb(60, 95, 140) else backend.Color.rgb(70, 105, 145),
        .dusk => backend.Color.rgb(85, 50, 38),
        .evening => if (era == .nyc_1980s) backend.Color.rgb(18, 20, 48) else backend.Color.rgb(22, 25, 40),
    };
    gfx.clear(clear_col);

    if (cam_opt) |c| {
        gfx.setCamera(c);
    } else {
        gfx.setCamera(followCamera(p, 11.0, 15.0));
    }

    gfx.drawGround(180.0, backend.Color.rgb(50, 48, 46));

    gfx.drawBox(.{ .x = 12, .y = 0.04, .z = 20 }, 10.0, 0.1, 70.0, backend.Color.rgb(28, 28, 30));
    gfx.drawBox(.{ .x = 12, .y = 0.04, .z = 20 }, 55.0, 0.09, 10.0, backend.Color.rgb(28, 28, 30));

    building(gfx, 4, 28, 5, 6, 4, backend.Color.rgb(92, 76, 66));
    building(gfx, 12, 29, 5, 7, 4, backend.Color.rgb(72, 74, 80));
    building(gfx, 20, 28, 5, 5, 4, backend.Color.rgb(86, 70, 62));
    building(gfx, 4, 12, 5, 5, 4, backend.Color.rgb(80, 74, 68));
    building(gfx, 12, 11, 5, 6, 4, backend.Color.rgb(70, 72, 78));
    building(gfx, 20, 12, 5, 5, 4, backend.Color.rgb(88, 78, 70));

    // design 07: night street lamps
    if (period == .night or period == .evening) {
        lamp(gfx, 7, 20);
        lamp(gfx, 17, 20);
        lamp(gfx, 12, 15);
        lamp(gfx, 12, 25);
    }

    // design 08: proximity-aware beacons
    const n1 = near_job and dist2(p.x, p.y, 16, 22) < 36;
    const n2 = near_job and dist2(p.x, p.y, 8, 28) < 36;
    const n3 = near_job and dist2(p.x, p.y, 22, 12) < 36;
    jobBeacon(gfx, 16.0, 22.0, n1, true);
    jobBeacon(gfx, 8.0, 28.0, n2, true);
    jobBeacon(gfx, 22.0, 12.0, n3, true);

    if (car) |v| {
        const col = if (v.occupied) backend.Color.rgb(40, 120, 200) else backend.Color.rgb(65, 65, 75);
        gfx.drawBox(.{ .x = v.x, .y = 0.5, .z = v.y }, 2.0, 1.0, 3.5, col);
    }

    gfx.drawPlayerProxy(.{ .x = p.x, .y = 0.85, .z = p.y }, p.facing_yaw, backend.Color.rgb(220, 190, 70));
}

fn dist2(ax: f32, ay: f32, bx: f32, by: f32) f32 {
    const dx = ax - bx;
    const dy = ay - by;
    return dx * dx + dy * dy;
}
