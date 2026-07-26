const std = @import("std");
const backend = @import("backend.zig");
const player = @import("../game/player.zig");
const living = @import("../game/living.zig");
const action = @import("../game/action.zig");

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

fn jobBeacon(gfx: backend.Backend, x: f32, z: f32) void {
    gfx.drawBox(.{ .x = x, .y = 0.12, .z = z }, 2.5, 0.24, 2.5, backend.Color.rgb(25, 70, 95));
    gfx.drawBox(.{ .x = x, .y = 2.0, .z = z }, 0.5, 4.0, 0.5, backend.Color.rgb(70, 190, 255));
}

pub fn drawMinimalScene(gfx: backend.Backend, p: player.Player, period: living.Period, car: ?action.Vehicle) void {
    const clear_col = switch (period) {
        .night => backend.Color.rgb(8, 10, 22),
        .dawn => backend.Color.rgb(40, 35, 55),
        .day => backend.Color.rgb(70, 105, 145),
        .dusk => backend.Color.rgb(85, 50, 38),
        .evening => backend.Color.rgb(22, 25, 40),
    };
    gfx.clear(clear_col);
    gfx.setCamera(followCamera(p, 11.0, 15.0));

    // Ground
    gfx.drawGround(180.0, backend.Color.rgb(50, 48, 46));

    // Cross streets (read as asphalt)
    gfx.drawBox(.{ .x = 12, .y = 0.04, .z = 20 }, 10.0, 0.1, 70.0, backend.Color.rgb(28, 28, 30));
    gfx.drawBox(.{ .x = 12, .y = 0.04, .z = 20 }, 55.0, 0.09, 10.0, backend.Color.rgb(28, 28, 30));

    // North row
    building(gfx, 4, 28, 5, 6, 4, backend.Color.rgb(92, 76, 66));
    building(gfx, 12, 29, 5, 7, 4, backend.Color.rgb(72, 74, 80));
    building(gfx, 20, 28, 5, 5, 4, backend.Color.rgb(86, 70, 62));

    // South row
    building(gfx, 4, 12, 5, 5, 4, backend.Color.rgb(80, 74, 68));
    building(gfx, 12, 11, 5, 6, 4, backend.Color.rgb(70, 72, 78));
    building(gfx, 20, 12, 5, 5, 4, backend.Color.rgb(88, 78, 70));

    // Job markers (match main.zig spawns)
    jobBeacon(gfx, 16.0, 22.0);
    jobBeacon(gfx, 8.0, 28.0);
    jobBeacon(gfx, 22.0, 12.0);

    if (car) |v| {
        const col = if (v.occupied) backend.Color.rgb(40, 120, 200) else backend.Color.rgb(65, 65, 75);
        gfx.drawBox(.{ .x = v.x, .y = 0.5, .z = v.y }, 2.0, 1.0, 3.5, col);
    }

    gfx.drawPlayerProxy(.{ .x = p.x, .y = 0.85, .z = p.y }, p.facing_yaw, backend.Color.rgb(220, 190, 70));
}
