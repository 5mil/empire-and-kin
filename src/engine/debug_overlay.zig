const std = @import("std");
const backend = @import("backend.zig");

pub fn draw(gfx: backend.Backend, frame: u32, dt: f64) void {
    var buf: [40]u8 = undefined;
    const fps: u32 = if (dt > 0.0001) @intFromFloat(1.0 / dt) else 0;
    const line = std.fmt.bufPrint(&buf, "f{d} {d}fps", .{ frame, fps }) catch "";
    gfx.drawText(line, 1080, 110, backend.Color.rgb(100, 110, 120));
}
