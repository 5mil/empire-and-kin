const std = @import("std");
const backend = @import("backend.zig");
const time = @import("../game/time.zig");

pub fn draw(gfx: backend.Backend, clock: time.Clock) void {
    var buf: [24]u8 = undefined;
    const line = std.fmt.bufPrint(&buf, "{d:0>2}:{d:0>2}", .{ clock.hour(), clock.minute() }) catch "";
    gfx.drawText(line, 600, 40, backend.Color.rgb(220, 220, 200));
}
