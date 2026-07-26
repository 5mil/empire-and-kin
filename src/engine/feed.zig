//! Last-N event feed for the HUD.
const std = @import("std");
const backend = @import("backend.zig");

pub const Feed = struct {
    lines: [4][64]u8 = undefined,
    lens: [4]usize = .{ 0, 0, 0, 0 },
    count: usize = 0,

    pub fn push(self: *Feed, text: []const u8) void {
        // shift down
        var i: usize = 3;
        while (i > 0) : (i -= 1) {
            self.lines[i] = self.lines[i - 1];
            self.lens[i] = self.lens[i - 1];
        }
        const n = @min(text.len, 63);
        @memcpy(self.lines[0][0..n], text[0..n]);
        self.lens[0] = n;
        if (self.count < 4) self.count += 1;
    }

    pub fn draw(self: Feed, gfx: backend.Backend) void {
        if (self.count == 0) return;
        gfx.drawText("-- FEED --", 900, 480, backend.Color.rgb(160, 160, 140));
        var i: usize = 0;
        while (i < self.count) : (i += 1) {
            const y: i32 = 500 + @as(i32, @intCast(i)) * 16;
            gfx.drawText(self.lines[i][0..self.lens[i]], 900, y, backend.Color.rgb(190, 195, 180));
        }
    }
};
