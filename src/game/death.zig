const player = @import("player.zig");
const economy = @import("economy.zig");

pub fn isDown(p: player.Player) bool {
    return p.health == 0;
}

/// Hospital bill: clear wanted, restore HP, lose cash.
pub fn hospital(p: *player.Player, eco: *economy.Economy) void {
    const bill: u32 = 400;
    if (eco.treasury >= bill) eco.treasury -= bill else eco.treasury = 0;
    p.health = 40;
    p.wanted_level = 0;
    p.x = 10;
    p.y = 21;
}
