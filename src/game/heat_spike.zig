const city = @import("city.zig");
const player = @import("player.zig");

pub fn maybe(d: *city.District, p: player.Player, seed: u32) bool {
    if (p.wanted_level < 3) return false;
    if (seed % 7 != 0) return false;
    d.heat = @min(100, d.heat + 12);
    return true;
}
