const player = @import("player.zig");
const stash = @import("stash.zig");
const economy = @import("economy.zig");

pub const WH_X: f32 = 2.0;
pub const WH_Z: f32 = 28.0;
pub const CAP_BONUS: u32 = 500;

pub fn near(p: player.Player) bool {
    const dx = p.x - WH_X;
    const dz = p.y - WH_Z;
    return dx * dx + dz * dz < 16.0;
}

/// Large deposit when near warehouse.
pub fn bigDeposit(s: *stash.Stash, eco: *economy.Economy) bool {
    return stash.deposit(s, eco, CAP_BONUS);
}
