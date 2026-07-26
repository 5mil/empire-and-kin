const player = @import("player.zig");
const economy = @import("economy.zig");
const scene = @import("../engine/scene.zig");

pub const TAXI_X: f32 = 13.0;
pub const TAXI_Z: f32 = 19.5;

pub fn near(p: player.Player) bool {
    const dx = p.x - TAXI_X;
    const dz = p.y - TAXI_Z;
    return dx * dx + dz * dz < 9.0;
}

pub fn rideHome(p: *player.Player, eco: *economy.Economy) bool {
    if (eco.treasury < 40) return false;
    eco.treasury -= 40;
    p.x = scene.SAFEHOUSE_X;
    p.y = scene.SAFEHOUSE_Z + 3.0;
    return true;
}
