const economy = @import("economy.zig");
const rival = @import("rival.zig");
const player = @import("player.zig");

pub const INF_X: f32 = 21.0;
pub const INF_Z: f32 = 17.0;

pub fn near(p: player.Player) bool {
    const dx = p.x - INF_X;
    const dz = p.y - INF_Z;
    return dx * dx + dz * dz < 12.0;
}

pub fn pay(eco: *economy.Economy, r: *rival.Rival) bool {
    if (eco.treasury < 250) return false;
    eco.treasury -= 250;
    rival.pushBack(r);
    rival.pushBack(r);
    return true;
}
