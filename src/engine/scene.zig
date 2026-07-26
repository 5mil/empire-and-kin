const std = @import("std");
const backend = @import("backend.zig");
const player = @import("../game/player.zig");
const living = @import("../game/living.zig");
const action = @import("../game/action.zig");

pub fn followCamera(p: player.Player, height: f32, back: f32) backend.Camera {
    return .{
        .position = .{ .x = p.x, .y = height, .z = p.y - back },
        .target = .{ .x = p.x, .y = 1.2, .z = p.y },
        .up = .{ .x = 0, .y = 1, .z = 0 },
        .fov_deg = 50,
    };
}

fn building(gfx: backend.Backend, x: f32, z: f32, w: f32, h: f32, d: f32, col: backend.Color) void {
    gfx.drawBox(.{ .x = x, .y = h * 0.5, .z = z }, w, h, d, col);
}

fn jobBeacon(gfx: backend.Backend, x: f32, z: f32) void {
    // Tall thin marker + base pad so jobs are readable in the world
    gfx.drawBox(.{ .x = x, .y = 0.15, .z = z }, 3.0, 0.3, 3.0, backend.Color.rgb(30, 90, 120));
    gfx.drawBox(.{ .x = x, .y = 2.5, .z = z }, 0.6, 5.0, 0.6, backend.Color.rgb(80, 200, 255));
    gfx.drawBox(.{ .x = x, .y = 5.2, .z = z }, 1.2, 0.4, 1.2, backend.Color.rgb(255, 220, 80));
}

pub fn drawMinimalScene(gfx: backend.Backend, p: player.Player, period: living.Period, car: ?action.Vehicle) void {
    const clear_col = switch (period) {
        .night => backend.Color.rgb(8, 10, 22),
        .dawn => backend.Color.rgb(40, 35, 55),
        .day => backend.Color.rgb(72, 110, 150),
        .dusk => backend.Color.rgb(90, 55, 40),
        .evening => backend.Color.rgb(25, 28, 45),
    };
    gfx.clear(clear_col);
    gfx.setCamera(followCamera(p, 12.0, 16.0));

    // Street / sidewalk ground
    gfx.drawGround(220.0, backend.Color.rgb(48, 46, 44));

    // Main avenue (asphalt strip along Z)
    gfx.drawBox(.{ .x = 10, .y = 0.05, .z = 20 }, 8.0, 0.12, 80.0, backend.Color.rgb(32, 32, 34));
    // Side street along X
    gfx.drawBox(.{ .x = 10, .y = 0.05, .z = 20 }, 60.0, 0.11, 8.0, backend.Color.rgb(32, 32, 34));

    // Little Italy-ish blocks — north side of avenue
    building(gfx, 2, 28, 5, 5, 4, backend.Color.rgb(95, 78, 68));
    building(gfx, 8, 30, 4, 7, 4, backend.Color.rgb(70, 72, 78));
    building(gfx, 14, 29, 5, 6, 5, backend.Color.rgb(88, 70, 62));
    building(gfx, 20, 31, 4, 5, 4, backend.Color.rgb(78, 74, 70));
    building(gfx, 26, 28, 6, 8, 5, backend.Color.rgb(65, 68, 75));

    // South side
    building(gfx, 2, 12, 5, 6, 4, backend.Color.rgb(82, 76, 70));
    building(gfx, 9, 10, 4, 5, 4, backend.Color.rgb(90, 82, 72));
    building(gfx, 16, 11, 5, 7, 5, backend.Color.rgb(72, 70, 78));
    building(gfx, 22, 9, 4, 4, 4, backend.Color.rgb(85, 75, 68));
    building(gfx, 28, 12, 5, 6, 4, backend.Color.rgb(68, 72, 80));

    // Corner landmarks
    building(gfx, -4, 20, 6, 9, 6, backend.Color.rgb(55, 58, 65)); // tenement
    building(gfx, 34, 20, 5, 5, 5, backend.Color.rgb(100, 85, 70)); // social club block

    // Job beacons match mission spawn coords in main.zig
    jobBeacon(gfx, 16.0, 22.0); // bootlegging
    jobBeacon(gfx, 8.0, 28.0); // protection
    jobBeacon(gfx, 22.0, 12.0); // smuggling

    // Parked props / street furniture
    gfx.drawBox(.{ .x = 6, .y = 0.4, .z = 18 }, 1.0, 0.8, 1.0, backend.Color.rgb(40, 40, 45));
    gfx.drawBox(.{ .x = 18, .y = 0.5, .z = 24 }, 0.8, 1.0, 0.8, backend.Color.rgb(50, 45, 40));

    if (car) |v| {
        const col = if (v.occupied) backend.Color.rgb(40, 120, 200) else backend.Color.rgb(70, 70, 80);
        gfx.drawBox(.{ .x = v.x, .y = 0.55, .z = v.y }, 2.0, 1.1, 3.6, col);
    }

    // Player last so they draw on top in depth ambiguity cases
    gfx.drawPlayerProxy(.{ .x = p.x, .y = 0.9, .z = p.y }, p.facing_yaw, backend.Color.rgb(220, 190, 70));
}
