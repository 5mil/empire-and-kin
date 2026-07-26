const empire = @import("empire.zig");
const city = @import("city.zig");
const economy = @import("economy.zig");
const player = @import("player.zig");

pub fn attempt(eco: *economy.Economy, e: *empire.Empire, d: *city.District, p: *player.Player, seed: u32) []const u8 {
    if (eco.treasury < 500) return "Need $500";
    eco.treasury -= 500;
    d.heat = @min(100, d.heat + 20);
    if (seed % 3 == 0) {
        e.reputation = @min(100, e.reputation + 8);
        d.control = @min(100, d.control + 6);
        return "Hit succeeded";
    }
    p.wanted_level = @min(5, p.wanted_level + 2);
    e.reputation = @max(-100, e.reputation - 5);
    return "Hit botched";
}
