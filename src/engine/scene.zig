const std = @import("std");
const backend = @import("backend.zig");
const player = @import("../game/player.zig");
const living = @import("../game/living.zig");

pub fn followCamera(p: player.Player, height: f32, back: f32) backend.Camera {
    return .{
        .position = .{ .x = p.x, .y = height, .z = p.y - back },
        .target = .{ .x = p.x, .y = 1.0, .z = p.y },
        .up = .{ .x = 0, .y = 1, .z = 0 },
        .fov_deg = 55,
    };
}

pub fn drawMinimalScene(gfx: backend.Backend, p: player.Player, period: living.Period) void {
    const clear_col = switch (period) {
        .night => backend.Color.rgb(8, 10, 22),
        .dawn => backend.Color.rgb(40, 35, 55),
        .day => backend.Color.rgb(72, 110, 150),
        .dusk => backend.Color.rgb(90, 55, 40),
        .evening => backend.Color.rgb(25, 28, 45),
    };
    gfx.clear(clear_col);
    gfx.setCamera(followCamera(p, 14.0, 18.0));
    gfx.drawGround(200.0, backend.Color.rgb(55, 52, 48));
    gfx.drawBox(.{ .x = 5, .y = 2, .z = 3 }, 4, 4, 4, backend.Color.rgb(90, 80, 70));
    gfx.drawBox(.{ .x = -8, .y = 3, .z = 6 }, 5, 6, 4, backend.Color.rgb(70, 75, 80));
    gfx.drawBox(.{ .x = 12, .y = 2.5, .z = -4 }, 6, 5, 5, backend.Color.rgb(85, 70, 65));
    gfx.drawBox(.{ .x = -3, .y = 2, .z = -7 }, 3, 4, 3, backend.Color.rgb(60, 65, 70));
    gfx.drawPlayerProxy(.{ .x = p.x, .y = 1.0, .z = p.y }, p.facing_yaw, backend.Color.rgb(200, 180, 60));
}
