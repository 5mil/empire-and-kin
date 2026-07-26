const player = @import("player.zig");
const economy = @import("economy.zig");
const empire = @import("empire.zig");

pub const CIG_X: f32 = 11.0;
pub const CIG_Z: f32 = 17.5;

pub fn near(p: player.Player) bool {
    const dx = p.x - CIG_X;
    const dz = p.y - CIG_Z;
    return dx * dx + dz * dz < 6.0;
}

pub fn smoke(eco: *economy.Economy, e: *empire.Empire) bool {
    if (eco.treasury < 40) return false;
    eco.treasury -= 40;
    e.reputation = @min(100, e.reputation + 1);
    return true;
}
