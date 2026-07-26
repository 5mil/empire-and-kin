const std = @import("std");
const backend = @import("backend.zig");
const panel = @import("panel.zig");

pub fn draw(gfx: backend.Backend, hp: u8, x: i32, y: i32) void {
    var buf: [24]u8 = undefined;
    const line = std.fmt.bufPrint(&buf, "HP {d}", .{hp}) catch "HP";
    const col = if (hp < 30) backend.Color.rgb(230, 60, 50) else if (hp < 60) backend.Color.rgb(230, 180, 60) else backend.Color.rgb(100, 210, 120);
    gfx.drawText(line, x, y, col);
    panel.drawBar(gfx, x, y + 14, hp, 100, '#', '.');
}
