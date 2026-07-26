const city = @import("city.zig");

pub const Rival = struct {
    name: []const u8 = "Dutch Schultz Org",
    pressure: u8 = 20,
    last_hit: f64 = 0,
};

pub fn tick(r: *Rival, d: *city.District, elapsed: f64) void {
    if (elapsed - r.last_hit < 20.0) return;
    r.last_hit = elapsed;
    if (r.pressure > 30 and d.control > 2) {
        d.control -= 2;
        r.pressure = @min(100, r.pressure + 1);
    }
}

pub fn pushBack(r: *Rival) void {
    if (r.pressure > 5) r.pressure -= 5;
}
