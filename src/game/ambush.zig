const player = @import("player.zig");
const city = @import("city.zig");

/// Returns true if an ambush should trigger this check.
pub fn roll(seed: u32, heat: u8, wanted: u8) bool {
    if (heat < 50 and wanted < 2) return false;
    const chance = heat / 20 + wanted;
    return (seed % 40) < chance;
}

pub fn apply(p: *player.Player, d: *city.District) void {
    if (p.health > 15) p.health -= 15 else p.health = 1;
    d.heat = @min(100, d.heat + 5);
}
