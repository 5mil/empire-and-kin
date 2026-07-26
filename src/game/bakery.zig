const player = @import("player.zig");
const economy = @import("economy.zig");
const respect = @import("respect.zig");
const empire = @import("empire.zig");

pub const BAK_X: f32 = 9.0;
pub const BAK_Z: f32 = 12.5;

pub fn near(p: player.Player) bool {
    const dx = p.x - BAK_X;
    const dz = p.y - BAK_Z;
    return dx * dx + dz * dz < 9.0;
}

pub fn buy(eco: *economy.Economy, e: *empire.Empire) bool {
    if (eco.treasury < 15) return false;
    eco.treasury -= 15;
    respect.earnStreet(e, 1);
    return true;
}
