//! Personal stash: park cash off the books.
const economy = @import("economy.zig");
const player = @import("player.zig");

pub const STASH_X: f32 = 4.0;
pub const STASH_Z: f32 = 26.0;

pub const Stash = struct {
    amount: u32 = 0,
};

pub fn near(p: player.Player) bool {
    const dx = p.x - STASH_X;
    const dz = p.y - STASH_Z;
    return dx * dx + dz * dz < 12.0;
}

pub fn deposit(s: *Stash, eco: *economy.Economy, amt: u32) bool {
    if (amt == 0 or eco.treasury < amt) return false;
    eco.treasury -= amt;
    s.amount += amt;
    return true;
}

pub fn withdraw(s: *Stash, eco: *economy.Economy, amt: u32) bool {
    if (amt == 0 or s.amount < amt) return false;
    s.amount -= amt;
    eco.treasury += amt;
    return true;
}
