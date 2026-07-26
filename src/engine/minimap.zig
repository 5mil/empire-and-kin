//! Corner minimap as text HUD.
const std = @import("std");
const backend = @import("backend.zig");
const player = @import("../game/player.zig");
const mission_ui = @import("mission_ui.zig");
const collision = @import("../game/collision.zig");
const scene = @import("scene.zig");

pub fn draw(gfx: backend.Backend, p: player.Player, jobs: []const mission_ui.ActiveJob) void {
    const ox: i32 = 1080;
    const oy: i32 = 20;
    gfx.drawText("MAP", ox, oy, backend.Color.rgb(180, 180, 160));
    gfx.drawText("+----+", ox, oy + 16, backend.Color.rgb(90, 90, 100));
    gfx.drawText("|    |", ox, oy + 32, backend.Color.rgb(90, 90, 100));
    gfx.drawText("|    |", ox, oy + 48, backend.Color.rgb(90, 90, 100));
    gfx.drawText("+----+", ox, oy + 64, backend.Color.rgb(90, 90, 100));

    const w = collision.WORLD_MAX_X - collision.WORLD_MIN_X;
    const h = collision.WORLD_MAX_Y - collision.WORLD_MIN_Y;
    const nx = (p.x - collision.WORLD_MIN_X) / w;
    const ny = (p.y - collision.WORLD_MIN_Y) / h;
    const px: i32 = ox + 8 + @as(i32, @intFromFloat(nx * 48));
    const py: i32 = oy + 20 + @as(i32, @intFromFloat((1.0 - ny) * 40));
    gfx.drawText("P", px, py, backend.Color.rgb(255, 220, 80));

    const sx = (scene.SAFEHOUSE_X - collision.WORLD_MIN_X) / w;
    const sy = (scene.SAFEHOUSE_Z - collision.WORLD_MIN_Y) / h;
    const ssx: i32 = ox + 8 + @as(i32, @intFromFloat(sx * 48));
    const ssy: i32 = oy + 20 + @as(i32, @intFromFloat((1.0 - sy) * 40));
    gfx.drawText("S", ssx, ssy, backend.Color.rgb(80, 220, 120));

    for (jobs) |j| {
        if (j.state == .done) continue;
        const jx = (j.world.x - collision.WORLD_MIN_X) / w;
        const jy = (j.world.y - collision.WORLD_MIN_Y) / h;
        const mx: i32 = ox + 8 + @as(i32, @intFromFloat(jx * 48));
        const my: i32 = oy + 20 + @as(i32, @intFromFloat((1.0 - jy) * 40));
        gfx.drawText("J", mx, my, backend.Color.rgb(80, 200, 255));
    }
}
