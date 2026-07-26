//! Fence: dump heat for a fee or buy a clean ID.
const economy = @import("economy.zig");
const city = @import("city.zig");
const player = @import("player.zig");

pub const FENCE_X: f32 = 24.0;
pub const FENCE_Z: f32 = 16.0;

pub fn near(p: player.Player) bool {
    const dx = p.x - FENCE_X;
    const dz = p.y - FENCE_Z;
    return dx * dx + dz * dz < 16.0;
}

/// Pay $200 to cut heat by 15.
pub fn coolHeat(eco: *economy.Economy, d: *city.District) bool {
    if (eco.treasury < 200) return false;
    if (d.heat == 0) return false;
    eco.treasury -= 200;
    if (d.heat > 15) d.heat -= 15 else d.heat = 0;
    return true;
}

/// Pay $400 to clear one wanted star.
pub fn clearStar(eco: *economy.Economy, p: *player.Player) bool {
    if (eco.treasury < 400 or p.wanted_level == 0) return false;
    eco.treasury -= 400;
    p.wanted_level -= 1;
    return true;
}
