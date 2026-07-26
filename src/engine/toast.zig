//! Transient center-bottom messages for job complete, save, etc.
const std = @import("std");
const backend = @import("backend.zig");

pub const Toast = struct {
    msg: [96]u8 = undefined,
    len: usize = 0,
    timer: f64 = 0,

    pub fn show(self: *Toast, text: []const u8, seconds: f64) void {
        const n = @min(text.len, self.msg.len);
        @memcpy(self.msg[0..n], text[0..n]);
        self.len = n;
        self.timer = seconds;
    }

    pub fn tick(self: *Toast, dt: f64) void {
        if (self.timer > 0) {
            self.timer -= dt;
            if (self.timer < 0) self.timer = 0;
        }
    }

    pub fn draw(self: Toast, gfx: backend.Backend) void {
        if (self.timer <= 0 or self.len == 0) return;
        const col = backend.Color.rgb(255, 230, 140);
        gfx.drawText(self.msg[0..self.len], 320, 640, col);
    }
};
