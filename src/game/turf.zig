const city = @import("city.zig");
const empire = @import("empire.zig");
const crew = @import("crew.zig");

pub fn resolve(d: *city.District, e: *empire.Empire, c: *crew.Crew, seed: u32) []const u8 {
    if (seed % 2 == 0) {
        d.control = @min(100, d.control + 5);
        e.reputation = @min(100, e.reputation + 2);
        c.morale = @min(100, c.morale + 3);
        return "Turf war won";
    }
    if (d.control > 5) d.control -= 5;
    if (c.morale > 8) c.morale -= 8;
    return "Turf war lost";
}
