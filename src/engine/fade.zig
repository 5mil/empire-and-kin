pub const Fade = struct {
    t: f64 = 0,
    duration: f64 = 0.5,
    active: bool = false,

    pub fn start(self: *Fade, sec: f64) void {
        self.duration = sec;
        self.t = sec;
        self.active = true;
    }

    pub fn tick(self: *Fade, dt: f64) void {
        if (!self.active) return;
        self.t -= dt;
        if (self.t <= 0) {
            self.t = 0;
            self.active = false;
        }
    }

    pub fn alpha(self: Fade) f32 {
        if (!self.active or self.duration <= 0) return 0;
        return @floatCast(self.t / self.duration);
    }
};
