pub const Cd = struct {
    t: f64 = 0,

    pub fn tick(self: *Cd, dt: f64) void {
        if (self.t > 0) {
            self.t -= dt;
            if (self.t < 0) self.t = 0;
        }
    }

    pub fn ready(self: Cd) bool {
        return self.t <= 0;
    }

    pub fn start(self: *Cd, sec: f64) void {
        self.t = sec;
    }
};
