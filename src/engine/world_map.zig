//! Full-screen world map with zoom / pan — M to toggle.
//! Better movement: dedicated zoom keys, clamped pan, legend, district hint.
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
    zoom: f32 = 1.15,
    pan_x: f32 = 0,
    pan_y: f32 = 0,
};

pub fn handle(m: *WorldMap, raw: input.RawKeys, edge_m: *input.ButtonEdge) void {
    if (edge_m.pressed(raw.m)) m.open = !m.open;
    if (!m.open) return;

    // Zoom: Q out, E in (map owns Q/E while open — camera orbit is disabled by caller)
    if (raw.q) m.zoom = @max(0.55, m.zoom - 0.035);
    if (raw.e) m.zoom = @min(3.2, m.zoom + 0.035);
    // Also support brackets
    if (raw.bracket_l) m.zoom = @max(0.55, m.zoom - 0.04);
    if (raw.bracket_r) m.zoom = @min(3.2, m.zoom + 0.04);

    const pan_speed: f32 = 1.35 / m.zoom;
    if (raw.left or raw.a) m.pan_x -= pan_speed;
    if (raw.right or raw.d) m.pan_x += pan_speed;
    if (raw.up or raw.w) m.pan_y += pan_speed;
    if (raw.down or raw.s) m.pan_y -= pan_speed;

    // Soft clamp so you cannot pan into empty void forever
    m.pan_x = std.math.clamp(m.pan_x, -90.0, 90.0);
    m.pan_y = std.math.clamp(m.pan_y, -70.0, 70.0);
}

pub fn draw(
    gfx: backend.Backend,
    m: WorldMap,
    p: player.Player,
    jobs: []const mission_ui.ActiveJob,
) void {
    if (!m.open) return;

    gfx.drawText("########################################", 260, 28, backend.Color.rgb(18, 18, 26));
    gfx.drawText("#     EMPIRE & KIN — CITY MAP          #", 260, 44, backend.Color.rgb(220, 210, 160));
    gfx.drawText("#  WASD pan   Q/E or [ ] zoom   M close#", 260, 60, backend.Color.rgb(140, 140, 130));
    gfx.drawText("########################################", 260, 76, backend.Color.rgb(18, 18, 26));

    const ox: f32 = 640.0;
    const oy: f32 = 380.0;
    const scale: f32 = 4.8 * m.zoom;

    // Avenue guides (approximate multi-avenue grid)
    gfx.drawText("--- avenues / cross streets ---", 280, 100, backend.Color.rgb(70, 80, 95));

    // Buildings as density markers
    for (cityscape.BUILDINGS) |b| {
        const sx = ox + (b.x - p.x + m.pan_x) * scale;
        const sy = oy - (b.z - p.y + m.pan_y) * scale;
        if (sx < 180 or sx > 1120 or sy < 95 or sy > 660) continue;
        // Taller buildings slightly brighter glyph
        const ch: []const u8 = if (b.h > 9.0) "H" else if (b.h > 7.0) "#" else "+";
        gfx.drawText(ch, @intFromFloat(sx), @intFromFloat(sy), backend.Color.rgb(95, 88, 82));
    }

    // Lamps (small dots)
    for (cityscape.LAMPS) |lp| {
        const sx = ox + (lp.x - p.x + m.pan_x) * scale;
        const sy = oy - (lp.z - p.y + m.pan_y) * scale;
        if (sx < 180 or sx > 1120 or sy < 95 or sy > 660) continue;
        gfx.drawText(".", @intFromFloat(sx), @intFromFloat(sy), backend.Color.rgb(160, 150, 90));
    }

    // Jobs
    for (jobs) |j| {
        if (j.state == .done) continue;
        const sx = ox + (j.world.x - p.x + m.pan_x) * scale;
        const sy = oy - (j.world.y - p.y + m.pan_y) * scale;
        if (sx < 180 or sx > 1120 or sy < 95 or sy > 660) continue;
        gfx.drawText("J", @intFromFloat(sx), @intFromFloat(sy), backend.Color.rgb(80, 220, 255));
    }

    // Safehouse
    {
        const sx = ox + (scene.SAFEHOUSE_X - p.x + m.pan_x) * scale;
        const sy = oy - (scene.SAFEHOUSE_Z - p.y + m.pan_y) * scale;
        gfx.drawText("S", @intFromFloat(sx), @intFromFloat(sy), backend.Color.rgb(80, 255, 120));
    }

    // Player always center of view frame
    gfx.drawText("P", @intFromFloat(ox), @intFromFloat(oy), backend.Color.rgb(255, 220, 60));

    // Legend
    gfx.drawText("P you  S safehouse  J job  H tall  # mid  + low  . lamp", 280, 640, backend.Color.rgb(130, 130, 120));

    var buf: [72]u8 = undefined;
    const zoom_txt = std.fmt.bufPrint(&buf, "zoom {d:.2}  pan {d:.0},{d:.0}  world ~({d:.0},{d:.0})", .{
        m.zoom,
        m.pan_x,
        m.pan_y,
        p.x,
        p.y,
    }) catch "zoom";
    gfx.drawText(zoom_txt, 280, 658, backend.Color.rgb(160, 160, 150));

    _ = collision.WORLD_MIN_X;
    _ = collision.WORLD_MAX_X;
}
