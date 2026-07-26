const std = @import("std");
const backend = @import("backend.zig");

pub const Feed = struct {
    lines: [8][]const u8 = .{ "", "", "", "", "", "", "", "" },
    count: u8 = 0,

    pub fn push(self: *Feed, msg: []const u8) void {
        if (msg.len == 0) return;
        if (self.count < self.lines.len) {
            self.lines[self.count] = msg;
            self.count += 1;
        } else {
            var i: u8 = 0;
            while (i + 1 < self.lines.len) : (i += 1) {
                self.lines[i] = self.lines[i + 1];
            }
            self.lines[self.lines.len - 1] = msg;
        }
    }

    pub fn draw(self: Feed, gfx: backend.Backend) void {
        var i: u8 = 0;
        while (i < self.count) : (i += 1) {
            const y: i32 = 420 + @as(i32, i) * 16;
            const col = if (i + 1 == self.count)
                backend.Color.rgb(255, 230, 160)
            else
                backend.Color.rgb(150, 150, 140);
            gfx.drawText(self.lines[i], 10, y, col);
        }
    }
};
