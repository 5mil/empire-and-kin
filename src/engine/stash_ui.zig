const std = @import("std");
const backend = @import("backend.zig");
const stash = @import("../game/stash.zig");

pub fn draw(gfx: backend.Backend, s: stash.Stash) void {
    if (s.amount == 0) return;
    var buf: [32]u8 = undefined;
    const line = std.fmt.bufPrint(&buf, "Stash ${d}", .{s.amount}) catch "Stash";
    gfx.drawText(line, 1080, 210, backend.Color.rgb(160, 200, 140));
}
