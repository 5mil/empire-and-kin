const player = @import("player.zig");
const city = @import("city.zig");

pub fn run(p: *player.Player, d: *city.District, seed: u32) []const u8 {
    if (seed % 2 == 0) {
        d.control = @min(100, d.control + 2);
        return "Skirmish won";
    }
    if (p.health > 10) p.health -= 10 else p.health = 1;
    d.heat = @min(100, d.heat + 4);
    return "Skirmish lost";
}
