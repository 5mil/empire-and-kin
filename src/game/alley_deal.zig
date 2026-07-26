const player = @import("player.zig");
const economy = @import("economy.zig");
const city = @import("city.zig");

pub fn nearAlley(p: player.Player) bool {
    return p.x < 2.5;
}

pub fn deal(eco: *economy.Economy, d: *city.District, seed: u32) []const u8 {
    if (seed % 2 == 0) {
        eco.treasury += 120;
        d.heat = @min(100, d.heat + 6);
        return "Alley deal paid";
    }
    if (eco.treasury > 50) eco.treasury -= 50;
    return "Alley deal sour";
}
