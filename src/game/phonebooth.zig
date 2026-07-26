const player = @import("player.zig");
const economy = @import("economy.zig");

pub const PHONE_X: f32 = 7.0;
pub const PHONE_Z: f32 = 18.5;

pub fn near(p: player.Player) bool {
    const dx = p.x - PHONE_X;
    const dz = p.y - PHONE_Z;
    return dx * dx + dz * dz < 9.0;
}

/// Pay $25 to get a cash tip (random-ish fixed).
pub fn callTip(eco: *economy.Economy) bool {
    if (eco.treasury < 25) return false;
    eco.treasury -= 25;
    eco.treasury += 80;
    return true;
}
