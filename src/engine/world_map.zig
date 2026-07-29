//! Full-screen world map with zoom / pan — M to toggle.
const std = @import("std");
const backend = @import("backend.zig");
const player = @import("../game/player.zig");
const mission_ui = @import("mission_ui.zig");
const collision = @import("../game/collision.zig");
const scene = @import("scene.zig");
const cityscape = @import("cityscape.zig");
const input = @import("input.zig");

pub const WorldMap = struct {
    open: bool = false,
    zoom: f32 = 1.0,
    pan_x: f32 = 0,
    pan_y: f32 = 0,
};

pub fn handle(m: *WorldMap, raw: input.RawKeys, edge_m: *input.ButtonEdge) void {
    if (edge_m.pressed(raw.m)) m.open = !m.open;
    if (!m.open) return;
    // Zoom [ ]
    if (raw.key_1) m.zoom = @min(2.5, m.zoom + 0.02); // reuse held keys carefully — use dedicated
    // Pan with arrows while map open (movement is paused by caller ideally)
    const pan_speed: f32 = 1.2 / m.zoom;
    if (raw.left or raw.a) m.pan_x -= pan_speed;
    if (raw.right or raw.d) m.pan_x += pan_speed;
    if (raw.up or raw.w) m.pan_y += pan_speed;
    if (raw.down or raw.s) m.pan_y -= pan_speed;
    if (raw.q) m.zoom = @max(0.6, m.zoom - 0.03);
    if (raw.e) m.zoom = @min(3.0, m.zoom + 0.03);
}

pub fn draw(
    gfx: backend.Backend,
    m: WorldMap,
    p: player.Player,
    jobs: []const mission_ui.ActiveJob,
) void {
    if (!m.open) return;

    // Dim overlay via text block frame
    gfx.drawText("################################", 280, 40, backend.Color.rgb(20, 20, 28));
    gfx.drawText("#     EMPIRE & KIN — CITY MAP   #", 280, 56, backend.Color.rgb(220, 210, 160));
    gfx.drawText("#  Q/E zoom  WASD pan  M close  #", 280, 72, backend.Color.rgb(140, 140, 130));
    gfx.drawText("################################", 280, 88, backend.Color.rgb(20, 20, 28));

    const ox: f32 = 640.0;
    const oy: f32 = 380.0;
    const scale: f32 = 4.5 * m.zoom;

    const wmin = collision.WORLD_MIN_X;
    const wmax = collision.WORLD_MAX_X;
    const zmin = collision.WORLD_MIN_Y;
    const zmax = collision.WORLD_MAX_Y;

    // Road grid approximation
    gfx.drawText("--- avenues / streets ---", 300, 110, backend.Color.rgb(80, 90, 100));

    // Buildings as dots
    for (cityscape.BUILDINGS) |b| {
        const sx = ox + (b.x - p.x + m.pan_x) * scale;
        const sy = oy - (b.z - p.y + m.pan_y) * scale;
        if (sx < 200 or sx > 1100 or sy < 100 or sy > 650) continue;
        gfx.drawText("#", @intFromFloat(sx), @intFromFloat(sy), backend.Color.rgb(90, 85, 80));
    }

    // Jobs
    for (jobs) |j| {
        if (j.state == .done) continue;
        const sx = ox + (j.world.x - p.x + m.pan_x) * scale;
        const sy = oy - (j.world.y - p.y + m.pan_y) * scale;
        if (sx < 200 or sx > 1100 or sy < 100 or sy > 650) continue;
        gfx.drawText("J", @intFromFloat(sx), @intFromFloat(sy), backend.Color.rgb(80, 220, 255));
    }

    // Safehouse
    {
        const sx = ox + (scene.SAFEHOUSE_X - p.x + m.pan_x) * scale;
        const sy = oy - (scene.SAFEHOUSE_Z - p.y + m.pan_y) * scale;
        gfx.drawText("S", @intFromFloat(sx), @intFromFloat(sy), backend.Color.rgb(80, 255, 120));
    }

    // Player center
    gfx.drawText("P", @intFromFloat(ox), @intFromFloat(oy), backend.Color.rgb(255, 220, 60));

    var buf: [64]u8 = undefined;
    const zoom_txt = std.fmt.bufPrint(&buf, "zoom {d:.1}  pan {d:.0},{d:.0}", .{ m.zoom, m.pan_x, m.pan_y }) catch "zoom";
    gfx.drawText(zoom_txt, 300, 660, backend.Color.rgb(160, 160, 150));

    _ = wmin;
    _ = wmax;
    _ = zmin;
    _ = zmax;
}
