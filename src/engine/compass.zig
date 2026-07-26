//! Simple N/E/S/W + nearest job arrow text.
const std = @import("std");
const backend = @import("backend.zig");
const player = @import("../game/player.zig");
const mission_ui = @import("mission_ui.zig");

pub fn draw(gfx: backend.Backend, p: player.Player, jobs: []const mission_ui.ActiveJob) void {
    var best_dx: f32 = 0;
    var best_dz: f32 = 0;
    var best_d: f32 = 1e9;
    var found = false;
    for (jobs) |j| {
        if (j.state == .done) continue;
        const dx = j.world.x - p.x;
        const dz = j.world.y - p.y;
        const d = dx * dx + dz * dz;
        if (d < best_d) {
            best_d = d;
            best_dx = dx;
            best_dz = dz;
            found = true;
        }
    }
    gfx.drawText("N", 620, 8, backend.Color.rgb(140, 140, 150));
    if (!found) {
        gfx.drawText("JOB --", 600, 24, backend.Color.rgb(100, 100, 110));
        return;
    }
    const adx = @abs(best_dx);
    const adz = @abs(best_dz);
    const dir: []const u8 = if (adz >= adx)
        (if (best_dz < 0) "N" else "S")
    else
        (if (best_dx > 0) "E" else "W");
    var buf: [32]u8 = undefined;
    const line = std.fmt.bufPrint(&buf, "JOB {s} {d:.0}m", .{ dir, @sqrt(best_d) }) catch "JOB";
    gfx.drawText(line, 580, 24, backend.Color.rgb(120, 220, 255));
}
