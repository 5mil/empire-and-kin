const player = @import("player.zig");
const economy = @import("economy.zig");
const empire = @import("empire.zig");

pub const SHOP_X: f32 = 25.0;
pub const SHOP_Z: f32 = 12.0;

pub fn near(p: player.Player) bool {
    const dx = p.x - SHOP_X;
    const dz = p.y - SHOP_Z;
    return dx * dx + dz * dz < 9.0;
}

pub fn gift(eco: *economy.Economy, e: *empire.Empire) bool {
    if (eco.treasury < 75) return false;
    eco.treasury -= 75;
    e.respect_italian = @min(100, e.respect_italian + 3);
    return true;
}
