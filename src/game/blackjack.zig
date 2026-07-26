const economy = @import("economy.zig");
const player = @import("player.zig");

pub const DEN_X: f32 = 3.0;
pub const DEN_Z: f32 = 14.0;

pub fn near(p: player.Player) bool {
    const dx = p.x - DEN_X;
    const dz = p.y - DEN_Z;
    return dx * dx + dz * dz < 12.0;
}

/// Stake $100. Win ~45% for $220 return.
pub fn play(eco: *economy.Economy, seed: u32) i32 {
    if (eco.treasury < 100) return 0;
    eco.treasury -= 100;
    if (seed % 20 < 9) {
        eco.treasury += 220;
        return 120;
    }
    return -100;
}
