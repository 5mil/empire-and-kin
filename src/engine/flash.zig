const backend = @import("backend.zig");

pub const Flash = struct {
    text: []const u8 = "",
    t: f64 = 0,

    pub fn show(self: *Flash, msg: []const u8, sec: f64) void {
        self.text = msg;
        self.t = sec;
    }

    pub fn tick(self: *Flash, dt: f64) void {
        if (self.t > 0) {
            self.t -= dt;
            if (self.t < 0) self.t = 0;
        }
    }

    pub fn draw(self: Flash, gfx: backend.Backend) void {
        if (self.t <= 0 or self.text.len == 0) return;
        gfx.drawText(self.text, 480, 200, backend.Color.rgb(255, 100, 80));
    }
};
