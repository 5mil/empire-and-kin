const backend = @import("backend.zig");

pub const Toast = struct {
    msg: []const u8 = "",
    timer: f64 = 0,
    urgent: bool = false,

    pub fn show(self: *Toast, text: []const u8, sec: f64) void {
        self.msg = text;
        self.timer = sec;
        self.urgent = false;
    }

    pub fn showUrgent(self: *Toast, text: []const u8, sec: f64) void {
        self.msg = text;
        self.timer = sec;
        self.urgent = true;
    }

    pub fn tick(self: *Toast, dt: f64) void {
        if (self.timer > 0) {
            self.timer -= dt;
            if (self.timer < 0) self.timer = 0;
        }
    }

    pub fn draw(self: Toast, gfx: backend.Backend) void {
        if (self.timer <= 0 or self.msg.len == 0) return;
        const col = if (self.urgent)
            backend.Color.rgb(255, 90, 70)
        else
            backend.Color.rgb(255, 240, 180);
        gfx.drawText(self.msg, 400, 120, col);
    }
};
