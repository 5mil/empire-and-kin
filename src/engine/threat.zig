const std = @import("std");
const backend = @import("backend.zig");

pub fn level(heat: u8, wanted: u8) u8 {
    const h: u16 = heat;
    const w: u16 = wanted * 15;
    return @intCast(@min(100, h + w));
}

pub fn draw(gfx: backend.Backend, heat: u8, wanted: u8) void {
    const lv = level(heat, wanted);
    var buf: [24]u8 = undefined;
    const line = std.fmt.bufPrint(&buf, "Threat {d}", .{lv}) catch "Threat";
    const col = if (lv >= 70) backend.Color.rgb(230, 60, 50) else if (lv >= 40) backend.Color.rgb(230, 170, 50) else backend.Color.rgb(120, 200, 120);
    gfx.drawText(line, 1080, 130, col);
}
