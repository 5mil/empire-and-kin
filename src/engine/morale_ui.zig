const std = @import("std");
const backend = @import("backend.zig");
const crew = @import("../game/crew.zig");

pub fn draw(gfx: backend.Backend, c: crew.Crew) void {
    var buf: [32]u8 = undefined;
    const line = std.fmt.bufPrint(&buf, "Morale {d}", .{c.morale}) catch "Morale";
    const col = if (c.morale < 30) backend.Color.rgb(230, 80, 60) else if (c.morale < 60) backend.Color.rgb(220, 180, 80) else backend.Color.rgb(120, 210, 140);
    gfx.drawText(line, 1080, 150, col);
}
