//! Corner minimap as text HUD.
const std = @import("std");
const backend = @import("backend.zig");
const player = @import("../game/player.zig");
const mission_ui = @import("mission_ui.zig");
const collision = @import("../game/collision.zig");
const scene = @import("scene.zig");
const fence = @import("../game/fence.zig");
const doc = @import("../game/doc.zig");

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
    gfx.drawText("S", ox + 8 + @as(i32, @intFromFloat(sx * 48)), oy + 20 + @as(i32, @intFromFloat((1.0 - sy) * 40)), backend.Color.rgb(80, 220, 120));

    const fx = (fence.FENCE_X - collision.WORLD_MIN_X) / w;
    const fy = (fence.FENCE_Z - collision.WORLD_MIN_Y) / h;
    gfx.drawText("F", ox + 8 + @as(i32, @intFromFloat(fx * 48)), oy + 20 + @as(i32, @intFromFloat((1.0 - fy) * 40)), backend.Color.rgb(180, 140, 80));

    const dx = (doc.DOC_X - collision.WORLD_MIN_X) / w;
    const dy = (doc.DOC_Z - collision.WORLD_MIN_Y) / h;
    gfx.drawText("D", ox + 8 + @as(i32, @intFromFloat(dx * 48)), oy + 20 + @as(i32, @intFromFloat((1.0 - dy) * 40)), backend.Color.rgb(220, 220, 230));

    for (jobs) |j| {
        if (j.state == .done) continue;
        const jx = (j.world.x - collision.WORLD_MIN_X) / w;
        const jy = (j.world.y - collision.WORLD_MIN_Y) / h;
        const mx: i32 = ox + 8 + @as(i32, @intFromFloat(jx * 48));
        const my: i32 = oy + 20 + @as(i32, @intFromFloat((1.0 - jy) * 40));
        gfx.drawText("J", mx, my, backend.Color.rgb(80, 200, 255));
    }
}
