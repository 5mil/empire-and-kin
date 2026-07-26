const economy = @import("economy.zig");
const player = @import("player.zig");

pub const BANK_X: f32 = 6.0;
pub const BANK_Z: f32 = 12.0;

pub fn near(p: player.Player) bool {
    const dx = p.x - BANK_X;
    const dz = p.y - BANK_Z;
    return dx * dx + dz * dz < 16.0;
}

/// Bet $100 — seed decides win ~40% for $250 back.
pub fn play(eco: *economy.Economy, seed: u32) i32 {
    if (eco.treasury < 100) return 0;
    eco.treasury -= 100;
    if (seed % 5 < 2) {
        eco.treasury += 250;
        return 150;
    }
    return -100;
}
