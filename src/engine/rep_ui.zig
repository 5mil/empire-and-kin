const std = @import("std");
const backend = @import("backend.zig");
const empire = @import("../game/empire.zig");

pub fn draw(gfx: backend.Backend, e: empire.Empire) void {
    var buf: [48]u8 = undefined;
    const line = std.fmt.bufPrint(&buf, "Rep {s}", .{empire.reputationLabel(e)}) catch "Rep";
    gfx.drawText(line, 1080, 190, backend.Color.rgb(200, 180, 140));
}
