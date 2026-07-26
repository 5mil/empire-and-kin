const player = @import("player.zig");
const economy = @import("economy.zig");

pub const DOC_X: f32 = 20.0;
pub const DOC_Z: f32 = 26.0;
pub const COST: u32 = 300;

pub fn near(p: player.Player) bool {
    const dx = p.x - DOC_X;
    const dz = p.y - DOC_Z;
    return dx * dx + dz * dz < 16.0;
}

pub fn heal(p: *player.Player, eco: *economy.Economy) bool {
    if (eco.treasury < COST) return false;
    if (p.health >= 100) return false;
    eco.treasury -= COST;
    p.health = 100;
    return true;
}
