const empire = @import("empire.zig");
const city = @import("city.zig");

pub fn daily(e: *empire.Empire, d: city.District) void {
    if (d.control >= 70) {
        e.reputation = @min(100, e.reputation + 1);
    } else if (d.control < 25 and e.reputation > -50) {
        e.reputation -= 1;
    }
}
